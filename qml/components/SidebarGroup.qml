import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

ColumnLayout {
    id: root
    property string title: "DOCUMENTS"
    property bool expanded: true
    property bool collapsed: false
    default property alias entries: entries.data
    spacing: 2
    SidebarItem {
        text: root.title
        iconName: "right"
        iconRotation: root.expanded ? 90 : 0
        visible: !root.collapsed
        Layout.fillWidth: true
        implicitHeight: 28
        onClicked: root.expanded = !root.expanded
    }
    Item {
        id: container
        Layout.fillWidth: true
        implicitHeight: root.expanded || root.collapsed ? entries.implicitHeight : 0
        visible: implicitHeight > 0
        clip: true
        enabled: root.expanded || root.collapsed
        opacity: root.expanded || root.collapsed ? 1 : 0
        Behavior on implicitHeight { NumberAnimation { duration: 220; easing.type: Easing.InOutCubic } }
        Behavior on opacity { NumberAnimation { duration: 160 } }
        ColumnLayout {
            id: entries
            width: parent.width
            spacing: 2
        }
    }
}
