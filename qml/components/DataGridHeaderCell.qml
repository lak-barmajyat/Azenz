import QtQuick
import QtQuick.Controls.Basic as C
import "../controls"
import "../theme"

C.AbstractButton {
    id: root
    property string alignment: "left"
    property bool sortable: true
    property string sortDirection: "none"
    property bool resizable: true
    property color headerBackground: Colors.header
    property color headerForeground: Colors.navy
    signal resizeStarted
    signal resizeBy(real delta)
    implicitWidth: 160
    implicitHeight: 32
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    background: Rectangle {
        color: root.hovered ? Qt.darker(root.headerBackground, 1.08) : root.headerBackground
        border.color: root.visualFocus ? Colors.accent : "transparent"
    }
    contentItem: Label {
        text: root.text
        leftPadding: 10
        rightPadding: root.sortable ? 26 : 10
        font.pixelSize: 11
        font.weight: Font.DemiBold
        color: root.headerForeground
        horizontalAlignment: root.alignment === "right" ? Text.AlignRight : root.alignment === "center" ? Text.AlignHCenter : Text.AlignLeft
    }
    Icon {
        anchors.right: parent.right
        anchors.rightMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        name: root.sortDirection === "asc" ? "up" : root.sortDirection === "desc" ? "down" : "sort"
        width: 12
        height: 12
        color: root.sortDirection !== "none" ? Colors.accent : root.headerForeground
        visible: root.sortable
    }
    ColumnResizeHandle {
        anchors.right: parent.right
        height: parent.height
        visible: root.resizable
        onResizeStarted: root.resizeStarted()
        onResizeBy: function (delta) {
            root.resizeBy(delta);
        }
    }
}
