from __future__ import annotations

import csv
from collections.abc import Callable
from datetime import datetime
from decimal import Decimal
from pathlib import Path
from typing import Any

from PySide6.QtCore import Property, QObject, QThread, QUrl, Signal, Slot
from PySide6.QtGui import QDesktopServices
from sqlalchemy import delete, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.d_document_lignes import DDocumentLignes
from database.models.d_documents import DDocuments
from database.models.d_mouvements_stock import DMouvementsStock
from database.models.d_stock import DStock
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session
from modules.stockage.document_printing import render_stock_documents
from services.logger import get_logger
from services.paths import app_data_dir


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
    exportCompleted = Signal(str)
    exportFailed = Signal(str)
    printCompleted = Signal(str)
    printFailed = Signal(str)

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
        elif operation == "delete" and isinstance(result, int):
            self.deleteCompleted.emit(result)
            self.refresh()
        elif operation == "print":
            if result in {"not_found", "service_unavailable"}:
                self.printFailed.emit(str(result))
            elif not isinstance(result, str):
                self.printFailed.emit(str(result or "service_unavailable"))
            elif not QDesktopServices.openUrl(QUrl.fromLocalFile(result)):
                self.printFailed.emit("open_failed")
            else:
                self.printCompleted.emit(result)
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

    @Slot(QUrl, "QVariantList")
    def exportCsv(self, destination: QUrl, records: list[dict[str, Any]]) -> None:
        if destination.isEmpty() or not destination.isLocalFile():
            self.exportFailed.emit("invalid_destination")
            return
        path = Path(destination.toLocalFile())
        if path.suffix.casefold() != ".csv":
            path = path.with_suffix(".csv")
        try:
            self._write_csv(path, records)
        except (OSError, ValueError):
            self._logger.exception("Stock list export failed")
            self.exportFailed.emit("write_failed")
            return
        self.exportCompleted.emit(str(path))

    @staticmethod
    def _write_csv(path: Path, records: list[dict[str, Any]]) -> None:
        columns = (
            ("code", "Code document"),
            ("type", "Type document"),
            ("date", "Date"),
            ("status", "Statut"),
            ("comment", "Commentaire"),
        )
        with path.open("w", encoding="utf-8-sig", newline="") as output:
            writer = csv.writer(output, delimiter=";")
            writer.writerow([title for _, title in columns])
            for record in records:
                writer.writerow([record.get(key, "") for key, _ in columns])

    @Slot("QVariantList")
    def printDocuments(self, document_ids: list[int]) -> None:
        ids = sorted({int(value) for value in document_ids if int(value) > 0})
        if not ids or self.busy or self._closing:
            return
        if self._preview:
            self.printFailed.emit("preview_only")
            return
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        destination = app_data_dir() / "prints" / f"stockage-{timestamp}.pdf"
        self._start("print", lambda: self._create_printout(ids, destination))

    def _create_printout(self, document_ids: list[int], destination: Path) -> str:
        try:
            documents = self._load_print_documents(document_ids)
            if not documents:
                return "not_found"
            render_stock_documents(destination, documents)
            return str(destination)
        except (
            ArithmeticError,
            KeyError,
            OSError,
            RuntimeError,
            SQLAlchemyError,
            TypeError,
            ValueError,
        ):
            destination.unlink(missing_ok=True)
            self._logger.exception("Stock document PDF generation failed")
            return "service_unavailable"

    @with_session()
    def _load_print_documents(
        self, document_ids: list[int], *, session: Session
    ) -> list[dict[str, Any]]:
        headers = session.execute(
            select(
                DDocuments.id,
                DDocuments.code_document,
                DDocuments.date_document,
                DDocuments.status,
                DDocuments.commentaire,
                PTypesDocuments.nom_type_document,
            )
            .join(PTypesDocuments, DDocuments.type_document_id == PTypesDocuments.id)
            .where(
                DDocuments.id.in_(document_ids),
                DDocuments.supprime == 0,
                PTypesDocuments.domaine == "STOCK",
            )
            .order_by(DDocuments.date_document, DDocuments.id)
        ).all()
        lines_by_document: dict[int, list[dict[str, Any]]] = {
            int(header.id): [] for header in headers
        }
        if lines_by_document:
            lines = session.execute(
                select(
                    DDocumentLignes.document_id,
                    DDocumentLignes.code_article,
                    DDocumentLignes.designation,
                    DDocumentLignes.quantite,
                    DDocumentLignes.commentaire,
                )
                .where(
                    DDocumentLignes.document_id.in_(list(lines_by_document)),
                    DDocumentLignes.supprime == 0,
                )
                .order_by(DDocumentLignes.document_id, DDocumentLignes.numero_ligne)
            ).all()
            for line in lines:
                lines_by_document[int(line.document_id)].append(
                    {
                        "reference": line.code_article or "",
                        "description": line.designation or "",
                        "quantity": line.quantite,
                        "comment": line.commentaire or "",
                    }
                )
        return [
            {
                "documentCode": header.code_document,
                "documentType": header.nom_type_document,
                "date": header.date_document,
                "status": header.status,
                "comment": header.commentaire or "",
                "lines": lines_by_document[int(header.id)],
            }
            for header in headers
        ]

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
