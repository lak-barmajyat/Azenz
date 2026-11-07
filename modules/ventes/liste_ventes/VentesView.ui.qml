import QtQuick
import QtQuick.Layouts
import "../../../qml/controls"
import "../../../qml/components"
import "../../../qml/theme"

Rectangle {
    id: root
    color: Colors.canvas
    property var records: []
    property var columns: []
    property string viewState: "default"
    property string filterError: ""
    property real totalHT: 0
    property real totalVAT: 0
    property real totalTTC: 0
    property string userName: "Mohammed"
    property string connectionText: "Hors connexion"
    property bool connected: false
    property bool previewMode: false
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
    property alias exportButton: exportAction
    property alias refreshButton: refresh
    property alias backButton: back
    property alias newDocumentButton: newDocument

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 94
            color: Colors.surface
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: qsTr("Ventes")
                        color: Colors.navy
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    ToolbarSeparator { implicitHeight: 18 }
                    Breadcrumb {}
                    Item { Layout.fillWidth: true }
                    AzenzButton {
                        id: refresh
                        text: qsTr("Actualiser")
                        iconName: "refresh"
                        variant: "secondary"
                        size: "compact"
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.subtle
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    AzenzButton {
                        id: create
                        text: qsTr("Nouveau")
                        iconName: "add"
                        size: "compact"
                    }
                    AzenzButton {
                        id: edit
                        text: qsTr("Modifier")
                        iconName: "edit"
                        variant: "secondary"
                        size: "compact"
                        enabled: grid.selectionCount === 1
                    }
                    AzenzButton {
                        id: remove
                        text: qsTr("Supprimer")
                        iconName: "delete"
                        variant: "danger"
                        size: "compact"
                        enabled: grid.selectionCount > 0
                    }
                    AzenzButton {
                        id: duplicate
                        text: qsTr("Dupliquer")
                        iconName: "copy"
                        variant: "secondary"
                        size: "compact"
                        enabled: grid.selectionCount === 1
                    }
                    AzenzButton {
                        id: printAction
                        text: qsTr("Imprimer")
                        iconName: "print"
                        variant: "secondary"
                        size: "compact"
                        enabled: grid.selectionCount > 0
                    }
                    AzenzButton {
                        id: exportAction
                        text: qsTr("Exporter Excel")
                        iconName: "table"
                        variant: "secondary"
                        size: "compact"
                        enabled: root.records.length > 0
                    }
                    Item { Layout.fillWidth: true }
                    AzenzButton {
                        id: back
                        text: qsTr("Retour")
                        iconName: "left"
                        variant: "secondary"
                        size: "compact"
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            color: Colors.canvas
            border.color: Colors.border
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                AzenzTextField {
                    id: codeFilter
                    objectName: "ventesCodeFilter"
                    width: 140
                    height: 30
                    placeholderText: qsTr("Code document")
                }
                AzenzComboBox {
                    id: typeFilter
                    width: 160
                    height: 30
                    model: [
                        { text: qsTr("Tous les types"), value: "" },
                        { text: qsTr("Devis commercial"), value: "Devis" },
                        { text: qsTr("Facture de vente"), value: "Facture" },
                        { text: qsTr("Bon de commande"), value: "Commande" },
                        { text: qsTr("Bon de livraison"), value: "Livraison" }
                    ]
                    currentIndex: 0
                }
                DateInput {
                    id: fromDate
                    objectName: "ventesFromDate"
                    width: 138
                    height: 30
                }
                DateInput {
                    id: toDate
                    objectName: "ventesToDate"
                    width: 138
                    height: 30
                }
                AzenzButton {
                    id: apply
                    text: qsTr("Appliquer")
                    variant: "secondary"
                    size: "compact"
                }
                IconButton {
                    id: reset
                    iconName: "close"
                    size: "compact"
                    tooltip: qsTr("Réinitialiser les filtres")
                }
            }
        }
        Label {
            text: root.filterError
            visible: text !== ""
            color: Colors.danger
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.topMargin: 6
        }
        DataGrid {
            id: grid
            objectName: "ventesGrid"
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
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            color: Colors.surface
            border.color: Colors.border
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                FinancialTotal { title: qsTr("Total HT"); amount: root.totalHT }
                FinancialTotal { title: qsTr("TVA"); amount: root.totalVAT }
                FinancialTotal {
                    title: qsTr("Total TTC")
                    amount: root.totalTTC
                    emphasized: true
                    implicitWidth: 170
                }
                Item { Layout.fillWidth: true }
                AzenzButton {
                    id: newDocument
                    text: qsTr("Nouveau document")
                    iconName: "add"
                    size: "compact"
                }
            }
        }
    }
}
