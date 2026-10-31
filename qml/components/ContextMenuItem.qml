import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../controls"
import "../theme"

C.MenuItem {
    id: root
    property string iconName: ""
    property string shortcutText: ""
    property bool destructive: false
    implicitHeight: 28
    implicitWidth: 244
    leftPadding: 12
    rightPadding: 12
    hoverEnabled: true
    indicator: Item {}
    arrow: Icon {
        name: "right"
        visible: root.subMenu !== null
        x: root.width - width - 8
        y: (root.height - height) / 2
        width: 14
        height: 14
    }
    contentItem: RowLayout {
        spacing: 8
        Icon {
            name: root.checked ? "check" : root.iconName || "info"
            visible: root.iconName !== "" || root.checkable
            color: root.destructive ? Colors.danger : Colors.textSecondary
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }
        Label {
            text: root.text
            Layout.fillWidth: true
            font.pixelSize: 12
            color: !root.enabled ? Colors.disabledText : root.destructive ? Colors.danger : Colors.text
        }
        Label {
            text: root.shortcutText
            font.pixelSize: 11
            color: Colors.textSecondary
            visible: !root.subMenu
        }
    }
    background: Rectangle {
        radius: 3
        color: root.highlighted || root.hovered ? root.destructive ? Colors.tint("danger") : Colors.rowHover : "transparent"
        border.color: root.visualFocus ? Colors.accent : "transparent"
        border.width: 2
    }
}
