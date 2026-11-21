from __future__ import annotations

import csv
from collections.abc import Callable
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any

from PySide6.QtCore import Property, QObject, QThread, QUrl, Signal, Slot
from PySide6.QtGui import QDesktopServices
from sqlalchemy import select, update
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from database.models.d_document_lignes import DDocumentLignes
from database.models.d_documents import DDocuments
from database.models.d_tiers import DTiers
from database.models.p_types_documents import PTypesDocuments
from database.session import with_session
from modules.achats.liste_achats.document_printing import render_purchase_documents
from services.logger import get_logger
from services.paths import app_data_dir


class _LoadThread(QThread):
    def __init__(
        self, operation: Callable[[], list[dict[str, Any]] | None], parent: QObject
    ) -> None:
        super().__init__(parent)
        self._operation = operation
        self.records: list[dict[str, Any]] | None = None

    def run(self) -> None:
        self.records = self._operation()


class ListeAchatsModel(QObject):
    dataChanged = Signal()
    documentTypesChanged = Signal()
    busyChanged = Signal()
    loadFailed = Signal(str)
    validationFailed = Signal(str)
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
        self._closing = False
        self._worker: _LoadThread | None = None
        self._delete_worker: _LoadThread | None = None
        self._print_worker: _LoadThread | None = None
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
        return (
            self._worker is not None
            or self._delete_worker is not None
            or self._print_worker is not None
        )

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
        if self._closing or self._worker is not None:
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
        self._closing = True
        if self._delete_worker is not None:
            self._delete_worker.wait()
            self._complete_delete()
        if self._print_worker is not None:
            self._print_worker.wait()
            self._complete_print()
        if self._worker is not None:
            self._worker.wait()
            self._complete()

    @Slot("QVariantList")
    def deleteDocuments(self, document_ids: list[int]) -> None:
        ids = sorted({int(document_id) for document_id in document_ids if int(document_id) > 0})
        if not ids or self.busy:
            return
        self._delete_worker = _LoadThread(lambda: self._soft_delete(ids), self)
        self._delete_worker.finished.connect(self._complete_delete)
        self.busyChanged.emit()
        self._delete_worker.start()

    @Slot()
    def _complete_delete(self) -> None:
        worker = self._delete_worker
        if worker is None:
            return
        self._delete_worker = None
        self.busyChanged.emit()
        result = worker.records
        worker.deleteLater()
        if result is None:
            self.deleteFailed.emit("service_unavailable")
            return
        deleted = int(result[0]["count"]) if result else 0
        self.deleteCompleted.emit(deleted)
        if not self._closing:
            self.refresh()

    def _soft_delete(self, document_ids: list[int]) -> list[dict[str, Any]] | None:
        try:
            return [{"count": self._mark_deleted(document_ids)}]
        except (SQLAlchemyError, RuntimeError):
            self._logger.exception("Purchase document soft-delete failed")
            return None

    @with_session()
    def _mark_deleted(self, document_ids: list[int], *, session: Session) -> int:
        existing_ids = list(
            session.scalars(
                select(DDocuments.id)
                .join(DDocuments.type_document)
                .where(
                    DDocuments.id.in_(document_ids),
                    DDocuments.supprime == 0,
                    PTypesDocuments.domaine == "ACHAT",
                )
            )
        )
        if not existing_ids:
            return 0
        session.execute(
            update(DDocuments).where(DDocuments.id.in_(existing_ids)).values(supprime=1)
        )
        return len(existing_ids)

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
            self._logger.exception("Purchase list export failed")
            self.exportFailed.emit("write_failed")
            return
        self.exportCompleted.emit(str(path))

    @staticmethod
    def _write_csv(path: Path, records: list[dict[str, Any]]) -> None:
        columns = (
            ("supplierCode", "Code fournisseur"),
            ("supplier", "Fournisseur"),
            ("documentCode", "Code document"),
            ("documentType", "Type document"),
            ("date", "Date"),
            ("ht", "Total HT"),
            ("vat", "TVA"),
            ("ttc", "Total TTC"),
        )
        with path.open("w", encoding="utf-8-sig", newline="") as output:
            writer = csv.writer(output, delimiter=";")
            writer.writerow([title for _, title in columns])
            for record in records:
                writer.writerow([record.get(key, "") for key, _ in columns])

    @Slot("QVariantList")
    def printDocuments(self, document_ids: list[int]) -> None:
        ids = sorted({int(document_id) for document_id in document_ids if int(document_id) > 0})
        if not ids or self.busy or self._closing:
            return
        if self._preview:
            self.printFailed.emit("preview_only")
            return
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        destination = app_data_dir() / "prints" / f"achats-{timestamp}.pdf"
        self._print_worker = _LoadThread(lambda: self._create_printout(ids, destination), self)
        self._print_worker.finished.connect(self._complete_print)
        self.busyChanged.emit()
        self._print_worker.start()

    @Slot()
    def _complete_print(self) -> None:
        worker = self._print_worker
        if worker is None:
            return
        self._print_worker = None
        self.busyChanged.emit()
        result = worker.records
        worker.deleteLater()
        if self._closing:
            return
        if result is None:
            self.printFailed.emit("service_unavailable")
            return
        if not result:
            self.printFailed.emit("not_found")
            return
        path = str(result[0]["path"])
        if not QDesktopServices.openUrl(QUrl.fromLocalFile(path)):
            self.printFailed.emit("open_failed")
            return
        self.printCompleted.emit(path)

    def _create_printout(
        self, document_ids: list[int], destination: Path
    ) -> list[dict[str, Any]] | None:
        try:
            documents = self._load_print_documents(document_ids)
            if not documents:
                return []
            render_purchase_documents(destination, documents)
            return [{"path": str(destination)}]
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
            self._logger.exception("Purchase document PDF generation failed")
            return None

    @with_session()
    def _load_print_documents(
        self, document_ids: list[int], *, session: Session
    ) -> list[dict[str, Any]]:
        headers = session.execute(
            select(
                DDocuments.id,
                DDocuments.code_document,
                DDocuments.date_document,
                DDocuments.montant_ht,
                DDocuments.montant_tva,
                DDocuments.montant_remise,
                DDocuments.montant_net_ttc,
                DTiers.code_tiers,
                DTiers.raison_sociale,
                PTypesDocuments.nom_type_document,
            )
            .join(DDocuments.type_document)
            .outerjoin(DDocuments.tier)
            .where(
                DDocuments.id.in_(document_ids),
                DDocuments.supprime == 0,
                PTypesDocuments.domaine == "ACHAT",
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
                    DDocumentLignes.prix_unitaire_ht,
                    DDocumentLignes.prix_unitaire_ttc,
                    DDocumentLignes.tva_percentage,
                    DDocumentLignes.montant_ht,
                    DDocumentLignes.montant_ttc,
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
                        "priceHT": line.prix_unitaire_ht,
                        "priceTTC": line.prix_unitaire_ttc,
                        "vat": line.tva_percentage,
                        "totalHT": line.montant_ht,
                        "totalTTC": line.montant_ttc,
                    }
                )
        return [
            {
                "documentCode": header.code_document,
                "documentType": header.nom_type_document,
                "date": header.date_document,
                "supplierCode": header.code_tiers or "",
                "supplier": header.raison_sociale or "",
                "totalHT": header.montant_ht,
                "totalVAT": header.montant_tva,
                "discount": header.montant_remise,
                "totalNetTTC": header.montant_net_ttc,
                "lines": lines_by_document[int(header.id)],
            }
            for header in headers
        ]

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
            self._logger.exception("Purchase list query failed")
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
            .where(DDocuments.supprime == 0, PTypesDocuments.domaine == "ACHAT")
            .order_by(DDocuments.date_document.desc())
        ).all()
        return [
            {
                "id": row.id,
                "supplierCode": row.code_tiers or "",
                "supplier": row.raison_sociale or "",
                "documentCode": row.code_document,
                "documentType": row.nom_type_document,
                "date": row.date_document.date().isoformat(),
                "ht": row.montant_ht,
                "vat": row.montant_tva,
                "ttc": row.montant_ttc,
            }
            for row in rows
        ]
