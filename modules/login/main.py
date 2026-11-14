from __future__ import annotations

import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from database.engine import database
from database.session import setup_session
from modules.login.model import LoginModel
from services.config import load_config
from services.logger import setup_logging
from services.paths import PROJECT_ROOT, QML_DIR


def main() -> int:
    setup_logging()
    database.setup(load_config().database)
    setup_session()
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(QML_DIR))
    login_model = LoginModel(engine)
    engine.rootContext().setContextProperty("loginModel", login_model)
    app.aboutToQuit.connect(login_model.shutdown)
    try:
        engine.load(QUrl.fromLocalFile(str(PROJECT_ROOT / "modules/login/LoginWindow.qml")))
        if not engine.rootObjects():
            return 1
        return app.exec()
    finally:
        login_model.shutdown()
        database.close()


if __name__ == "__main__":
    sys.exit(main())
