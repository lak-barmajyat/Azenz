import QtQuick
import QtQuick.Layouts
import "../controls"
import "../components"
import "../theme"

ColumnLayout {
    spacing: 16
    GallerySection {
        Layout.fillWidth: true
        title: "08 / Navigation desktop"
        subtitle: "Identité entreprise • Volet 224 / 56px • Groupes repliables • Menus système • Fil d'ariane"
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            Sidebar {
                Layout.preferredHeight: 590
                Layout.preferredWidth: implicitWidth
            }
            Sidebar {
                collapsed: true
                Layout.preferredHeight: 590
                Layout.preferredWidth: implicitWidth
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 20
                ApplicationMenuBar {
                    Layout.fillWidth: true
                }
                Breadcrumb {
                    items: ["Documents", "Ventes"]
                }
                Label {
                    text: "Ventes"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
                Label {
                    text: "Les commandes sont exposées par des signaux QML.\nL'écran définit les opérations autorisées."
                    wrapMode: Text.WordWrap
                    color: Colors.textSecondary
                    Layout.fillWidth: true
                }
                MetricCard {
                    label: "Total TTC"
                    value: "149 400,00 MAD"
                    Layout.fillWidth: true
                }
                InlineBanner {
                    title: "Navigation au clavier"
                    message: "Tab pour avancer, Espace ou Entrée pour activer.\nÉchap ferme les menus et surcouches."
                    closeButton: false
                    Layout.fillWidth: true
                }
                Rectangle {
                    color: Colors.navy
                    radius: 6
                    Layout.fillWidth: true
                    Layout.preferredHeight: 68
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        SidebarItem {
                            text: "Actif"
                            iconName: "sales"
                            active: true
                            Layout.fillWidth: true
                        }
                        SidebarItem {
                            text: "Désactivé"
                            iconName: "lock"
                            enabled: false
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
    GallerySection {
        Layout.fillWidth: true
        title: "16 / Barre d'état"
        StatusBar {
            Layout.fillWidth: true
        }
    }
}
