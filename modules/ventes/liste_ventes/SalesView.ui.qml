import QtQuick
import QtQuick.Layouts
import "../../../qml/controls"
import "../../../qml/components"
import "../../../qml/theme"

Rectangle {
    id: root
    width: 1600
    height: 1000
    color: Colors.canvas
    property var records: []
    property var columns: []
    property string viewState: "default"
    property string filterError: ""
    property real totalHT: 0
    property real totalVAT: 0
    property real totalTTC: 0
    property string companyName: "Atlas Distribution"
    property string userName: "Mohammed"
    property string connectionText: "Hors connexion"
    property bool connected: false
    property bool previewMode: false
    property alias titleBar: titleBar
    property alias menuBar: menuBar
    property alias sidebar: sidebar
    property alias grid: grid
    property alias codeFilter: codeFilter
    property alias typeFilter: typeFilter
    property alias fromDate: fromDate
    property alias toDate: toDate
    property alias applyButton: apply
    property alias resetButton: reset
    property alias newButton: create
    property alias editButton: edit
    property alias deleteButton: remove
    property alias duplicateButton: duplicate
    property alias printButton: printAction
    property alias exportButton: exportButton
    property alias refreshButton: refresh
    property alias backButton: back
    property alias newDocumentButton: newDocument

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        WindowTitleBar {
            id: titleBar
            dark: true
            title: "AZENZ ERP Desktop v4.2.1 Pro"
            subtitle: root.previewMode ? "| Aperçu des écrans" : ""
            Layout.fillWidth: true
        }
        ApplicationMenuBar {
            id: menuBar
            dark: true
            Layout.fillWidth: true
            Layout.preferredHeight: 28
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            SalesSidebar {
                id: sidebar
                companyName: root.companyName
                userName: root.userName
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                Rectangle {
                    color: "white"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 94
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Label {
                                text: "Ventes"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: Colors.navy
                            }
                            ToolbarSeparator {
                                implicitHeight: 18
                            }
                            Breadcrumb {}
                            Item {
                                Layout.fillWidth: true
                            }
                            AzenzButton {
                                id: refresh
                                text: "F5"
                                iconName: "refresh"
                                variant: "secondary"
                                size: "compact"
                                implicitWidth: 54
                                leftPadding: 8
                                rightPadding: 8
                            }
                        }
                        Rectangle {
                            height: 1
                            color: Colors.subtle
                            Layout.fillWidth: true
                        }
                        RowLayout {
                            spacing: 6
                            Layout.fillWidth: true
                            AzenzButton {
                                id: create
                                text: "Nouveau"
                                iconName: "add"
                                size: "compact"
                            }
                            ToolbarSeparator {
                                Layout.leftMargin: 4
                                Layout.rightMargin: 4
                            }
                            AzenzButton {
                                id: edit
                                text: "Modifier"
                                iconName: "edit"
                                variant: "secondary"
                                size: "compact"
                                enabled: grid.selectionCount === 1
                            }
                            AzenzButton {
                                id: remove
                                text: "Supprimer"
                                iconName: "delete"
                                variant: "danger"
                                size: "compact"
                                enabled: grid.selectionCount > 0
                            }
                            AzenzButton {
                                id: duplicate
                                text: "Dupliquer"
                                iconName: "copy"
                                variant: "secondary"
                                size: "compact"
                                enabled: grid.selectionCount === 1
                            }
                            ToolbarSeparator {
                                Layout.leftMargin: 4
                                Layout.rightMargin: 4
                            }
                            AzenzButton {
                                id: printAction
                                text: "Imprimer"
                                iconName: "print"
                                variant: "secondary"
                                size: "compact"
                                enabled: grid.selectionCount > 0
                            }
                            AzenzButton {
                                id: exportButton
                                text: "Exporter Excel"
                                iconName: "table"
                                variant: "secondary"
                                size: "compact"
                                enabled: root.records.length > 0
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            Label {
                                text: "Filtrage instantané actif"
                                font.pixelSize: 10
                                color: "#94A3B8"
                                visible: root.width > 1450
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: filters.implicitHeight + 16
                    color: Colors.canvas
                    border.color: Colors.border
                    Flow {
                        id: filters
                        x: 20
                        y: 8
                        width: parent.width - 40
                        spacing: 10
                        Row {
                            spacing: 6
                            Label {
                                text: "Code Document :"
                                height: 28
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            AzenzTextField {
                                id: codeFilter
                                objectName: "salesCodeFilter"
                                width: 112
                                height: 28
                                placeholderText: "ex. DV-001"
                            }
                        }
                        Row {
                            spacing: 6
                            Label {
                                text: "Type :"
                                height: 28
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            AzenzComboBox {
                                id: typeFilter
                                width: 170
                                height: 28
                                model: [
                                    {
                                        text: "Tous les types",
                                        value: ""
                                    },
                                    {
                                        text: "Devis Commercial",
                                        value: "Devis"
                                    },
                                    {
                                        text: "Facture de Vente",
                                        value: "Facture"
                                    },
                                    {
                                        text: "Bon de Commande",
                                        value: "Commande"
                                    },
                                    {
                                        text: "Bon de Livraison",
                                        value: "Livraison"
                                    }
                                ]
                                currentIndex: 0
                            }
                        }
                        Row {
                            spacing: 6
                            Label {
                                text: "Du :"
                                height: 28
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            DateInput {
                                id: fromDate
                                objectName: "salesFromDate"
                                width: 138
                                height: 28
                            }
                        }
                        Row {
                            spacing: 6
                            Label {
                                text: "À :"
                                height: 28
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                            DateInput {
                                id: toDate
                                objectName: "salesToDate"
                                width: 138
                                height: 28
                            }
                        }
                        AzenzButton {
                            id: apply
                            text: "Appliquer les filtres"
                            size: "compact"
                            variant: "secondary"
                        }
                        IconButton {
                            id: reset
                            iconName: "close"
                            size: "compact"
                            tooltip: "Réinitialiser les filtres"
                        }
                    }
                }
                Label {
                    text: root.filterError
                    visible: text !== ""
                    color: Colors.danger
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.topMargin: 6
                }
                DataGrid {
                    id: grid
                    objectName: "salesGrid"
                    rows: root.records
                    columns: root.columns
                    viewState: root.viewState
                    density: "comfortable"
                    headerBackground: Colors.navy
                    headerForeground: "white"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 16
                }
                Rectangle {
                    color: "white"
                    border.color: Colors.border
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 12
                        FinancialTotal {
                            title: "Total HT"
                            amount: root.totalHT
                        }
                        FinancialTotal {
                            title: "Montant TVA (20%)"
                            amount: root.totalVAT
                        }
                        FinancialTotal {
                            title: "Total TTC"
                            amount: root.totalTTC
                            emphasized: true
                            implicitWidth: 186
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        AzenzButton {
                            id: back
                            text: "Retour"
                            iconName: "left"
                            variant: "secondary"
                            size: "compact"
                        }
                        AzenzButton {
                            id: newDocument
                            text: "Nouveau Document"
                            iconName: "add"
                            size: "compact"
                        }
                    }
                }
            }
        }
        Rectangle {
            color: "#0C263E"
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                Label {
                    text: "Société : " + root.companyName
                    color: "#E2E8F0"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }
                Label {
                    text: root.previewMode ? "Données d'exemple" : ""
                    color: "#94A3B8"
                    font.pixelSize: 10
                }
                Rectangle {
                    width: 7
                    height: 7
                    radius: 4
                    color: root.connected ? Colors.success : Colors.warning
                }
                Label {
                    text: root.connectionText
                    color: root.connected ? "#34D399" : "#CBD5E1"
                    font.pixelSize: 11
                }
            }
        }
    }
}
