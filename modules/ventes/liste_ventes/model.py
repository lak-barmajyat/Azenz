from __future__ import annotations

from collections.abc import Callable
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from PySide6.QtCore import Property, QObject, QThread, Signal, Slot
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.d_documents import DDocuments
from database.models.d_tiers import DTiers
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session
from services.logger import get_logger


class _LoadThread(QThread):
    def __init__(
        self, operation: Callable[[], list[dict[str, Any]] | None], parent: QObject
    ) -> None:
        super().__init__(parent)
        self._operation = operation
        self.records: list[dict[str, Any]] | None = None

    def run(self) -> None:
        self.records = self._operation()


class ListeVentesModel(QObject):
    dataChanged = Signal()
    documentTypesChanged = Signal()
    busyChanged = Signal()
    loadFailed = Signal(str)
    validationFailed = Signal(str)

    def __init__(self, parent: QObject | None = None, *, preview: bool = False) -> None:
        super().__init__(parent)
        self._logger = get_logger(__name__)
        self._preview = preview
        self._worker: _LoadThread | None = None
        self._source: list[dict[str, Any]] = []
        self._records: list[dict[str, Any]] = []
        self._totals = {"ht": 0.0, "vat": 0.0, "ttc": 0.0}
        self._types: list[str] = []
        self._code = ""
        self._document_type = ""
        self._from: date | None = None
        self._to: date | None = None

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._worker is not None

    @Property(list, notify=dataChanged)
    def records(self) -> list[dict[str, Any]]:
        return self._records

    @Property(dict, notify=dataChanged)
    def totals(self) -> dict[str, float]:
        return self._totals

    @Property(list, notify=documentTypesChanged)
    def documentTypes(self) -> list[str]:
        return self._types

    @Slot()
    def refresh(self) -> None:
        if self._worker is not None:
            return
        if self._preview:
            self._publish()
            return
        self._worker = _LoadThread(self._load, self)
        self._worker.finished.connect(self._complete)
        self.busyChanged.emit()
        self._worker.start()

    @Slot()
    def _complete(self) -> None:
        worker = self._worker
        if worker is None:
            return
        self._worker = None
        self.busyChanged.emit()
        if worker.records is None:
            self.loadFailed.emit("service_unavailable")
        else:
            self._source = worker.records
            self._publish()
        worker.deleteLater()

    @Slot()
    def shutdown(self) -> None:
        if self._worker is not None:
            self._worker.wait()
            self._complete()

    @Slot(str, str, str, str)
    def applyFilters(self, code: str, document_type: str, from_date: str, to_date: str) -> None:
        try:
            start = date.fromisoformat(from_date) if from_date else None
            end = date.fromisoformat(to_date) if to_date else None
        except ValueError:
            self.validationFailed.emit("invalid_date")
            return
        if start is not None and end is not None and start > end:
            self.validationFailed.emit("invalid_range")
            return
        self._code = code.strip().casefold()
        self._document_type = document_type
        self._from, self._to = start, end
        self._publish()

    @Slot("QVariantList")
    def setPreviewRecords(self, records: list[dict[str, Any]]) -> None:
        """Use the existing in-memory preview data without opening a database session."""
        if not self._preview:
            return
        self._source = [
            {**row, "date": datetime.strptime(row["date"], "%d/%m/%Y").date().isoformat()}
            for row in records
        ]
        self._publish()

    def _publish(self) -> None:
        rows = [
            row
            for row in self._source
            if (not self._code or self._code in row["documentCode"].casefold())
            and (not self._document_type or row["documentType"] == self._document_type)
            and (self._from is None or date.fromisoformat(row["date"]) >= self._from)
            and (self._to is None or date.fromisoformat(row["date"]) <= self._to)
        ]
        self._totals = {
            key: float(sum((Decimal(str(row[key])) for row in rows), Decimal(0)))
            for key in ("ht", "vat", "ttc")
        }
        self._records = [
            {
                **row,
                "date": date.fromisoformat(row["date"]).strftime("%d/%m/%Y"),
                **{key: float(row[key]) for key in ("ht", "vat", "ttc")},
            }
            for row in rows
        ]
        types = sorted({row["documentType"] for row in self._source})
        if types != self._types:
            self._types = types
            self.documentTypesChanged.emit()
        self.dataChanged.emit()

    def _load(self) -> list[dict[str, Any]] | None:
        try:
            return self._load_records()
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Sales list query failed")
            return None

    @with_session()
    def _load_records(self, *, session: Session) -> list[dict[str, Any]]:
        # Select all displayed fields together; no lazy queries or ORM objects cross threads.
        rows = session.execute(
            select(
                DDocuments.id,
                DDocuments.code_document,
                DDocuments.date_document,
                DDocuments.montant_ht,
                DDocuments.montant_tva,
                DDocuments.montant_ttc,
                PTypesDocuments.nom_type_document,
                DTiers.code_tiers,
                DTiers.raison_sociale,
            )
            .join(DDocuments.type_document)
            .outerjoin(DDocuments.tier)
            .where(DDocuments.supprime == 0, PTypesDocuments.domaine == "VENTE")
            .order_by(DDocuments.date_document.desc())
        ).all()
        return [
            {
                "id": row.id,
                "clientCode": row.code_tiers or "",
                "client": row.raison_sociale or "",
                "documentCode": row.code_document,
                "documentType": row.nom_type_document,
                "date": row.date_document.date().isoformat(),
                "ht": row.montant_ht,
                "vat": row.montant_tva,
                "ttc": row.montant_ttc,
            }
            for row in rows
        ]
