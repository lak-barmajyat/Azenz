import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.ScrollBar {
    id: root
    padding: 1
    hoverEnabled: true
    minimumSize: 0.05
    contentItem: Rectangle {
        implicitWidth: 6
        implicitHeight: 6
        radius: 3
        color: root.pressed ? Colors.navy : root.hovered ? "#94A3B8" : Colors.borderStrong
        opacity: root.size < 1 ? 1 : 0
    }
    background: Rectangle {
        implicitWidth: 8
        implicitHeight: 8
        color: Colors.canvas
    }
}
