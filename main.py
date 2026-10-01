import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from services.logger import get_logger, setup_logging
from services.paths import PROJECT_ROOT, QML_DIR


def main() -> int:
    app = QGuiApplication(sys.argv)

    app.setApplicationName("Azenz")
    app.setOrganizationName("LakSoftware")

    setup_logging()
    logger = get_logger(__name__)

    logger.info("Starting Azenz")

    engine = QQmlApplicationEngine()

    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(QML_DIR))

    qml_file = QML_DIR / "App.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        logger.critical("Failed to load App.qml")
        return 1

    logger.info("Azenz started successfully")

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
