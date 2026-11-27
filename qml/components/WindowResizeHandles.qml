import QtQuick

Item {
    id: root
    property var targetWindow: null
    readonly property bool resizable: targetWindow !== null && targetWindow.visibility === Window.Windowed
    visible: resizable
    z: 1000

    MouseArea {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: 12; bottomMargin: 12 }
        width: 6
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed: root.targetWindow.startSystemResize(Qt.LeftEdge)
    }
    MouseArea {
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: 12; bottomMargin: 12 }
        width: 6
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed: root.targetWindow.startSystemResize(Qt.RightEdge)
    }
    MouseArea {
        anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 12; rightMargin: 12 }
        height: 6
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed: root.targetWindow.startSystemResize(Qt.TopEdge)
    }
    MouseArea {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 12; rightMargin: 12 }
        height: 6
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed: root.targetWindow.startSystemResize(Qt.BottomEdge)
    }
    MouseArea {
        anchors { left: parent.left; top: parent.top }
        width: 12; height: 12
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.targetWindow.startSystemResize(Qt.LeftEdge | Qt.TopEdge)
    }
    MouseArea {
        anchors { right: parent.right; top: parent.top }
        width: 12; height: 12
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.targetWindow.startSystemResize(Qt.RightEdge | Qt.TopEdge)
    }
    MouseArea {
        anchors { left: parent.left; bottom: parent.bottom }
        width: 12; height: 12
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.targetWindow.startSystemResize(Qt.LeftEdge | Qt.BottomEdge)
    }
    MouseArea {
        anchors { right: parent.right; bottom: parent.bottom }
        width: 12; height: 12
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.targetWindow.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
    }
}
