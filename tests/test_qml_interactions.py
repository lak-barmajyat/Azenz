"""Real Qt input tests for selection, sorting, calendar, focus, and overlays.

Run directly with Python (PySide6 required); no database or pytest required.
"""

import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QPA_FONTDIR", str(ROOT / "resources/fonts"))
os.environ.setdefault("QT_QUICK_BACKEND", "software")
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")

from PySide6.QtCore import QPoint, Qt, QUrl, qInstallMessageHandler  # noqa: E402
from PySide6.QtGui import QGuiApplication  # noqa: E402
from PySide6.QtQml import QQmlEngine, QQmlExpression  # noqa: E402
from PySide6.QtQuick import QQuickView  # noqa: E402
from PySide6.QtTest import QTest  # noqa: E402


def main():
    app = QGuiApplication.instance() or QGuiApplication([])
    messages = []
    qInstallMessageHandler(lambda kind, context, message: messages.append(message))
    view = QQuickView()
    view.engine().addImportPath(str(ROOT / "qml"))
    view.setSource(QUrl.fromLocalFile(str(ROOT / "tests/KitHarness.qml")))
    assert view.status() != QQuickView.Error, [e.toString() for e in view.errors()]
    view.show()
    QTest.qWait(150)
    root = view.rootObject()
    context = QQmlEngine.contextForObject(root)

    def js(code):
        expression = QQmlExpression(context, root, code)
        value = expression.evaluate()
        assert not expression.hasError(), expression.error().toString()
        if isinstance(value, tuple):
            value = value[0]
        if hasattr(value, "toVariant"):
            value = value.toVariant()
        app.processEvents()
        return value

    assert js("inherited.height") == 38
    js("scope.density = 'compact'")
    assert js("inherited.height") == 32
    js("dateField.text = '31/02/2026'; dateField.commit()")
    assert js("dateField.validationState") == "error"
    js("dateField.text = '29/02/2024'; dateField.commit()")
    assert js("dateField.validationState") == "default"
    assert js("dateField.hasValue")
    js("dateField.value = new Date(2026, 9, 23)")
    assert js("dateField.text") == "23/10/2026"
    js("dateField.text = ''; dateField.commit()")
    assert not js("dateField.hasValue")
    js("numberField.step(1)")
    assert js("numberField.value") == 7
    js("numberField.value = 20; numberField.step(1)")
    assert js("numberField.value") == 20
    js("combo.choose(1)")
    assert js("combo.currentIndex") == -1
    js("combo.choose(2)")
    assert js("combo.currentValue") == 3
    js("combo.popup.open()")
    QTest.qWait(50)
    for character in "Atlas":
        QTest.keyClick(view, ord(character.upper()))
    assert js("combo.filtered.length") == 1
    QTest.keyClick(view, Qt.Key_Return)
    assert js("combo.currentValue") == 1
    assert not js("combo.popup.visible")

    js("grid.focusRow(0)")
    QTest.keyClick(view, Qt.Key_Down)
    assert js("grid.currentRow") == 1
    assert js("grid.selectionCount") == 0
    QTest.keyClick(view, Qt.Key_Space)
    assert js("grid.selectedIds[0]") == 2
    js("grid.sortColumn = 1; grid.sortDirection = 'asc'")
    assert js("grid.displayRows[0].id") == 2  # Numeric, not lexical sort.
    assert js("grid.selectedIds[0]") == 2  # Selection survives sort.
    js("grid.sortColumn = 2")
    assert js("grid.displayRows[0].id") == 2  # Date crosses year boundary.
    js("grid.toggle(grid.rows[2])")
    assert js("grid.selectionCount") == 1  # Disabled row cannot be selected.
    js("grid.sortColumn = -1; grid.focusRow(0)")
    QTest.keyClick(view, Qt.Key_F10, Qt.ShiftModifier)
    assert js("root.targetId") == 1  # Focus target differs from checked record 2.
    assert js("context.visible")
    QTest.keyClick(view, Qt.Key_Escape)
    assert not js("context.visible")
    js("grid.selectedIds = []")
    QTest.mouseClick(view, Qt.LeftButton, Qt.ControlModifier, QPoint(180, 246))
    assert js("grid.selectedIds[0]") == 1
    QTest.mouseClick(view, Qt.LeftButton, Qt.ShiftModifier, QPoint(180, 274))
    assert js("grid.selectionCount") == 2
    js("grid.selectedIds = [2]")
    # Actual pointer targeting and resize, not only method calls.
    QTest.mouseClick(view, Qt.RightButton, Qt.NoModifier, QPoint(180, 246))
    assert js("root.targetId") == 1
    QTest.keyClick(view, Qt.Key_Escape)
    QTest.mousePress(view, Qt.LeftButton, Qt.NoModifier, QPoint(355, 216))
    QTest.mouseMove(view, QPoint(405, 216), 25)
    QTest.mouseRelease(view, Qt.LeftButton, Qt.NoModifier, QPoint(405, 216))
    assert js("grid.columns[0].width") > 300
    js("grid.rows = [grid.rows[0]]")
    assert js("grid.selectionCount") == 0  # Removed selection is reconciled.
    for state in ("loading", "empty", "error", "default"):
        js(f"grid.viewState = '{state}'")
        QTest.qWait(20)

    QTest.mouseClick(view, Qt.LeftButton, Qt.NoModifier, QPoint(80, 36))
    QTest.qWait(50)
    assert js("dialog.visible")
    assert js("root.Window.window.activeFocusItem.text") == "Annuler"
    QTest.keyClick(view, Qt.Key_Return)
    QTest.qWait(50)
    assert js("root.acceptedCount") == 0
    assert js("root.rejectedCount") == 1
    assert js("trigger.activeFocus")
    js("dialog.open()")
    QTest.qWait(50)
    for _ in range(8):
        QTest.keyClick(view, Qt.Key_Tab)
        assert js("root.Window.window.activeFocusItem.text") in ("Annuler", "Supprimer", "")
    QTest.keyClick(view, Qt.Key_Escape)
    assert not js("dialog.visible")
    js("calendar.selectedDate = new Date(2024, 1, 29); calendar.open()")
    QTest.qWait(50)
    QTest.keyClick(view, Qt.Key_Right)
    assert js("calendar.focusedDate.getMonth()") == 2
    assert js("calendar.focusedDate.getDate()") == 1
    QTest.keyClick(view, Qt.Key_Escape)
    assert not js("calendar.visible")
    js("for (var i=0; i<6; ++i) toasts.show('Notice', 'Test', 'warning')")
    assert js("toasts.notifications.length") == 6
    assert js("toasts.children.length") == 5  # Repeater plus four visible toasts.
    js("toasts.dismiss(0)")
    assert js("toasts.notifications[0].id") == 0  # Retained during exit animation.
    QTest.qWait(250)
    assert js("toasts.notifications[0].id") == 1
    js("for (var i=1; i<6; ++i) toasts.dismiss(i)")
    QTest.qWait(300)
    assert js("toasts.notifications.length") == 0
    js("toasts.duration = 120; toasts.show('Timed notice', 'Animation test', 'info')")
    QTest.qWait(100)
    assert js("toasts.notifications.length") == 1
    QTest.qWait(650)
    assert js("toasts.notifications.length") == 0
    assert not messages, "\n".join(messages)
    print(
        "PASS: density, dates, numeric input, searchable selection, grid keyboard/pointer/resize, "
        "sorting, dialog focus, calendar and toast queue"
    )


if __name__ == "__main__":
    main()
