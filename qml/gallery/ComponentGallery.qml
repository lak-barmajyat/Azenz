pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../controls"
import "../components"
import "../theme"

Rectangle {
    id: root
    property int pageIndex: 0
    property string density: "compact"
    width: 1440
    height: 1000
    color: Colors.canvas
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Colors.navy
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                Logo {
                    variant: "dark"
                    Layout.preferredWidth: 112
                    Layout.preferredHeight: 40
                }
                ColumnLayout {
                    spacing: 2
                    Label {
                        text: "AZENZ ERP · Component Library"
                        color: "white"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }
                    Label {
                        text: "Qt Quick / Qt Design Studio · Fluent Industrial Desktop"
                        color: "#CBD5E1"
                        font.pixelSize: 12
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                AzenzButton {
                    text: root.density === "compact" ? "Compact" : "Confortable"
                    variant: "secondary"
                    onClicked: root.density = root.density === "compact" ? "comfortable" : "compact"
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "white"
            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Repeater {
                    model: ["Boutons & Inputs", "Navigation", "Grilles & Menus", "Feedback & États", "Fondations"]
                    AzenzButton {
                        required property string modelData
                        required property int index
                        text: modelData
                        variant: root.pageIndex === index ? "primary" : "ghost"
                        onClicked: root.pageIndex = index
                    }
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Colors.border
            }
        }
        C.ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            C.ScrollBar.vertical: AzenzScrollBar {
                parent: scroll
                x: scroll.width - width
                y: 0
                height: scroll.height
            }
            C.ScrollBar.horizontal.policy: C.ScrollBar.AlwaysOff
            Item {
                width: scroll.availableWidth
                implicitHeight: loader.implicitHeight + 48
                Loader {
                    id: loader
                    x: 24
                    y: 24
                    width: parent.width - 48
                    source: ["ControlsPage.qml", "NavigationPage.qml", "TablesPage.qml", "FeedbackPage.qml", "FoundationsPage.qml"][root.pageIndex]
                    Connections {
                        target: loader.item
                        ignoreUnknownSignals: true
                        function onNotify(title, message) {
                            notifications.show(title, message);
                        }
                    }
                }
            }
        }
        StatusBar {
            Layout.fillWidth: true
            companyName: "AZENZ · Design System Preview"
        }
    }
    ToastHost {
        id: notifications
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        anchors.topMargin: 148
    }
}
