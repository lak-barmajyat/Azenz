import QtQuick
import QtQuick.Controls.Basic as C
import "../controls"
import "../theme"

C.AbstractButton {
    id: root
    property string iconName: "folder"
    property bool active: false
    property bool collapsed: false
    property real iconRotation: 0
    implicitWidth: collapsed ? 40 : 208
    implicitHeight: 36
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    clip: true
    Accessible.name: text
    Keys.onReturnPressed: clicked()
    background: Rectangle {
        radius: 4
        color: root.active ? Colors.accent : root.hovered ? Colors.navHover : "transparent"
        border.color: root.visualFocus ? Colors.accent : "transparent"
        border.width: 2
        Behavior on color { ColorAnimation { duration: 140 } }
    }
    contentItem: Item {
        Icon {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            color: root.enabled ? "white" : "#66788A"
            width: 18
            height: 18
            rotation: root.iconRotation
            Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }
        }
        Label {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            opacity: root.collapsed ? 0 : 1
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            color: root.enabled ? "#E2E8F0" : "#66788A"
            font.pixelSize: 12
        }
    }
    AzenzToolTip {
        text: root.text
        placement: "right"
        visible: root.collapsed && (root.hovered || root.visualFocus) && !root.down
    }
}
