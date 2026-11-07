import QtQuick

Item {
    property bool collapsed: false
    implicitHeight: 56
    implicitWidth: collapsed ? 56 : 224
    Logo {
        anchors.centerIn: parent
        width: parent.collapsed ? 28 : 112
        height: 28
        variant: parent.collapsed ? "symbol" : "dark"
        opacity: 0.23
    }
}
