"""Exercise sales date fields through actual ApplicationWindow mouse/keyboard input."""
import os
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_BACKEND", "software")
os.environ.setdefault("QT_QPA_FONTDIR", str(Path(__file__).resolve().parents[1] / "resources/fonts"))
from PySide6.QtCore import QPoint, Qt, QUrl, qInstallMessageHandler
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QQmlExpression, QQmlEngine
from PySide6.QtTest import QTest

ROOT = Path(__file__).resolve().parents[1]
app = QGuiApplication([])
messages = []
qInstallMessageHandler(lambda kind, context, message: messages.append(message))
engine = QQmlApplicationEngine()
engine.addImportPath(str(ROOT / "qml"))
engine.load(QUrl.fromLocalFile(str(ROOT / "qml/App.qml")))
window = engine.rootObjects()[0]
scope = QQmlEngine.contextForObject(window)

def js(code):
    expression = QQmlExpression(scope, window, code)
    value = expression.evaluate()
    assert not expression.hasError(), expression.error().toString()
    value = value[0] if isinstance(value, tuple) else value
    app.processEvents()
    return value.toVariant() if hasattr(value, "toVariant") else value

def click(point):
    QTest.mouseClick(window, Qt.LeftButton, Qt.NoModifier,
                     QPoint(round(point.x()), round(point.y())))
    QTest.qWait(80)

js("app.signedIn = true")
for width, height in [(1600, 1000), (1200, 700)]:
    window.resize(width, height)
    QTest.qWait(150)
    for field in ["fromDate", "toDate"]:
        f = f"sales.{field}"
        js("sales.resetFilters()")
        click(js(f"{f}.mapToItem(null, {f}.width - 15, {f}.height / 2)"))
        assert js(f"{f}.calendarPopup.visible && {f}.calendarPopup.activeFocus")
        # Click an actual day button, rather than invoking choose() directly.
        point = js(f"""(function() {{
            function find(item) {{
                if (item.day !== undefined && item.day.getDate() === 10
                    && item.day.getMonth() === {f}.calendarPopup.month)
                    return item.mapToItem(null, item.width / 2, item.height / 2);
                for (var i = 0; i < item.children.length; ++i) {{
                    var result = find(item.children[i]);
                    if (result) return result;
                }}
                return null;
            }}
            return find({f}.calendarPopup.contentItem);
        }})()""")
        click(point)
        assert js(f"{f}.hasValue && !{f}.calendarPopup.visible && {f}.value.getDate() === 10")
        js(f"{f}.forceActiveFocus(); {f}.selectAll()")
        for character in "11/02/2021":
            QTest.keyClick(window, Qt.Key(ord(character)))
        click(js(f"{f}.mapToItem(null, {f}.width - 15, {f}.height / 2)"))
        assert js(f"{f}.calendarPopup.year === 2021 && {f}.calendarPopup.month === 1")
        assert js(f"{f}.calendarPopup.selectedDate.getDate() === 11")
        QTest.keyClick(window, Qt.Key_Escape)
        js(f"{f}.forceActiveFocus(); {f}.selectAll()")
        QTest.keyClick(window, Qt.Key_Backspace)
        QTest.keyClick(window, Qt.Key_Tab)
        QTest.qWait(50)
        assert js(f"!{f}.hasValue && {f}.text === ''")
        key = "from" if field == "fromDate" else "to"
        assert js(f"sales.appliedFilters.{key} === null"), "Clearing must remove the active date filter"

assert not messages, "\n".join(messages)
print("PASS: both sales dates open/select by mouse, resync after typing, and clear filters at both window sizes")
window.close()
