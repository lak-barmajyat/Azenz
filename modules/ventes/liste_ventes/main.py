from __future__ import annotations

import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from modules.ventes.liste_ventes.model import VentesModel
from services.paths import PROJECT_ROOT


def main() -> int:
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    model = VentesModel(engine)
    engine.rootContext().setContextProperty("ventesModel", model)
    engine.load(
        QUrl.fromLocalFile(str(PROJECT_ROOT / "modules" / "ventes" / "liste_ventes" / "Ventes.qml"))
    )
    if not engine.rootObjects():
        return 1
    model.refresh()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
