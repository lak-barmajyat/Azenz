import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.CheckBox {
    id: root
    property string density: Theme.densityFor(parent)
    implicitHeight: Theme.controlHeight(density)
    spacing: 8
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    indicator: Rectangle {
        x: root.mirrored ? root.width - width : 0
        y: (root.height - height) / 2
        width: 16
        height: 16
        radius: 3
        color: !root.enabled ? Colors.disabled : root.checkState !== Qt.Unchecked ? Colors.accent : root.hovered ? Colors.canvas : "white"
        border.color: !root.enabled ? Colors.borderStrong : root.checkState !== Qt.Unchecked ? Colors.accent : Colors.borderStrong
        Icon {
            anchors.centerIn: parent
            width: 12
            height: 12
            name: root.checkState === Qt.PartiallyChecked ? "minus" : "check"
            color: root.enabled ? "white" : Colors.disabledText
            visible: root.checkState !== Qt.Unchecked
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            color: "transparent"
            border.color: Colors.accent
            border.width: 2
            radius: 5
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
