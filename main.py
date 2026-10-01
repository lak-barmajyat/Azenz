import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from services.bootstrap import StartupCancelled, bootstrap_application
from services.logger import get_logger
from services.paths import PROJECT_ROOT, QML_DIR


def confirm_database_creation(database_name: str) -> bool:
    """Temporary confirmation until the QML setup dialog is implemented."""
    answer = input(
        f"Database '{database_name}' does not exist. "
        "Do you want to create it? [y/N]: "
    )

    return answer.strip().lower() in {"y", "yes"}


def main() -> int:
    app = QGuiApplication(sys.argv)

    app.setApplicationName("Azenz")
    app.setOrganizationName("LakSoftware")

    try:
        config = bootstrap_application(
            confirm_database_creation=confirm_database_creation
        )
    except StartupCancelled:
        logger = get_logger(__name__)
        logger.info("Azenz startup cancelled")
        return 0

    logger = get_logger(__name__)
    logger.info(
        "Starting Azenz UI | environment=%s",
        config.environment,
    )

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