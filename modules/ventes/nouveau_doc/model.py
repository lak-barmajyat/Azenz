from __future__ import annotations

from collections.abc import Callable
from copy import deepcopy
from datetime import date, datetime, time
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation
from typing import Any

from PySide6.QtCore import Property, QObject, QThread, Signal, Slot
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.d_articles import DArticles
from database.models.d_document_lignes import DDocumentLignes
from database.models.d_documents import DDocuments
from database.models.d_tiers import DTiers
from database.models.p_tvas import PTvas
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session
from services.code_generation import next_code
from services.logger import get_logger
from services.user_session import UserSession


class _LoadThread(QThread):
    def __init__(self, operation: Callable[[], dict[str, Any] | None], parent: QObject) -> None:
        super().__init__(parent)
        self._operation = operation
        self.result: dict[str, Any] | None = None

    def run(self) -> None:
        self.result = self._operation()


class NouveauDocModel(QObject):
    """Article lookup, draft editing and atomic document/line creation."""

    documentCodeChanged = Signal()
    codeBusyChanged = Signal()
    codeGenerationFailed = Signal()
    lookupsChanged = Signal()
    lookupsBusyChanged = Signal()
    lookupsFailed = Signal()
    documentLoaded = Signal(dict)
    documentLoadingChanged = Signal()
    documentLoadFailed = Signal(str)
    dataChanged = Signal()
    hasChangesChanged = Signal()
    validationFailed = Signal(str)
    articleSearchChanged = Signal()
    searchBusyChanged = Signal()
    searchFailed = Signal()
    busyChanged = Signal()
    documentSaved = Signal(int, str)
    documentUnchanged = Signal()
    saveFailed = Signal(str)

    def __init__(
        self,
        parent: QObject | None = None,
        *,
        preview: bool = False,
        user_session: UserSession | None = None,
    ) -> None:
        super().__init__(parent)
        self._logger = get_logger(__name__)
        self._preview = preview
        self._user_session = user_session
        self._closing = False
        self._code_worker: _LoadThread | None = None
        self._requested_type = ""
        self._loading_type = ""
        self._document_code = ""
        self._lookup_worker: _LoadThread | None = None
        self._document_worker: _LoadThread | None = None
        self._clients: list[dict[str, Any]] = []
        self._document_types: list[dict[str, Any]] = []
        self._lines: list[dict[str, Any]] = []
        self._payments: list[dict[str, Any]] = []
        self._discount = Decimal(0)
        self._next_id = 1
        self._search_worker: _LoadThread | None = None
        self._search_request = ("", "")
        self._loading_search = ("", "")
        self._search_results: dict[str, Any] = {"field": "", "query": "", "items": []}
        self._save_worker: _LoadThread | None = None
        self._saved = False
        self._editing_document_id: int | None = None
        self._original_state: dict[str, Any] | None = None
        self._header_draft: dict[str, Any] = {}
        self._has_changes = False

    @Property(list, notify=lookupsChanged)
    def clients(self) -> list[dict[str, Any]]:
        return self._clients

    @Property(list, notify=lookupsChanged)
    def documentTypes(self) -> list[dict[str, Any]]:
        return self._document_types

    @Property(bool, notify=lookupsBusyChanged)
    def lookupsBusy(self) -> bool:
        return self._lookup_worker is not None

    @Slot()
    def loadLookups(self) -> None:
        if self._preview or self._closing or self._lookup_worker is not None:
            return
        self._lookup_worker = _LoadThread(self._load_lookups, self)
        self._lookup_worker.finished.connect(self._complete_lookups)
        self.lookupsBusyChanged.emit()
        self._lookup_worker.start()

    @Slot()
    def _complete_lookups(self) -> None:
        worker = self._lookup_worker
        if worker is None:
            return
        self._lookup_worker = None
        self.lookupsBusyChanged.emit()
        if worker.result is None:
            self.lookupsFailed.emit()
        else:
            self._clients = worker.result["clients"]
            self._document_types = worker.result["documentTypes"]
            self.lookupsChanged.emit()
            if self._requested_type and self._code_worker is None and not self._document_code:
                self._start_code()
        worker.deleteLater()

    @Slot()
    def shutdown(self) -> None:
        self._closing = True
        if self._lookup_worker is not None:
            self._lookup_worker.wait()
            self._complete_lookups()
        if self._document_worker is not None:
            self._document_worker.wait()
            self._complete_document()
        if self._code_worker is not None:
            self._code_worker.wait()
            self._complete_code()
        if self._search_worker is not None:
            self._search_worker.wait()
            self._complete_search()
        if self._save_worker is not None:
            self._save_worker.wait()
            self._complete_save()

    @Property(str, notify=documentCodeChanged)
    def documentCode(self) -> str:
        return self._document_code

    @Property(bool, notify=codeBusyChanged)
    def codeBusy(self) -> bool:
        return self._code_worker is not None

    @Slot(str)
    def generateDocumentCode(self, type_code: str) -> None:
        if self._closing:
            return
        self._requested_type = type_code
        self._document_code = ""
        self.documentCodeChanged.emit()
        if self._code_worker is None:
            self._start_code()

    def _start_code(self) -> None:
        if self._code_worker is not None:
            return
        document_type = next(
            (item for item in self._document_types if item["value"] == self._requested_type), None
        )
        if self._preview or self._closing or document_type is None:
            return
        self._loading_type = self._requested_type
        self._code_worker = _LoadThread(lambda: self._load_code(document_type), self)
        self._code_worker.finished.connect(self._complete_code)
        self.codeBusyChanged.emit()
        self._code_worker.start()

    @Slot()
    def _complete_code(self) -> None:
        worker = self._code_worker
        if worker is None:
            return
        self._code_worker = None
        worker.deleteLater()
        if not self._closing:
            if self._loading_type != self._requested_type:
                self._start_code()
            elif worker.result is None:
                self.codeGenerationFailed.emit()
            else:
                self._document_code = worker.result["code"]
                self.documentCodeChanged.emit()
        self.codeBusyChanged.emit()

    def _load_code(self, document_type: dict[str, Any]) -> dict[str, str] | None:
        try:
            return {"code": self._query_code(document_type)}
        except (SQLAlchemyError, RuntimeError, ValueError):
            self._logger.exception("Document code generation failed")
            return None

    @with_session()
    def _query_code(self, document_type: dict[str, Any], *, session: Session) -> str:
        # Latest saved document of this type, regardless of year or soft deletion.
        last_code = session.scalar(
            select(DDocuments.code_document)
            .where(DDocuments.type_document_id == document_type["id"])
            .order_by(DDocuments.id.desc())
            .limit(1)
        )
        return next_code(last_code, prefix=document_type["value"])

    @Slot(str, result=int)
    def clientIndexForCode(self, code: str) -> int:
        normalized = code.strip().casefold()
        return next(
            (
                index
                for index, client in enumerate(self._clients)
                if client["code"].casefold() == normalized
            ),
            -1,
        )

    @Slot(str, result=int)
    def documentTypeIndexForCode(self, code: str) -> int:
        return next(
            (
                index
                for index, document_type in enumerate(self._document_types)
                if document_type["value"] == code
            ),
            -1,
        )

    def _load_lookups(self) -> dict[str, Any] | None:
        try:
            return self._query_lookups()
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Document client/type lookup failed")
            return None

    @with_session()
    def _query_lookups(self, *, session: Session) -> dict[str, Any]:
        clients = session.execute(
            select(DTiers.id, DTiers.code_tiers, DTiers.raison_sociale)
            .where(DTiers.type_tiers == "CLIENT")
            .order_by(DTiers.raison_sociale, DTiers.code_tiers)
        ).all()
        types = session.execute(
            select(
                PTypesDocuments.id,
                PTypesDocuments.code_type_document,
                PTypesDocuments.nom_type_document,
            )
            .where(PTypesDocuments.domaine == "VENTE", PTypesDocuments.actif == 1)
            .order_by(PTypesDocuments.nom_type_document)
        ).all()
        return {
            "clients": [
                {"text": row.raison_sociale, "value": row.id, "code": row.code_tiers}
                for row in clients
            ],
            "documentTypes": [
                {
                    "text": f"{row.code_type_document} — {row.nom_type_document}",
                    "value": row.code_type_document,
                    "id": row.id,
                }
                for row in types
            ],
        }

    @Property(bool, notify=documentLoadingChanged)
    def documentLoading(self) -> bool:
        return self._document_worker is not None

    @Property(bool, notify=hasChangesChanged)
    def hasChanges(self) -> bool:
        return self._has_changes

    @Slot(int, bool)
    def loadDocument(self, document_id: int, duplicate: bool) -> None:
        if document_id <= 0 or self._preview or self._closing or self._document_worker is not None:
            return
        self._document_worker = _LoadThread(
            lambda: self._load_document(document_id, duplicate), self
        )
        self._document_worker.finished.connect(self._complete_document)
        self.documentLoadingChanged.emit()
        self.busyChanged.emit()
        self._document_worker.start()

    @Slot()
    def _complete_document(self) -> None:
        worker = self._document_worker
        if worker is None:
            return
        result = worker.result
        self._document_worker = None
        worker.deleteLater()
        self.documentLoadingChanged.emit()
        self.busyChanged.emit()
        if self._closing:
            return
        if result is None:
            self.documentLoadFailed.emit("not_found")
            return

        header = {**result["header"], "discount": result["discount"]}
        duplicate = bool(result["duplicate"])
        self._lines = result["lines"]
        self._payments = []
        self._discount = Decimal(str(result["discount"]))
        self._next_id = len(self._lines) + 1
        self._editing_document_id = None if duplicate else int(header["id"])
        self._header_draft = dict(header)
        self._original_state = None if duplicate else self._change_state(header)
        self._set_has_changes(False)
        self._requested_type = header["type"]
        if duplicate:
            self._document_code = ""
            self.documentCodeChanged.emit()
            self._start_code()
        else:
            self._document_code = header["code"]
            self.documentCodeChanged.emit()
        self.dataChanged.emit()
        self.documentLoaded.emit(header)

    def _load_document(self, document_id: int, duplicate: bool) -> dict[str, Any] | None:
        try:
            result = self._query_document(document_id)
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Sales document load failed")
            return None
        if result is not None:
            result["duplicate"] = duplicate
        return result

    @with_session()
    def _query_document(self, document_id: int, *, session: Session) -> dict[str, Any] | None:
        document = session.execute(
            select(
                DDocuments.id,
                DDocuments.code_document,
                DDocuments.date_document,
                DDocuments.montant_remise,
                DDocuments.tier_id,
                DTiers.code_tiers,
                PTypesDocuments.code_type_document,
            )
            .join(DDocuments.type_document)
            .outerjoin(DDocuments.tier)
            .where(
                DDocuments.id == document_id,
                DDocuments.supprime == 0,
                PTypesDocuments.domaine == "VENTE",
            )
        ).one_or_none()
        if document is None:
            return None
        rows = session.execute(
            select(
                DDocumentLignes.id,
                DDocumentLignes.article_id,
                DDocumentLignes.code_article,
                DDocumentLignes.designation,
                DDocumentLignes.quantite,
                DDocumentLignes.prix_unitaire_ht,
                DDocumentLignes.prix_unitaire_ttc,
                DDocumentLignes.tva_id,
                DDocumentLignes.code_tva,
                DDocumentLignes.tva_percentage,
                DDocumentLignes.montant_ht,
                DDocumentLignes.montant_ttc,
            )
            .where(
                DDocumentLignes.document_id == document_id,
                DDocumentLignes.supprime == 0,
            )
            .order_by(DDocumentLignes.numero_ligne)
        ).all()
        lines = [
            {
                "id": index,
                "lineId": row.id,
                "articleId": row.article_id,
                "reference": row.code_article or "",
                "description": row.designation or "",
                "quantity": float(row.quantite),
                "priceHT": float(row.prix_unitaire_ht),
                "priceTTC": float(row.prix_unitaire_ttc or 0),
                "vat": float(row.tva_percentage),
                "totalHT": float(row.montant_ht or 0),
                "totalTTC": float(row.montant_ttc or 0),
                "tvaId": row.tva_id,
                "tvaCode": row.code_tva,
            }
            for index, row in enumerate(rows, 1)
        ]
        return {
            "header": {
                "id": document.id,
                "client": {"value": document.tier_id},
                "clientCode": document.code_tiers or "",
                "code": document.code_document,
                "type": document.code_type_document,
                "date": document.date_document.date().isoformat(),
            },
            "discount": str(document.montant_remise),
            "lines": lines,
        }

    @Property(dict, notify=articleSearchChanged)
    def articleSearchResults(self) -> dict[str, Any]:
        return self._search_results

    @Property(bool, notify=searchBusyChanged)
    def searchBusy(self) -> bool:
        return self._search_worker is not None

    @Slot(str, str)
    def searchArticles(self, field: str, query: str) -> None:
        if self._closing:
            return
        self._search_request = (field, query) if field in {"reference", "description"} else ("", "")
        self._search_results = {"field": field, "query": query, "items": []}
        self.articleSearchChanged.emit()
        if self._search_worker is None:
            self._start_search()

    def _start_search(self) -> None:
        field, query = self._search_request
        if self._preview or self._closing or not field or not query.strip():
            return
        self._loading_search = self._search_request
        self._search_worker = _LoadThread(lambda: self._load_articles(field, query), self)
        self._search_worker.finished.connect(self._complete_search)
        self.searchBusyChanged.emit()
        self._search_worker.start()

    @Slot()
    def _complete_search(self) -> None:
        worker = self._search_worker
        if worker is None:
            return
        self._search_worker = None
        worker.deleteLater()
        if not self._closing:
            if self._loading_search != self._search_request:
                self._start_search()
            elif worker.result is None:
                self.searchFailed.emit()
            else:
                self._search_results = worker.result
                self.articleSearchChanged.emit()
        self.searchBusyChanged.emit()

    def _load_articles(self, field: str, query: str) -> dict[str, Any] | None:
        try:
            return {"field": field, "query": query, "items": self._query_articles(field, query)}
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Article search failed")
            return None

    @with_session()
    def _query_articles(self, field: str, query: str, *, session: Session) -> list[dict[str, Any]]:
        column = DArticles.code_article if field == "reference" else DArticles.designation
        rows = session.execute(
            select(
                DArticles.id,
                DArticles.code_article,
                DArticles.designation,
                DArticles.prix_vente_ht,
                DArticles.tva_id,
                PTvas.code_tva,
                PTvas.taux,
            )
            .outerjoin(DArticles.tva)
            .where(column.icontains(query.strip(), autoescape=True))
            .order_by(column, DArticles.id)
            .limit(30)
        ).all()
        return [
            {
                "id": row.id,
                "articleId": row.id,
                "reference": row.code_article,
                "description": row.designation,
                "priceHT": str(row.prix_vente_ht),
                "vat": str(row.taux or 0),
                "tvaId": row.tva_id,
                "tvaCode": row.code_tva or "SANS_TVA",
            }
            for row in rows
        ]

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._save_worker is not None or self._document_worker is not None

    @Property(list, notify=dataChanged)
    def lines(self) -> list[dict[str, Any]]:
        return self._lines

    @Property(list, notify=dataChanged)
    def payments(self) -> list[dict[str, Any]]:
        return self._payments

    @Property(dict, notify=dataChanged)
    def totals(self) -> dict[str, float]:
        ht = sum((Decimal(str(row["totalHT"])) for row in self._lines), Decimal(0))
        gross = self._gross_total()
        return {
            "ht": float(ht),
            "vat": float(gross - ht),
            "ttc": float(max(Decimal(0), gross - self._discount)),
        }

    @Slot()
    def reset(self) -> None:
        if self.busy:
            return
        self._saved = False
        self._editing_document_id = None
        self._original_state = None
        self._header_draft = {}
        self._set_has_changes(False)
        self._search_request = ("", "")
        self._search_results = {"field": "", "query": "", "items": []}
        self.articleSearchChanged.emit()
        self._requested_type = ""
        self._document_code = ""
        self.documentCodeChanged.emit()
        self._lines = []
        self._payments = []
        self._discount = Decimal(0)
        self._next_id = 1
        self.dataChanged.emit()

    def _set_has_changes(self, changed: bool) -> None:
        if self._has_changes == changed:
            return
        self._has_changes = changed
        self.hasChangesChanged.emit()

    def _change_state(self, header: dict[str, Any]) -> dict[str, Any]:
        client = header.get("client") or {}
        return {
            "clientId": client.get("value"),
            "code": header.get("code", "").strip(),
            "type": header.get("type", ""),
            "date": header.get("date", ""),
            "discount": self._discount,
            "lines": [
                {
                    "articleId": row.get("articleId"),
                    "quantity": self._number(row.get("quantity", "")),
                    "priceHT": self._number(row.get("priceHT", "")),
                    "vat": self._number(row.get("vat", 0)),
                    "tvaId": row.get("tvaId"),
                    "tvaCode": row.get("tvaCode", "SANS_TVA"),
                }
                for row in self._lines
            ],
        }

    def _refresh_change_flag(self) -> None:
        if self._original_state is None or not self._header_draft:
            return
        try:
            changed = self._change_state(self._header_draft) != self._original_state
        except ValueError:
            changed = True
        self._set_has_changes(changed)

    @Slot("QVariantMap")
    def updateDraftState(self, header: dict[str, Any]) -> None:
        self._header_draft = dict(header)
        self._refresh_change_flag()

    @Slot("QVariantMap")
    def captureDraftBaseline(self, header: dict[str, Any]) -> None:
        self._header_draft = dict(header)
        self._original_state = self._change_state(self._header_draft)
        self._set_has_changes(False)

    @staticmethod
    def _number(value: Any) -> Decimal:
        text = "".join(str(value).replace("MAD", "").split())
        if "," in text:
            text = text.replace(".", "").replace(",", ".")
        try:
            number = Decimal(text)
        except InvalidOperation as error:
            raise ValueError("Invalid number") from error
        if not number.is_finite():
            raise ValueError("Invalid number")
        return number

    def _line_values(self, values: dict[str, Any]) -> dict[str, float]:
        quantity = self._number(values.get("quantity", ""))
        price = self._number(values.get("priceHT", ""))
        vat = self._number(values.get("vat", 0))
        if quantity <= 0 or price < 0 or vat < 0:
            raise ValueError("Invalid line")
        total = quantity * price
        return {
            "quantity": float(quantity),
            "priceHT": float(price),
            "vat": float(vat),
            "priceTTC": float(price * (1 + vat / 100)),
            "totalHT": float(total),
            "totalTTC": float(total * (1 + vat / 100)),
        }

    @Slot("QVariantMap", result="QVariantMap")
    def computeLine(self, values: dict[str, Any]) -> dict[str, float]:
        try:
            calculated = self._line_values(values)
            return {key: calculated[key] for key in ("priceTTC", "totalHT", "totalTTC")}
        except ValueError:
            return {"priceTTC": 0.0, "totalHT": 0.0, "totalTTC": 0.0}

    @Slot("QVariantMap", result=bool)
    def validLine(self, values: dict[str, Any]) -> bool:
        try:
            self._line_values(values)
            return True
        except ValueError:
            return False

    def _id(self) -> int:
        value = self._next_id
        self._next_id += 1
        return value

    @Slot("QVariantMap", "QVariantMap", int, result=bool)
    def addLine(self, values: dict[str, Any], suggestion: dict[str, Any], editing_id: int) -> bool:
        try:
            if not suggestion:
                raise ValueError("Missing article")
            calculated = self._line_values(values)
        except ValueError:
            self.validationFailed.emit("invalid_line")
            return False
        line = {
            **values,
            **calculated,
            "id": editing_id if editing_id >= 0 else self._id(),
            "articleId": suggestion.get("articleId", suggestion.get("id")),
            "tvaId": suggestion.get("tvaId"),
            "tvaCode": suggestion.get("tvaCode", "SANS_TVA"),
        }
        if editing_id >= 0:
            self._lines = [line if row["id"] == editing_id else row for row in self._lines]
        else:
            self._lines = [*self._lines, line]
        self._refresh_change_flag()
        self.dataChanged.emit()
        return True

    @Slot(int)
    def removeLine(self, line_id: int) -> None:
        self._lines = [row for row in self._lines if row["id"] != line_id]
        self._refresh_change_flag()
        self.dataChanged.emit()

    @Slot("QVariantMap", int, result=bool)
    def addPayment(self, values: dict[str, Any], editing_id: int) -> bool:
        try:
            amount = self._number(values.get("amount", ""))
            payment_date = date.fromisoformat(values.get("date", ""))
            if amount <= 0 or not values.get("description", "").strip():
                raise ValueError("Invalid payment")
        except ValueError:
            self.validationFailed.emit("invalid_payment")
            return False
        payment = {
            **values,
            "id": editing_id if editing_id >= 0 else self._id(),
            "amount": float(amount),
            "date": payment_date.isoformat(),
            "code": values.get("code", "").strip(),
            "description": values["description"].strip(),
        }
        if editing_id >= 0:
            self._payments = [payment if row["id"] == editing_id else row for row in self._payments]
        else:
            self._payments = [*self._payments, payment]
        self._refresh_change_flag()
        self.dataChanged.emit()
        return True

    @Slot(int)
    def removePayment(self, payment_id: int) -> None:
        self._payments = [row for row in self._payments if row["id"] != payment_id]
        self._refresh_change_flag()
        self.dataChanged.emit()

    def _gross_total(self) -> Decimal:
        return sum((Decimal(str(row["totalTTC"])) for row in self._lines), Decimal(0))

    @Slot(str, result=bool)
    def applyDiscount(self, value: str) -> bool:
        try:
            amount = self._number(value)
            if amount < 0 or amount > self._gross_total():
                raise ValueError("Invalid discount")
        except ValueError:
            self.validationFailed.emit("invalid_discount")
            return False
        self._discount = amount
        self._refresh_change_flag()
        self.dataChanged.emit()
        return True

    @Slot("QVariantMap")
    def saveDocument(self, header: dict[str, Any]) -> None:
        if self.busy or self._saved or self._closing:
            return
        if self._preview:
            self.saveFailed.emit("preview_only")
            return
        try:
            document_date = date.fromisoformat(header.get("date", ""))
            if (
                not header.get("client")
                or not header.get("code", "").strip()
                or len(header["code"].strip()) > 50
                or not header.get("type")
                or not self._lines
            ):
                raise ValueError("Incomplete document")
        except (ValueError, TypeError):
            self.validationFailed.emit("invalid_document")
            return
        if self._payments:
            self.saveFailed.emit("payments_not_supported")
            return
        if self._discount > self._gross_total():
            self.validationFailed.emit("invalid_discount")
            return
        snapshot = deepcopy(
            {
                **header,
                "date": document_date.isoformat(),
                "code": header["code"].strip(),
                "lines": self._lines,
                "discount": self._discount,
                "automaticCode": self._editing_document_id is None
                and header["code"].strip() == self._document_code,
                "editingDocumentId": self._editing_document_id,
                "userId": self._user_session.user_id if self._user_session else None,
            }
        )
        self._header_draft = dict(header)
        if (
            self._editing_document_id is not None
            and self._original_state is not None
            and self._change_state(snapshot) == self._original_state
        ):
            self._set_has_changes(False)
            self.documentUnchanged.emit()
            return
        self._save_worker = _LoadThread(lambda: self._save(snapshot), self)
        self._save_worker.finished.connect(self._complete_save)
        self.busyChanged.emit()
        self._save_worker.start()

    @Slot()
    def _complete_save(self) -> None:
        worker = self._save_worker
        if worker is None:
            return
        result = worker.result
        self._save_worker = None
        worker.deleteLater()
        self._saved = result is not None and "error" not in result
        self.busyChanged.emit()
        if self._closing:
            return
        if self._saved and result is not None:
            self._set_has_changes(False)
            self.documentSaved.emit(result["id"], result["code"])
        else:
            self.saveFailed.emit(result["error"] if result else "service_unavailable")

    def _save(self, snapshot: dict[str, Any]) -> dict[str, Any]:
        try:
            if snapshot.get("editingDocumentId") is not None:
                return self._update_document(snapshot)
            return self._persist_document(snapshot)
        except ValueError as error:
            return {"error": str(error)}
        except InvalidOperation:
            return {"error": "invalid_line"}
        except IntegrityError as error:
            self._logger.exception("Document save constraint failure")
            return {
                "error": "duplicate_code"
                if error.orig and error.orig.args[0] == 1062
                else "service_unavailable"
            }
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Document save failed")
            return {"error": "service_unavailable"}

    @with_session()
    def _persist_document(self, draft: dict[str, Any], *, session: Session) -> dict[str, Any]:
        # Serialize saves per document type, including an empty series. No counter is reserved.
        document_type = session.scalar(
            select(PTypesDocuments)
            .where(
                PTypesDocuments.code_type_document == draft["type"],
                PTypesDocuments.domaine == "VENTE",
                PTypesDocuments.actif == 1,
            )
            .with_for_update()
        )
        if document_type is None:
            raise ValueError("invalid_document")
        client_id = draft["client"].get("value")
        if (
            session.scalar(
                select(DTiers.id).where(DTiers.id == client_id, DTiers.type_tiers == "CLIENT")
            )
            is None
        ):
            raise ValueError("invalid_document")
        code = draft["code"]
        if draft["automaticCode"]:
            last_code = session.scalar(
                select(DDocuments.code_document)
                .where(DDocuments.type_document_id == document_type.id)
                .order_by(DDocuments.id.desc())
                .limit(1)
                .with_for_update()
            )
            code = next_code(last_code, prefix=document_type.code_type_document)
        if len(code) > 50:
            raise ValueError("invalid_document")
        if (
            session.scalar(
                select(DDocuments.id)
                .where(
                    DDocuments.type_document_id == document_type.id,
                    DDocuments.code_document == code,
                )
                .with_for_update()
            )
            is not None
        ):
            raise ValueError("duplicate_code")

        article_ids = {row.get("articleId") for row in draft["lines"]}
        articles = {
            article.id: article
            for article in session.scalars(select(DArticles).where(DArticles.id.in_(article_ids)))
        }
        if None in article_ids or len(articles) != len(article_ids):
            raise ValueError("invalid_article")
        document = DDocuments(
            type_document_id=document_type.id,
            code_document=code,
            tier_id=client_id,
            status="BROUILLON",
            date_document=datetime.combine(date.fromisoformat(draft["date"]), time()),
            utilisateur_id=draft["userId"],
        )
        session.add(document)
        session.flush()
        for index, row in enumerate(draft["lines"], 1):
            article = articles[row["articleId"]]
            quantity = self._number(row["quantity"]).quantize(
                Decimal("0.0001"), rounding=ROUND_HALF_UP
            )
            price = self._number(row["priceHT"]).quantize(
                Decimal("0.000001"), rounding=ROUND_HALF_UP
            )
            vat = self._number(row["vat"]).quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)
            if quantity <= 0 or price < 0 or vat < 0 or len(row["tvaCode"]) > 20:
                raise ValueError("invalid_line")
            session.add(
                DDocumentLignes(
                    document_id=document.id,
                    numero_ligne=index,
                    article_id=article.id,
                    code_article=article.code_article,
                    designation=article.designation,
                    quantite=quantity,
                    prix_unitaire_ht=price,
                    tva_id=row["tvaId"],
                    code_tva=row["tvaCode"],
                    tva_percentage=vat,
                    impact_stock=int(bool(document_type.impacte_stock and article.suivi_stock)),
                    cree_par=draft["userId"],
                )
            )
        session.flush()
        # Use the DB-generated line totals; never INSERT into generated columns.
        ht, vat_total, gross = session.execute(
            select(
                func.sum(DDocumentLignes.montant_ht),
                func.sum(DDocumentLignes.montant_tva),
                func.sum(DDocumentLignes.montant_ttc),
            ).where(DDocumentLignes.document_id == document.id)
        ).one()
        if ht is None or vat_total is None or gross is None:
            raise ValueError("invalid_line")
        discount = draft["discount"].quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)
        if discount < 0 or discount > gross:
            raise ValueError("invalid_discount")
        net = gross - discount
        document.montant_ht = ht
        document.montant_tva = vat_total
        document.montant_ttc = gross
        document.montant_remise = discount
        document.montant_net_ht = (ht * net / gross if gross else Decimal(0)).quantize(
            Decimal("0.000001"), rounding=ROUND_HALF_UP
        )
        document.montant_net_ttc = net
        document.montant_paye = Decimal(0)
        document.montant_restant = net
        # The decorator commits document and lines together, or rolls everything back.
        return {"id": document.id, "code": code}

    @with_session()
    def _update_document(self, draft: dict[str, Any], *, session: Session) -> dict[str, Any]:
        document = session.scalar(
            select(DDocuments)
            .where(
                DDocuments.id == draft["editingDocumentId"],
                DDocuments.supprime == 0,
            )
            .with_for_update()
        )
        if document is None:
            raise ValueError("invalid_document")
        document_type = session.scalar(
            select(PTypesDocuments).where(
                PTypesDocuments.code_type_document == draft["type"],
                PTypesDocuments.domaine == "VENTE",
                PTypesDocuments.actif == 1,
            )
        )
        client_id = draft["client"].get("value")
        if (
            document_type is None
            or session.scalar(
                select(DTiers.id).where(DTiers.id == client_id, DTiers.type_tiers == "CLIENT")
            )
            is None
        ):
            raise ValueError("invalid_document")

        code = draft["code"]
        duplicate_id = session.scalar(
            select(DDocuments.id).where(
                DDocuments.type_document_id == document_type.id,
                DDocuments.code_document == code,
                DDocuments.id != document.id,
            )
        )
        if duplicate_id is not None:
            raise ValueError("duplicate_code")

        article_ids = {row.get("articleId") for row in draft["lines"]}
        articles = {
            article.id: article
            for article in session.scalars(select(DArticles).where(DArticles.id.in_(article_ids)))
        }
        if None in article_ids or len(articles) != len(article_ids):
            raise ValueError("invalid_article")

        all_document_lines = list(
            session.scalars(
                select(DDocumentLignes)
                .where(DDocumentLignes.document_id == document.id)
                .order_by(DDocumentLignes.numero_ligne)
                .with_for_update()
            )
        )
        existing_lines = {line.id: line for line in all_document_lines if not line.supprime}
        used_line_ids: set[int] = set()
        next_line_number = max((line.numero_ligne for line in all_document_lines), default=0) + 1
        for row in draft["lines"]:
            article = articles[row["articleId"]]
            quantity = self._number(row["quantity"]).quantize(
                Decimal("0.0001"), rounding=ROUND_HALF_UP
            )
            price = self._number(row["priceHT"]).quantize(
                Decimal("0.000001"), rounding=ROUND_HALF_UP
            )
            vat = self._number(row["vat"]).quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)
            if quantity <= 0 or price < 0 or vat < 0 or len(row["tvaCode"]) > 20:
                raise ValueError("invalid_line")
            line_id = row.get("lineId")
            line = existing_lines.get(line_id)
            if line is None:
                line = DDocumentLignes(
                    document_id=document.id,
                    numero_ligne=next_line_number,
                    code_tva=row["tvaCode"],
                    cree_par=draft["userId"],
                )
                next_line_number += 1
                session.add(line)
            else:
                used_line_ids.add(line.id)
            line.article_id = article.id
            line.code_article = article.code_article
            line.designation = article.designation
            line.quantite = quantity
            line.prix_unitaire_ht = price
            line.tva_id = row["tvaId"]
            line.code_tva = row["tvaCode"]
            line.tva_percentage = vat
            line.impact_stock = int(bool(document_type.impacte_stock and article.suivi_stock))
            line.supprime = 0
        for line_id, line in existing_lines.items():
            if line_id not in used_line_ids:
                line.supprime = 1

        document.type_document_id = document_type.id
        document.code_document = code
        document.tier_id = client_id
        document.date_document = datetime.combine(date.fromisoformat(draft["date"]), time())
        document.utilisateur_id = draft["userId"]
        session.flush()
        ht, vat_total, gross = session.execute(
            select(
                func.sum(DDocumentLignes.montant_ht),
                func.sum(DDocumentLignes.montant_tva),
                func.sum(DDocumentLignes.montant_ttc),
            ).where(
                DDocumentLignes.document_id == document.id,
                DDocumentLignes.supprime == 0,
            )
        ).one()
        if ht is None or vat_total is None or gross is None:
            raise ValueError("invalid_line")
        discount = draft["discount"].quantize(Decimal("0.000001"), rounding=ROUND_HALF_UP)
        if discount < 0 or discount > gross:
            raise ValueError("invalid_discount")
        net = gross - discount
        document.montant_ht = ht
        document.montant_tva = vat_total
        document.montant_ttc = gross
        document.montant_remise = discount
        document.montant_net_ht = (ht * net / gross if gross else Decimal(0)).quantize(
            Decimal("0.000001"), rounding=ROUND_HALF_UP
        )
        document.montant_net_ttc = net
        document.montant_restant = net - document.montant_paye
        return {"id": document.id, "code": code}
