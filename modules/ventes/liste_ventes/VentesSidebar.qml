pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../../../qml/controls"
import "../../../qml/components"
import "../../../qml/theme"

Rectangle {
    id: root
    property bool collapsed: false
    property string companyName: "Atlas Distribution"
    property string branch: "Casablanca • Négoce"
    property string userName: "Mohammed"
    property string userRole: "Admin"
    signal navigate(string page)
    implicitWidth: collapsed ? 64 : 256
    implicitHeight: 800
    clip: true
    Behavior on implicitWidth { NumberAnimation { duration: 240; easing.type: Easing.InOutCubic } }
    color: Colors.navy
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.collapsed ? 72 : 112
            Behavior on Layout.preferredHeight { NumberAnimation { duration: 240; easing.type: Easing.InOutCubic } }
            color: "#0D2A45"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.collapsed ? 12 : 16
                spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        border.color: Colors.accent
                        border.width: 2
                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: "#984700"
                            }
                            GradientStop {
                                position: 1
                                color: "#413625"
                            }
                        }
                        Label {
                            anchors.centerIn: parent
                            text: "AD"
                            color: "white"
                            font.weight: Font.Bold
                        }
                    }
                    ColumnLayout {
                        visible: !root.collapsed
                        Layout.fillWidth: true
                        spacing: 4
                        Label {
                            text: root.companyName
                            font.pixelSize: 13
                            color: "white"
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                        Label {
                            text: root.branch
                            color: "#CBD5E1"
                            font.pixelSize: 10
                            Layout.fillWidth: true
                        }
                    }
                    Badge {
                        visible: !root.collapsed
                        text: "SARL"
                        variant: "warning"
                        radius: 3
                        implicitHeight: 16
                    }
                }
                RowLayout {
                    visible: !root.collapsed
                    Layout.fillWidth: true
                    spacing: 5
                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: Colors.success
                    }
                    Label {
                        text: root.userName + " • " + root.userRole
                        color: "#CBD5E1"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                    }
                    Label {
                        text: "CL-ATLAS"
                        color: "#94A3B8"
                        font.pixelSize: 9
                    }
                }
            }
        }
        C.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            C.ScrollBar.horizontal.policy: C.ScrollBar.AlwaysOff
            ColumnLayout {
                width: parent.width
                spacing: 12
                SidebarItem {
                    text: "Dashboard"
                    iconName: "dashboard"
                    collapsed: root.collapsed
                    Layout.fillWidth: true
                    Layout.margins: 8
                    onClicked: root.navigate("dashboard")
                }
                Repeater {
                    model: [
                        {
                            title: "DOCUMENTS",
                            items: [
                                {
                                    text: "Ventes",
                                    key: "sales",
                                    icon: "sales"
                                },
                                {
                                    text: "Achats",
                                    key: "purchases",
                                    icon: "cart"
                                },
                                {
                                    text: "Stockage",
                                    key: "stock",
                                    icon: "warehouse"
                                }
                            ]
                        },
                        {
                            title: "TIERS",
                            items: [
                                {
                                    text: "Clients",
                                    key: "clients",
                                    icon: "users"
                                },
                                {
                                    text: "Fournisseurs",
                                    key: "suppliers",
                                    icon: "truck"
                                }
                            ]
                        },
                        {
                            title: "CATALOGUE",
                            items: [
                                {
                                    text: "Articles",
                                    key: "articles",
                                    icon: "tag"
                                },
                                {
                                    text: "Familles",
                                    key: "families",
                                    icon: "categories"
                                }
                            ]
                        }
                    ]
                    SidebarGroup {
                        id: group
                        required property var modelData
                        title: modelData.title
                        collapsed: root.collapsed
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Repeater {
                            model: group.modelData.items
                            SidebarItem {
                                required property var modelData
                                text: modelData.text
                                iconName: modelData.icon
                                active: modelData.key === "sales"
                                collapsed: root.collapsed
                                implicitHeight: 32
                                Layout.fillWidth: true
                                onClicked: root.navigate(modelData.key)
                            }
                        }
                    }
                }
                SidebarItem {
                    text: "Règlements"
                    iconName: "money"
                    collapsed: root.collapsed
                    Layout.fillWidth: true
                    Layout.margins: 8
                    onClicked: root.navigate("payments")
                }
            }
        }
        BottomBrandingArea {
            collapsed: root.collapsed
            Layout.fillWidth: true
            implicitHeight: 64
        }
        Rectangle {
            color: "#0B243A"
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                Label {
                    text: "Azenz Cloud Sync"
                    color: "#CBD5E1"
                    font.pixelSize: 10
                    visible: !root.collapsed
                    Layout.fillWidth: true
                }
                SidebarItem {
                    text: root.collapsed ? "Agrandir" : "Réduire"
                    collapsed: true
                    iconName: "left"
                    iconRotation: root.collapsed ? 180 : 0
                    implicitWidth: 36
                    implicitHeight: 28
                    onClicked: root.collapsed = !root.collapsed
                }
            }
        }
    }
}
