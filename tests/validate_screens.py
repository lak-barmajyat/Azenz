"""Compile, render, and exercise both HTML-derived screens without a database."""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QPA_FONTDIR", str(ROOT / "resources/fonts"))
os.environ.setdefault("QT_QUICK_BACKEND", "software")
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")

from PySide6.QtCore import QPoint, Qt, QUrl, qInstallMessageHandler
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine, QQmlExpression, QQmlComponent
from PySide6.QtQuick import QQuickView
from PySide6.QtTest import QTest

app = QGuiApplication([])
messages = []
qInstallMessageHandler(lambda kind, context, message: messages.append(message))
view = QQuickView()
view.engine().addImportPath(str(ROOT / "qml"))
view.setResizeMode(QQuickView.SizeRootObjectToView)
view.setSource(QUrl.fromLocalFile(str(ROOT / "qml/screens/ScreensPreview.qml")))
assert view.status() != QQuickView.Error, '\n'.join(e.toString() for e in view.errors())
view.resize(1600, 1000)
view.show()
QTest.qWait(250)
root = view.rootObject()
context = QQmlEngine.contextForObject(root)

def js(code):
    expression = QQmlExpression(context, root, code)
    value = expression.evaluate()
    assert not expression.hasError(), expression.error().toString()
    value = value[0] if isinstance(value, tuple) else value
    app.processEvents()
    return value.toVariant() if hasattr(value, "toVariant") else value

def wait_sidebar_width(expected):
    # Animation frame scheduling can take longer on a busy/offscreen renderer.
    for _ in range(30):
        if abs(js("sales.sidebar.width") - expected) < 0.01:
            return
        QTest.qWait(50)
    raise AssertionError(f"Sidebar did not settle at {expected}")

output = ROOT / "build/screens-preview"
output.mkdir(parents=True, exist_ok=True)
view.grabWindow().save(str(output / "login.png"))
js("login.submit()")
assert js("root.screen") == "login"
assert js("login.errorMessage.length") > 0
js("login.username = 'preview'; login.password = 'not-a-real-password'; login.submit()")
assert js("root.screen") == "sales"
assert js("login.password") == ""
assert js("sales.records.length") == 15
assert js("sales.totalHT") == 216100
assert js("sales.totalTTC") == 259320
QTest.qWait(150)
view.grabWindow().save(str(output / "sales.png"))
for field in ("fromDate", "toDate"):
    point = js(f"sales.{field}.mapToItem(null, sales.{field}.width - 15, sales.{field}.height / 2)")
    QTest.mouseClick(view, Qt.LeftButton, Qt.NoModifier, QPoint(round(point.x()), round(point.y())))
    QTest.qWait(100)
    assert js(f"sales.{field}.calendarPopup.visible"), f"{field} calendar did not open from its icon"
    assert js(f"sales.{field}.calendarPopup.activeFocus"), "Calendar must retain keyboard focus"
    QTest.keyClick(view, Qt.Key_Escape)
    assert not js(f"sales.{field}.calendarPopup.visible")
    js(f"sales.{field}.forceActiveFocus()")
    QTest.keyClick(view, Qt.Key_Down)
    QTest.qWait(50)
    assert js(f"sales.{field}.calendarPopup.visible")
    QTest.keyClick(view, Qt.Key_Return)
    assert js(f"sales.{field}.hasValue")
    assert not js(f"sales.{field}.calendarPopup.visible")
    js("sales.resetFilters()")
js("sales.codeFilter.text = 'DV-001'")
assert js("sales.records.length") == 1
assert js("sales.totalHT") == 14250
js("sales.resetFilters(); sales.typeFilter.currentIndex = 2; sales.applyFilters()")
assert js("sales.records.length") == 3
js("sales.resetFilters(); sales.fromDate.text = '11/01/2020'; sales.applyFilters()")
assert js("sales.records.length") == 2
js("sales.toDate.text = '10/01/2020'; sales.applyFilters()")
assert js("sales.filterError.length") > 0
assert js("sales.records.length") == 2  # Invalid range does not silently change the result.
js("sales.resetFilters(); sales.codeFilter.text = 'does-not-exist'")
assert js("sales.records.length") == 0
QTest.qWait(50)
view.grabWindow().save(str(output / "sales-empty.png"))
js("sales.resetFilters(); sales.grid.focusRow(0)")
QTest.keyClick(view, Qt.Key_Space)
assert js("sales.grid.selectionCount") == 1
assert js("sales.editButton.enabled")
js("sales.requestAction('delete')")
QTest.qWait(30)
QTest.keyClick(view, Qt.Key_Escape)
assert js("sales.sourceRows.length") == 15
js("sales.sidebar.collapsed = true")
QTest.qWait(80)
assert 64 < js("sales.sidebar.width") < 256, "Sidebar should animate through intermediate widths"
view.resize(1280, 720)
QTest.qWait(300)
wait_sidebar_width(64)
view.grabWindow().save(str(output / "sales-compact.png"))
js("sales.sidebar.collapsed = false")
QTest.qWait(300)
wait_sidebar_width(256)
# Reversing a transition must finish at the latest requested state.
js("sales.sidebar.collapsed = true")
QTest.qWait(60)
js("sales.sidebar.collapsed = false")
QTest.qWait(300)
wait_sidebar_width(256)
view.grabWindow().save(str(output / "sales-small-expanded.png"))
js("root.screen = 'login'; login.language = 'ar'; login.errorMessage = ''")
QTest.qWait(100)
view.grabWindow().save(str(output / "login-arabic.png"))
js("login.language = 'en'")
assert js("login.copy.heading") == "Sign in"

# Compile both actual window entry points too.
for path in ["qml/screens/App.qml", "qml/App.qml"]:
    component = QQmlComponent(view.engine(), QUrl.fromLocalFile(str(ROOT / path)))
    assert not component.isError(), '\n'.join(e.toString() for e in component.errors())
    window = component.createWithInitialProperties({"visible": False})
    assert window is not None, '\n'.join(e.toString() for e in component.errors())
    if path == "qml/App.qml":
        scope = QQmlEngine.contextForObject(window)
        attempt = QQmlExpression(scope, window, "login.username = 'unverified'; login.password = 'anything'; login.submit()")
        attempt.evaluate()
        assert not attempt.hasError(), attempt.error().toString()
        assert not window.property("signedIn"), "Production must not use the preview authentication bypass"
        denied = QQmlExpression(scope, window, "login.errorMessage.length > 0 && login.password === '' && !login.busy")
        assert denied.evaluate()[0]
    window.deleteLater()

assert not messages, '\n'.join(messages)
print("PASS: both screens compile/render; login validation, preview navigation, language, filters, totals, selection and cancel tested.")
print(f"Screenshots: {output}")
