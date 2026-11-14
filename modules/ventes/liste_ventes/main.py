from __future__ import annotations

import sys
from pathlib import Path

# Direct file execution starts with this folder, not the project root, on sys.path.
if not __package__:
    sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from database.engine import database
from database.session import setup_session
from modules.ventes.liste_ventes.model import ListeVentesModel
from services.config import load_config
from services.logger import setup_logging
from services.paths import PROJECT_ROOT, QML_DIR

WINDOW_QML = """
import QtQuick
import QtQuick.Controls.Basic

ApplicationWindow {
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: qsTr("Azenz — Liste des ventes")

    ListeVentes {
        anchors.fill: parent
        onBackRequested: Qt.quit()
        onQuitRequested: Qt.quit()
    }
}
"""


def main() -> int:
    setup_logging()
    database.setup(load_config().database)
    setup_session()
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(QML_DIR))
    model = ListeVentesModel(engine)
    engine.rootContext().setContextProperty("listeVentesModel", model)
    app.aboutToQuit.connect(model.shutdown)
    try:
        engine.loadData(
            WINDOW_QML.encode("utf-8"),
            QUrl.fromLocalFile(str(PROJECT_ROOT / "modules/ventes/liste_ventes/main.qml")),
        )
        if not engine.rootObjects():
            return 1
        return app.exec()
    finally:
        model.shutdown()
        database.close()


if __name__ == "__main__":
    sys.exit(main())
