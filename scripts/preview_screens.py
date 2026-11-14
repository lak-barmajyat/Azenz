"""Preview the two HTML-derived QML screens, without authentication or a database.

python -m scripts.preview_screens          # Login, then demo navigation to ventes
python -m scripts.preview_screens --ventes  # Ventes directly
"""

import os
import sys

os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from modules.ventes.liste_ventes.model import ListeVentesModel
from services.paths import PROJECT_ROOT


def main():
    app = QGuiApplication(sys.argv)
    root = PROJECT_ROOT
    engine = QQmlApplicationEngine()
    model = ListeVentesModel(engine, preview=True)
    engine.rootContext().setContextProperty("listeVentesModel", model)
    engine.addImportPath(str(root / "qml"))
    engine.load(QUrl.fromLocalFile(str(root / "qml/screens/App.qml")))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
