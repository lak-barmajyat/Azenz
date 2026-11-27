from __future__ import annotations

import sys
from pathlib import Path

if not __package__:
    sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from database.engine import database
from database.session import setup_session
from modules.stockage.nouveau_document.model import NouveauDocumentModel
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
    title: qsTr("Azenz — Document de stock")

    NouveauDocument {
        anchors.fill: parent
        onBackRequested: Qt.quit()
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
    model = NouveauDocumentModel(engine)
    engine.rootContext().setContextProperty("nouveauDocumentModel", model)
    app.aboutToQuit.connect(model.shutdown)
    engine.loadData(
        WINDOW_QML.encode("utf-8"),
        QUrl.fromLocalFile(str(PROJECT_ROOT / "modules/stockage/nouveau_document/main.qml")),
    )
    if not engine.rootObjects():
        return 1
    try:
        return app.exec()
    finally:
        model.shutdown()
        database.close()


if __name__ == "__main__":
    sys.exit(main())
