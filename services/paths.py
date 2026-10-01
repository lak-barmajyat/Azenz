from pathlib import Path

from PySide6.QtCore import QStandardPaths


PROJECT_ROOT = Path(__file__).resolve().parents[1]

QML_DIR = PROJECT_ROOT / "qml"
MODULES_DIR = PROJECT_ROOT / "modules"

RESOURCES_DIR = PROJECT_ROOT / "resources"
ICONS_DIR = RESOURCES_DIR / "icons"
IMAGES_DIR = RESOURCES_DIR / "images"

I18N_DIR = PROJECT_ROOT / "i18n"


def app_data_dir() -> Path:
    """Return the writable OS-specific Azenz data directory."""
    path = Path(
        QStandardPaths.writableLocation(
            QStandardPaths.StandardLocation.AppLocalDataLocation
        )
    )

    path.mkdir(parents=True, exist_ok=True)
    return path


def logs_dir() -> Path:
    path = app_data_dir() / "logs"
    path.mkdir(parents=True, exist_ok=True)
    return path

if __name__ == "__main__":
    print(app_data_dir())
