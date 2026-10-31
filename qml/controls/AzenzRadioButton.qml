import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.RadioButton {
    id: root
    property string density: Theme.densityFor(parent)
    implicitHeight: Theme.controlHeight(density)
    padding: 0
    spacing: 8
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    indicator: Rectangle {
        x: root.mirrored ? root.width - width : 0
        y: (root.height - height) / 2
        width: 16
        height: 16
        radius: 8
        color: root.enabled ? "white" : Colors.disabled
        border.color: root.checked ? Colors.accent : root.hovered ? Colors.navy : Colors.borderStrong
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: root.enabled ? Colors.accent : Colors.disabledText
            visible: root.checked
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 11
            color: "transparent"
            border.color: Colors.accent
            border.width: 2
            visible: root.visualFocus
        }
    }
    contentItem: Label {
        text: root.text
        leftPadding: root.mirrored ? 0 : 24
        rightPadding: root.mirrored ? 24 : 0
        color: root.enabled ? Colors.text : Colors.disabledText
        font.pixelSize: 12
    }
}
