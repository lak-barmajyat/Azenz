import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Rectangle {
    id: root
    property string density: "compact"
    property alias sidebar: sidebar
    property alias menuBar: menuBar
    property alias statusBar: statusBar
    property alias contentItem: workspace
    default property alias content: workspace.data
    width: 1440
    height: 900
    color: Colors.canvas
    LayoutMirroring.enabled: Theme.rightToLeft
    LayoutMirroring.childrenInherit: true
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        ApplicationMenuBar {
            id: menuBar
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Sidebar {
                id: sidebar
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
            }
            Item {
                id: workspace
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
            }
        }
        StatusBar {
            id: statusBar
            Layout.fillWidth: true
        }
    }
}
