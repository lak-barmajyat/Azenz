import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.Switch {
    id: root
    property string density: Theme.densityFor(parent)
    implicitHeight: Theme.controlHeight(density)
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    indicator: Rectangle {
        x: root.mirrored ? root.width - width : 0
        y: (root.height - height) / 2
        width: 32
        height: 18
        radius: 9
        color: !root.enabled ? Colors.disabled : root.checked ? (root.hovered ? Colors.accentHover : Colors.accent) : root.hovered ? Colors.borderStrong : "#E2E8F0"
        Rectangle {
            x: 2 + root.visualPosition * 14
            y: 2
            width: 14
            height: 14
            radius: 7
            color: root.enabled ? "white" : Colors.borderStrong
            Behavior on x {
                enabled: !Theme.reducedMotion
                NumberAnimation {
                    duration: 100
                }
            }
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 12
            color: "transparent"
            border.color: Colors.accent
            border.width: 2
            visible: root.visualFocus
        }
    }
    contentItem: Label {
        text: root.text
        leftPadding: root.mirrored ? 0 : 40
        rightPadding: root.mirrored ? 40 : 0
        color: root.enabled ? Colors.text : Colors.disabledText
        font.pixelSize: 12
    }
}
