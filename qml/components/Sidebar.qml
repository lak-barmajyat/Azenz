pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property bool collapsed: false
    property string currentPage: "sales"
    property alias companyName: identity.companyName
    property alias branchName: identity.branchName
    property alias companyLogo: identity.logoSource
    property var groups: [
        {
            title: "DOCUMENTS",
            items: [
                {
                    key: "sales",
                    text: "Ventes",
                    icon: "sales"
                },
                {
                    key: "purchases",
                    text: "Achats",
                    icon: "box"
                },
                {
                    key: "stock",
                    text: "Stockage",
                    icon: "box"
                }
            ]
        },
        {
            title: "TIERS",
            items: [
                {
                    key: "clients",
                    text: "Clients",
                    icon: "users"
                },
                {
                    key: "suppliers",
                    text: "Fournisseurs",
                    icon: "users"
                }
            ]
        },
        {
            title: "CATALOGUE",
            items: [
                {
                    key: "articles",
                    text: "Articles",
                    icon: "box"
                },
                {
                    key: "families",
                    text: "Familles",
                    icon: "folder"
                }
            ]
        }
    ]
    signal navigate(string page)
    implicitWidth: collapsed ? Theme.sidebarCollapsed : Theme.sidebarExpanded
    implicitHeight: 640
    color: Colors.navy
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        CompanyIdentityArea {
            id: identity
            collapsed: root.collapsed
            Layout.fillWidth: true
        }
        SidebarItem {
            text: root.collapsed ? qsTr("Développer") : qsTr("Réduire")
            iconName: "menu"
            collapsed: root.collapsed
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            onClicked: root.collapsed = !root.collapsed
        }
        C.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            C.ScrollBar.horizontal.policy: C.ScrollBar.AlwaysOff
            ColumnLayout {
                width: parent.width
                spacing: 8
                SidebarItem {
                    text: qsTr("Tableau de bord")
                    iconName: "home"
                    collapsed: root.collapsed
                    active: root.currentPage === "dashboard"
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    onClicked: {
                        root.currentPage = "dashboard";
                        root.navigate("dashboard");
                    }
                }
                Repeater {
                    model: root.groups
                    SidebarGroup {
                        required property var modelData
                        title: modelData.title
                        collapsed: root.collapsed
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Repeater {
                            model: modelData.items
                            SidebarItem {
                                required property var modelData
                                text: modelData.text
                                iconName: modelData.icon
                                enabled: modelData.enabled !== false
                                active: root.currentPage === modelData.key
                                collapsed: root.collapsed
                                Layout.fillWidth: true
                                onClicked: {
                                    root.currentPage = modelData.key;
                                    root.navigate(modelData.key);
                                }
                            }
                        }
                    }
                }
                SidebarItem {
                    text: qsTr("Règlements")
                    iconName: "money"
                    collapsed: root.collapsed
                    active: root.currentPage === "payments"
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    onClicked: {
                        root.currentPage = "payments";
                        root.navigate("payments");
                    }
                }
            }
        }
        BottomBrandingArea {
            collapsed: root.collapsed
            Layout.fillWidth: true
        }
    }
}
