import QtQuick
import "../theme"

MouseArea {
    id: root
    property real startX: 0
    signal resizeStarted
    signal resizeBy(real delta)
    implicitWidth: 7
    hoverEnabled: true
    cursorShape: Qt.SplitHCursor
    onPressed: function (mouse) {
        startX = mapToItem(null, mouse.x, 0).x;
        resizeStarted();
    }
    onPositionChanged: function (mouse) {
        if (pressed)
            resizeBy(mapToItem(null, mouse.x, 0).x - startX);
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1
        height: parent.height
        color: root.pressed ? Colors.navy : root.containsMouse ? Colors.accent : Colors.borderStrong
    }
}
