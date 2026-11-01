from __future__ import annotations

import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from modules.login.model import LoginModel
from services.paths import PROJECT_ROOT, QML_DIR


def main() -> int:
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(QML_DIR))

    login_model = LoginModel(engine)
    engine.load(QUrl.fromLocalFile(str(PROJECT_ROOT / "modules" / "login" / "Login.qml")))
    if not engine.rootObjects():
        return 1

    login = engine.rootObjects()[0]
    login.loginRequested.connect(login_model.authenticate)
    login_model.authenticationCompleted.connect(
        lambda success, message, username: login.completeAuthentication(success, message)
    )
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())