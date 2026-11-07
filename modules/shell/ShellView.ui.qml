import QtQuick
import QtQuick.Layouts
import "../../qml/components"
import "../../qml/theme"

Rectangle {
    id: root
    property string companyName: "Atlas Distribution"
    property string userName: "Mohammed"
    property string connectionText: "Hors connexion"
    property bool connected: false
    property bool previewMode: false
    property string currentPage: "dashboard"
    property alias titleBar: titleBar
    property alias menuBar: menuBar
    property alias sidebar: sidebar
    property alias contentFrame: contentFrame
    signal navigationRequested(string page)
    signal quitRequested
    signal minimizeRequested
    signal maximizeRequested

    color: Colors.canvas
    default property alias content: contentFrame.data

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        WindowTitleBar {
            id: titleBar
            dark: true
            title: "AZENZ ERP Desktop v4.2.1 Pro"
            subtitle: root.previewMode ? "| Aperçu des écrans" : ""
            Layout.fillWidth: true
            onCloseRequested: root.quitRequested()
            onMinimizeRequested: root.minimizeRequested()
            onMaximizeRequested: root.maximizeRequested()
        }
        ApplicationMenuBar {
            id: menuBar
            dark: true
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            onCommandTriggered: function (command) {
                if (command === "quit")
                    root.quitRequested();
                else if (command === "sidebar")
                    root.sidebar.collapsed = !root.sidebar.collapsed;
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Sidebar {
                id: sidebar
                companyName: root.companyName
                currentPage: root.currentPage
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                onNavigate: function (page) {
                    root.navigationRequested(page);
                }
            }
            Item {
                id: contentFrame
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
            }
        }
        StatusBar {
            connectionState: root.connected ? "connected" : "disconnected"
            userName: root.userName
            companyName: root.companyName
            Layout.fillWidth: true
        }
    }
}
