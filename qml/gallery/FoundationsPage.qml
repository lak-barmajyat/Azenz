pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../controls"
import "../components"
import "../theme"

ColumnLayout {
    spacing: 16
    GallerySection {
        title: "01–02 / Fondations & couleurs"
        subtitle: "Navy structurel, orange d'action, surfaces claires et couleurs sémantiques"
        Layout.fillWidth: true
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Repeater {
                model: [
                    {
                        name: "Primary Navy",
                        color: Colors.navy
                    },
                    {
                        name: "Accent Orange",
                        color: Colors.accent
                    },
                    {
                        name: "Canvas",
                        color: Colors.canvas
                    },
                    {
                        name: "Surface",
                        color: Colors.surface
                    },
                    {
                        name: "Border",
                        color: Colors.border
                    },
                    {
                        name: "Text Primary",
                        color: Colors.text
                    }
                ]
                ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        color: modelData.color
                        radius: 4
                        border.color: Colors.border
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                    }
                    Label {
                        text: modelData.name
                        font.pixelSize: 12
                    }
                    Label {
                        text: modelData.color
                        font.pixelSize: 11
                        color: Colors.textSecondary
                    }
                }
            }
        }
    }
    GallerySection {
        title: "03 / Typographie"
        subtitle: "Inter · Noto Sans Arabic · Chiffres tabulaires"
        Layout.fillWidth: true
        Label {
            text: "Gestion Commerciale & Facturation Ventes"
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
        Label {
            text: "Lignes d'articles du devis DV-2025-0042"
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
        Label {
            text: "Client : SARL ATLAS DISTRIBUTION"
            font.pixelSize: 14
            font.weight: Font.Medium
        }
        Label {
            text: "Ce document constitue une confirmation ferme sous réserve des conditions générales."
            font.pixelSize: 13
        }
        Label {
            text: "Dernière modification par admin le 24/05/2025 à 14:32:09"
            font.pixelSize: 12
            color: Colors.textSecondary
        }
        Label {
            text: "PIÈCE COMPTABLE VALIDÉE • STATUT FERMÉ"
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
        Label {
            text: "إدارة المبيعات والفواتير — نظام أزينز"
            arabic: true
            font.pixelSize: 20
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
        }
        Label {
            text: "HT : 124 500,00 MAD     TVA : 24 900,00 MAD     TTC : 149 400,00 MAD"
            tabular: true
            font.pixelSize: 13
            color: Colors.navy
        }
    }
    GallerySection {
        title: "04 / Espacements & rayons"
        subtitle: "Échelle de 4px • Rayons 4 / 6 / 8px"
        Layout.fillWidth: true
        RowLayout {
            spacing: 24
            Repeater {
                model: [4, 8, 12, 16, 20, 24, 32]
                ColumnLayout {
                    required property int modelData
                    Rectangle {
                        width: modelData
                        height: 32
                        color: Colors.accent
                    }
                    Label {
                        text: modelData + "px"
                        font.pixelSize: 11
                    }
                }
            }
            Item {
                Layout.preferredWidth: 24
            }
            Repeater {
                model: [4, 6, 8]
                Rectangle {
                    required property int modelData
                    width: 80
                    height: 48
                    radius: modelData
                    color: Colors.subtle
                    border.color: Colors.borderStrong
                    Label {
                        anchors.centerIn: parent
                        text: modelData + "px"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
    GallerySection {
        title: "16 / Identité AZENZ"
        subtitle: "Images originales référencées dans le HTML • Proportions préservées"
        Layout.fillWidth: true
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            Logo {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 64
            }
            Rectangle {
                color: Colors.navy
                radius: 6
                Layout.preferredWidth: 190
                Layout.preferredHeight: 80
                Logo {
                    anchors.centerIn: parent
                    variant: "dark"
                    width: 160
                    height: 64
                }
            }
            Logo {
                variant: "symbol"
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
            }
            Logo {
                variant: "monochrome"
                Layout.preferredWidth: 160
                Layout.preferredHeight: 64
            }
        }
    }
}
