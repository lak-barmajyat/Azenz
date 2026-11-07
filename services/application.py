"""Qt objects stay alive here until the application event loop finishes."""

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from modules.login.model import LoginModel
from services.logger import get_logger
from services.paths import PROJECT_ROOT, QML_DIR


def run_application(argv: list[str]) -> int:
    app = QGuiApplication(argv)
    app.setApplicationName("Azenz")
    app.setOrganizationName("LakSoftware")
    engine = QQmlApplicationEngine()
    model = LoginModel(engine)
    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(QML_DIR))
    engine.setInitialProperties({"authModel": model, "authenticationAvailable": True})
    engine.load(QUrl.fromLocalFile(str(QML_DIR / "App.qml")))
    if not engine.rootObjects():
        raise RuntimeError("Unable to load the application UI")
    get_logger(__name__).info("Azenz started successfully")
    return app.exec()
