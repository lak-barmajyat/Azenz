"""Compile and instantiate every UI-kit component with Qt, without the database.

Run: python tests/validate_qml.py
Optional screenshots: python tests/validate_qml.py --render
"""

import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_BACKEND", "software")
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
os.environ.setdefault(
    "QT_QPA_FONTDIR", str(Path(__file__).resolve().parents[1] / "resources/fonts")
)

from PySide6.QtCore import QUrl, qInstallMessageHandler
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine
from PySide6.QtQuick import QQuickView
from PySide6.QtTest import QTest

ROOT = Path(__file__).resolve().parents[1]
app = QGuiApplication.instance() or QGuiApplication([])
engine = QQmlEngine()
engine.addImportPath(str(ROOT / "qml"))
messages = []
qInstallMessageHandler(lambda kind, context, message: messages.append(message))
failures = []
# Verify the same named imports used by Design Studio's component-library entries.
probe = QQmlComponent(engine)
probe.setData(
    b"""import QtQuick
import controls 1.0
import components 1.0
import layouts 1.0
Item { AzenzButton { text: "Import check" } Badge {} DensityScope {} }
""",
    QUrl.fromLocalFile(str(ROOT / "qml/ImportCheck.qml")),
)
import_object = probe.create()
if import_object is None:
    failures += [error.toString() for error in probe.errors()]
else:
    import_object.deleteLater()
files = []
for folder in ("controls", "components", "layouts"):
    files.extend(sorted((ROOT / "qml" / folder).glob("*.qml")))
for file in files:
    if "pragma Singleton" in file.read_text(encoding="utf-8"):
        continue
    component = QQmlComponent(engine, QUrl.fromLocalFile(str(file)))
    if component.isError():
        failures.append(f"{file.name}: " + "\n".join(e.toString() for e in component.errors()))
        continue
    obj = component.create()
    if obj is None:
        failures.append(f"{file.name}: " + "\n".join(e.toString() for e in component.errors()))
    else:
        obj.deleteLater()
    app.processEvents()

preview = ROOT / "qml/gallery/ComponentGallery.qml"
if preview.exists():
    view = QQuickView()
    view.engine().addImportPath(str(ROOT / "qml"))
    view.setResizeMode(QQuickView.SizeRootObjectToView)
    view.setSource(QUrl.fromLocalFile(str(preview)))
    if view.status() == QQuickView.Error:
        failures += [e.toString() for e in view.errors()]
    else:
        view.resize(1440, 1000)
        view.show()
        QTest.qWait(400)
        if "--render" in sys.argv:
            output = ROOT / "build/qml-preview"
            output.mkdir(parents=True, exist_ok=True)
            for index, name in enumerate(
                ["controls", "navigation", "tables", "feedback", "foundations"]
            ):
                view.rootObject().setProperty("pageIndex", index)
                QTest.qWait(250)
                view.grabWindow().save(str(output / f"{name}.png"))
            print(f"Screenshots: {output}")

failures.extend(messages)
for failure in failures:
    print(failure)
print(f"Validated {len(files)} component files; {len(failures)} errors/warnings.")
sys.exit(bool(failures))
