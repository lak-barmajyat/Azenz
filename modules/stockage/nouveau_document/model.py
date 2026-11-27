from __future__ import annotations

from collections.abc import Callable
from datetime import date, datetime, time
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation
from typing import Any

from PySide6.QtCore import Property, QObject, QThread, Signal, Slot
from sqlalchemy import delete, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.d_articles import DArticles
from database.models.d_document_lignes import DDocumentLignes
from database.models.d_documents import DDocuments
from database.models.d_mouvements_stock import DMouvementsStock
from database.models.d_stock import DStock
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session
from services.code_generation import next_code
from services.logger import get_logger


class _Worker(QThread):
    def __init__(self, operation: Callable[[], Any], parent: QObject) -> None:
        super().__init__(parent)
        self._operation = operation
        self.result: Any = None

    def run(self) -> None:
        self.result = self._operation()


class NouveauDocumentModel(QObject):
    lookupsChanged = Signal()
    articleSearchChanged = Signal()
    busyChanged = Signal()
    loadFailed = Signal(str)
    searchFailed = Signal()
    validationFailed = Signal(str)
    saveFailed = Signal(str)
    documentLoaded = Signal(dict)
    documentSaved = Signal(int, str)

    def __init__(self, parent: QObject | None = None, *, preview: bool = False) -> None:
        super().__init__(parent)
        self._logger = get_logger(__name__)
        self._preview = preview
        self._types: list[dict[str, Any]] = []
        self._search_results: list[dict[str, Any]] = []
        self._worker: _Worker | None = None
        self._operation = ""
        self._closing = False

    @Property(list, notify=lookupsChanged)
    def documentTypes(self) -> list[dict[str, Any]]:
        return self._types

    @Property(list, notify=articleSearchChanged)
    def articleSearchResults(self) -> list[dict[str, Any]]:
        return self._search_results

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._worker is not None

    @Slot()
    def loadLookups(self) -> None:
        if not self.busy:
            self._start("lookups", self._load_types)

    @Slot(str, str)
    def searchArticles(self, field: str, query: str) -> None:
        if self.busy:
            return
        key = "description" if field == "description" else "reference"
        self._start("search", lambda: self._query_articles(key, query))

    @Slot(int, bool)
    def loadDocument(self, document_id: int, duplicate: bool) -> None:
        if document_id > 0 and not self.busy:
            self._start("load", lambda: self._query_document(document_id, duplicate))

    @Slot("QVariantMap", int)
    def saveDocument(self, draft: dict[str, Any], editing_document_id: int) -> None:
        if self.busy:
            return
        if self._preview:
            self.saveFailed.emit("preview_only")
            return
        if not draft.get("type") or not draft.get("date") or not draft.get("lines"):
            self.validationFailed.emit("invalid_document")
            return
        snapshot = dict(draft)
        snapshot["lines"] = [dict(line) for line in draft["lines"]]
        snapshot["editingDocumentId"] = editing_document_id if editing_document_id > 0 else None
        self._start("save", lambda: self._save(snapshot))

    def _start(self, operation: str, callback: Callable[[], Any]) -> None:
        self._operation = operation
        self._worker = _Worker(callback, self)
        self._worker.finished.connect(self._complete)
        self.busyChanged.emit()
        self._worker.start()

    @Slot()
    def _complete(self) -> None:
        worker = self._worker
        if worker is None:
            return
        operation = self._operation
        result = worker.result
        self._worker = None
        self._operation = ""
        self.busyChanged.emit()
        worker.deleteLater()
        if operation == "lookups":
            if isinstance(result, list):
                self._types = result
                self.lookupsChanged.emit()
            else:
                self.loadFailed.emit("service_unavailable")
        elif operation == "search":
            if isinstance(result, list):
                self._search_results = result
                self.articleSearchChanged.emit()
            else:
                self.searchFailed.emit()
        elif operation == "load":
            if isinstance(result, dict) and "error" not in result:
                self.documentLoaded.emit(result)
            else:
                self.loadFailed.emit(str((result or {}).get("error", "service_unavailable")))
        elif isinstance(result, dict) and "id" in result:
            self.documentSaved.emit(result["id"], result["code"])
        else:
            self.saveFailed.emit(str((result or {}).get("error", "service_unavailable")))

    @Slot()
    def shutdown(self) -> None:
        self._closing = True
        if self._worker is not None:
            self._worker.wait()
            self._complete()

    def _load_types(self) -> list[dict[str, Any]] | None:
        try:
            return self._query_types()
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Stock document type loading failed")
            return None

    @with_session()
    def _query_types(self, *, session: Session) -> list[dict[str, Any]]:
        types = session.scalars(
            select(PTypesDocuments)
            .where(PTypesDocuments.domaine == "STOCK", PTypesDocuments.actif == 1)
            .order_by(PTypesDocuments.id)
        )
        return [
            {
                "text": row.nom_type_document,
                "value": row.code_type_document,
                "movementType": self._movement_type(row),
            }
            for row in types
        ]

    @staticmethod
    def _movement_type(document_type: PTypesDocuments) -> str:
        if document_type.sens_stock == "ENTREE":
            return "ENTREE"
        if document_type.sens_stock == "SORTIE":
            return "SORTIE"
        name = f"{document_type.code_type_document} {document_type.nom_type_document}".upper()
        return "INVENTAIRE" if "INVENT" in name else "AJUSTEMENT"

    @with_session()
    def _query_articles(self, field: str, query: str, *, session: Session) -> list[dict[str, Any]]:
        column = DArticles.designation if field == "description" else DArticles.code_article
        pattern = f"%{query.replace('%', r'\%').replace('_', r'\_')}%"
        rows = session.execute(
            select(DArticles, DStock.quantite_stock)
            .outerjoin(DStock, DStock.article_id == DArticles.id)
            .where(DArticles.suivi_stock == 1, column.ilike(pattern, escape="\\"))
            .order_by(column)
            .limit(20)
        ).all()
        return [
            {
                "articleId": article.id,
                "reference": article.code_article,
                "description": article.designation,
                "stock": float(quantity or 0),
            }
            for article, quantity in rows
        ]

    @with_session()
    def _query_document(
        self, document_id: int, duplicate: bool, *, session: Session
    ) -> dict[str, Any]:
        document = session.scalar(
            select(DDocuments)
            .join(PTypesDocuments)
            .where(
                DDocuments.id == document_id,
                DDocuments.supprime == 0,
                PTypesDocuments.domaine == "STOCK",
            )
        )
        if document is None:
            return {"error": "invalid_document"}
        document_type = document.type_document
        lines = list(
            session.scalars(
                select(DDocumentLignes)
                .where(DDocumentLignes.document_id == document.id, DDocumentLignes.supprime == 0)
                .order_by(DDocumentLignes.numero_ligne)
            )
        )
        return {
            "id": 0 if duplicate else document.id,
            "sourceId": document.id,
            "code": "" if duplicate else document.code_document,
            "type": document_type.code_type_document,
            "date": document.date_document.date().isoformat(),
            "comment": document.commentaire or "",
            "lines": [
                {
                    "id": index,
                    "lineId": None if duplicate else line.id,
                    "articleId": line.article_id,
                    "reference": line.code_article or "",
                    "description": line.designation or "",
                    "quantity": str(line.quantite),
                    "comment": line.commentaire or "",
                }
                for index, line in enumerate(lines, 1)
            ],
        }

    def _save(self, draft: dict[str, Any]) -> dict[str, Any]:
        try:
            return self._persist(draft)
        except (ValueError, InvalidOperation) as error:
            return {"error": str(error)}
        except IntegrityError as error:
            self._logger.exception("Stock document constraint failure")
            arguments = getattr(error.orig, "args", ())
            code = "duplicate_code" if arguments and arguments[0] == 1062 else "service_unavailable"
            return {"error": code}
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Stock document save failed")
            return {"error": "service_unavailable"}

    @with_session()
    def _persist(self, draft: dict[str, Any], *, session: Session) -> dict[str, Any]:
        document_type = session.scalar(
            select(PTypesDocuments)
            .where(
                PTypesDocuments.code_type_document == draft["type"],
                PTypesDocuments.domaine == "STOCK",
                PTypesDocuments.actif == 1,
            )
            .with_for_update()
        )
        if document_type is None:
            raise ValueError("invalid_document")
        movement_type = self._movement_type(document_type)
        document_id = draft.get("editingDocumentId")
        document = None
        old_movements: list[DMouvementsStock] = []
        if document_id:
            document = session.scalar(
                select(DDocuments)
                .join(PTypesDocuments)
                .where(
                    DDocuments.id == document_id,
                    DDocuments.supprime == 0,
                    PTypesDocuments.domaine == "STOCK",
                )
                .with_for_update()
            )
            if document is None:
                raise ValueError("invalid_document")
            old_movements = list(
                session.scalars(
                    select(DMouvementsStock)
                    .where(DMouvementsStock.document_id == document.id)
                    .order_by(DMouvementsStock.article_id, DMouvementsStock.id)
                    .with_for_update()
                )
            )
        article_ids = {int(row.get("articleId") or 0) for row in draft["lines"]}
        if 0 in article_ids or len(article_ids) != len(draft["lines"]):
            raise ValueError("invalid_article")
        articles = {
            article.id: article
            for article in session.scalars(
                select(DArticles)
                .where(DArticles.id.in_(article_ids), DArticles.suivi_stock == 1)
                .order_by(DArticles.id)
            )
        }
        if len(articles) != len(article_ids):
            raise ValueError("invalid_article")
        all_article_ids = sorted(article_ids | {row.article_id for row in old_movements})
        stocks = {
            stock.article_id: stock
            for stock in session.scalars(
                select(DStock)
                .where(DStock.article_id.in_(all_article_ids))
                .order_by(DStock.article_id)
                .with_for_update()
            )
        }
        for article_id in all_article_ids:
            if article_id not in stocks:
                stock = DStock(article_id=article_id, quantite_stock=Decimal(0))
                session.add(stock)
                stocks[article_id] = stock
        base = {article_id: stock.quantite_stock for article_id, stock in stocks.items()}
        for movement in old_movements:
            delta = movement.quantite if movement.sens_mouvement == "IN" else -movement.quantite
            base[movement.article_id] -= delta
        code = str(draft.get("code") or "").strip()
        if not code:
            last_code = session.scalar(
                select(DDocuments.code_document)
                .where(DDocuments.type_document_id == document_type.id)
                .order_by(DDocuments.id.desc())
                .limit(1)
                .with_for_update()
            )
            code = next_code(last_code, prefix=document_type.code_type_document)
        duplicate = session.scalar(
            select(DDocuments.id).where(
                DDocuments.type_document_id == document_type.id,
                DDocuments.code_document == code,
                DDocuments.id != (document.id if document else 0),
            )
        )
        if duplicate is not None or len(code) > 50:
            raise ValueError("duplicate_code" if duplicate else "invalid_document")
        parsed_date = date.fromisoformat(str(draft["date"]))
        quantities: dict[int, Decimal] = {}
        for row in draft["lines"]:
            quantity = Decimal(str(row["quantity"]).replace(",", ".")).quantize(
                Decimal("0.0001"), rounding=ROUND_HALF_UP
            )
            if quantity < 0 or (movement_type in {"ENTREE", "SORTIE"} and quantity == 0):
                raise ValueError("invalid_line")
            quantities[int(row["articleId"])] = quantity
        deltas: dict[int, Decimal] = {}
        for article_id, quantity in quantities.items():
            if movement_type == "ENTREE":
                delta = quantity
            elif movement_type == "SORTIE":
                delta = -quantity
            else:
                delta = quantity - base[article_id]
            if base[article_id] + delta < 0:
                raise ValueError("negative_stock")
            deltas[article_id] = delta
        for article_id, quantity in base.items():
            if article_id not in deltas and quantity < 0:
                raise ValueError("negative_stock")
        if document is None:
            document = DDocuments(
                type_document_id=document_type.id,
                code_document=code,
                status="VALIDE",
                date_document=datetime.combine(parsed_date, time()),
            )
            session.add(document)
            session.flush()
        else:
            session.execute(
                delete(DMouvementsStock).where(DMouvementsStock.document_id == document.id)
            )
            for line in session.scalars(
                select(DDocumentLignes).where(
                    DDocumentLignes.document_id == document.id, DDocumentLignes.supprime == 0
                )
            ):
                line.supprime = 1
            document.type_document_id = document_type.id
            document.code_document = code
            document.date_document = datetime.combine(parsed_date, time())
        document.commentaire = str(draft.get("comment") or "").strip() or None
        document.status = "VALIDE"
        document.montant_ht = document.montant_remise = document.montant_net_ht = Decimal(0)
        document.montant_tva = document.montant_ttc = document.montant_net_ttc = Decimal(0)
        document.montant_paye = document.montant_restant = Decimal(0)
        next_line = (
            session.scalar(
                select(DDocumentLignes.numero_ligne)
                .where(DDocumentLignes.document_id == document.id)
                .order_by(DDocumentLignes.numero_ligne.desc())
                .limit(1)
            )
            or 0
        )
        for row in draft["lines"]:
            article_id = int(row["articleId"])
            article = articles[article_id]
            next_line += 1
            line = DDocumentLignes(
                document_id=document.id,
                numero_ligne=next_line,
                article_id=article_id,
                code_article=article.code_article,
                designation=article.designation,
                quantite=quantities[article_id],
                code_tva="SANS_TVA",
                tva_percentage=Decimal(0),
                prix_unitaire_ht=Decimal(0),
                impact_stock=1,
                commentaire=str(row.get("comment") or "").strip() or None,
            )
            session.add(line)
            session.flush()
            delta = deltas[article_id]
            if delta:
                session.add(
                    DMouvementsStock(
                        article_id=article_id,
                        document_id=document.id,
                        document_ligne_id=line.id,
                        type_mouvement=movement_type,
                        sens_mouvement="IN" if delta > 0 else "OUT",
                        quantite=abs(delta),
                        date_mouvement=document.date_document,
                        description=document.commentaire or f"Document {code}",
                    )
                )
        now = datetime.now()
        for article_id, stock in stocks.items():
            stock.quantite_stock = base[article_id] + deltas.get(article_id, Decimal(0))
            stock.date_dernier_mouvement = now
        return {"id": document.id, "code": code}
