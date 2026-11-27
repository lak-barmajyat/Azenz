from __future__ import annotations

from collections.abc import Callable
from datetime import datetime
from decimal import Decimal
from typing import Any

from PySide6.QtCore import Property, QObject, QThread, Signal, Slot
from sqlalchemy import delete, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.d_document_lignes import DDocumentLignes
from database.models.d_documents import DDocuments
from database.models.d_mouvements_stock import DMouvementsStock
from database.models.d_stock import DStock
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session
from services.logger import get_logger


class _Worker(QThread):
    def __init__(self, operation: Callable[[], Any], parent: QObject) -> None:
        super().__init__(parent)
        self._operation = operation
        self.result: Any = None

    def run(self) -> None:
        self.result = self._operation()


class ListeStockModel(QObject):
    dataChanged = Signal()
    busyChanged = Signal()
    loadFailed = Signal(str)
    deleteCompleted = Signal(int)
    deleteFailed = Signal(str)

    def __init__(self, parent: QObject | None = None, *, preview: bool = False) -> None:
        super().__init__(parent)
        self._logger = get_logger(__name__)
        self._preview = preview
        self._records: list[dict[str, Any]] = []
        self._worker: _Worker | None = None
        self._operation = ""
        self._closing = False

    @Property(list, notify=dataChanged)
    def records(self) -> list[dict[str, Any]]:
        return self._records

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._worker is not None

    @Slot()
    def refresh(self) -> None:
        if self.busy or self._closing:
            return
        if self._preview:
            self.dataChanged.emit()
            return
        self._start("load", self._load)

    @Slot("QVariantList")
    def deleteDocuments(self, document_ids: list[int]) -> None:
        ids = sorted({int(value) for value in document_ids if int(value) > 0})
        if not ids or self.busy:
            return
        if self._preview:
            self.deleteFailed.emit("preview_only")
            return
        self._start("delete", lambda: self._delete(ids))

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
        if operation == "load":
            if isinstance(result, list):
                self._records = result
                self.dataChanged.emit()
            else:
                self.loadFailed.emit("service_unavailable")
        elif isinstance(result, int):
            self.deleteCompleted.emit(result)
            self.refresh()
        else:
            self.deleteFailed.emit(str(result or "service_unavailable"))

    @Slot()
    def shutdown(self) -> None:
        self._closing = True
        if self._worker is not None:
            self._worker.wait()
            self._complete()

    def _load(self) -> list[dict[str, Any]] | None:
        try:
            return self._query_records()
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Stock document loading failed")
            return None

    @with_session()
    def _query_records(self, *, session: Session) -> list[dict[str, Any]]:
        rows = session.execute(
            select(DDocuments, PTypesDocuments)
            .join(PTypesDocuments, DDocuments.type_document_id == PTypesDocuments.id)
            .where(PTypesDocuments.domaine == "STOCK", DDocuments.supprime == 0)
            .order_by(DDocuments.date_document.desc(), DDocuments.id.desc())
        ).all()
        return [
            {
                "id": document.id,
                "code": document.code_document,
                "type": document_type.nom_type_document,
                "typeCode": document_type.code_type_document,
                "date": document.date_document.strftime("%d/%m/%Y"),
                "status": "Validé" if document.status == "VALIDE" else document.status.title(),
                "statusVariant": "success" if document.status == "VALIDE" else "neutral",
                "typeVariant": self._type_variant(document_type),
                "comment": document.commentaire or "",
            }
            for document, document_type in rows
        ]

    @staticmethod
    def _type_variant(document_type: PTypesDocuments) -> str:
        if document_type.sens_stock == "ENTREE":
            return "success"
        if document_type.sens_stock == "SORTIE":
            return "danger"
        return "warning"

    def _delete(self, document_ids: list[int]) -> int | str:
        try:
            return self._delete_documents(document_ids)
        except ValueError as error:
            return str(error)
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Stock document deletion failed")
            return "service_unavailable"

    @with_session()
    def _delete_documents(self, document_ids: list[int], *, session: Session) -> int:
        documents = list(
            session.scalars(
                select(DDocuments)
                .join(PTypesDocuments)
                .where(
                    DDocuments.id.in_(document_ids),
                    DDocuments.supprime == 0,
                    PTypesDocuments.domaine == "STOCK",
                )
                .order_by(DDocuments.id)
                .with_for_update()
            )
        )
        if len(documents) != len(document_ids):
            raise ValueError("invalid_document")
        movements = list(
            session.scalars(
                select(DMouvementsStock)
                .where(DMouvementsStock.document_id.in_(document_ids))
                .order_by(DMouvementsStock.article_id, DMouvementsStock.id)
                .with_for_update()
            )
        )
        article_ids = sorted({movement.article_id for movement in movements})
        stocks = {
            stock.article_id: stock
            for stock in session.scalars(
                select(DStock)
                .where(DStock.article_id.in_(article_ids))
                .order_by(DStock.article_id)
                .with_for_update()
            )
        }
        reversals: dict[int, Decimal] = {}
        for movement in movements:
            delta = movement.quantite if movement.sens_mouvement == "IN" else -movement.quantite
            reversals[movement.article_id] = reversals.get(movement.article_id, Decimal(0)) - delta
        for article_id, reversal in reversals.items():
            stock = stocks.get(article_id)
            if stock is None:
                raise ValueError("invalid_stock")
            resulting_quantity = stock.quantite_stock + reversal
            if resulting_quantity < 0:
                raise ValueError("negative_stock")
            stock.quantite_stock = resulting_quantity
            stock.date_dernier_mouvement = datetime.now()
        session.execute(
            delete(DMouvementsStock).where(DMouvementsStock.document_id.in_(document_ids))
        )
        for document in documents:
            document.supprime = 1
        for line in session.scalars(
            select(DDocumentLignes).where(DDocumentLignes.document_id.in_(document_ids))
        ):
            line.supprime = 1
        return len(documents)
