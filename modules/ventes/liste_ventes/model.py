from __future__ import annotations

from PySide6.QtCore import QObject, Signal, Slot

from modules.ventes.liste_ventes.repository import list_ventes


class VentesModel(QObject):
    recordsChanged = Signal(list)
    loadFailed = Signal(str)

    @Slot()
    def refresh(self) -> None:
        """Load sales records and publish them to the ventes frame."""
        try:
            records = list_ventes()
        except Exception as error:
            self.loadFailed.emit(str(error))
            return
        self.recordsChanged.emit(records)
