"""Preview the two HTML-derived QML screens, without authentication or a database.

python preview_screens.py          # Login, then demo navigation to ventes
python preview_screens.py --ventes  # Ventes directly
"""

import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


def main():
    app = QGuiApplication(sys.argv)
    root = Path(__file__).resolve().parent
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(root / "qml"))
    engine.load(QUrl.fromLocalFile(str(root / "qml/screens/App.qml")))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
