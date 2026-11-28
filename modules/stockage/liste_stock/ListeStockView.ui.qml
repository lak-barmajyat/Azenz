import QtQuick
import QtQuick.Layouts
import "../../../qml/controls"
import "../../../qml/components"
import "../../../qml/theme"

Rectangle {
    id: root
    color: Colors.canvas
    property var rows: []
    property var columns: []
    property var documentTypes: []
    property string filterError: ""
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
    property alias columnsButton: columnsAction
    property alias refreshButton: refresh
    property alias backButton: back
    property alias footerNewButton: footerNew

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Colors.surface
            border.color: Colors.border
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 6
                AzenzButton { id: create; text: qsTr("Nouveau"); iconName: "add"; size: "compact" }
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
                    enabled: root.rows.length > 0
                }
                Item { Layout.fillWidth: true }
                AzenzButton {
                    id: columnsAction
                    iconName: "columns"
                    variant: "icon"
                    size: "compact"
                    tooltip: qsTr("Afficher les colonnes")
                }
                AzenzButton {
                    id: refresh
                    iconName: "refresh"
                    variant: "icon"
                    size: "compact"
                    tooltip: qsTr("Actualiser")
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: filters.childrenRect.height + 16
            color: Colors.surface
            border.color: Colors.border
            Flow {
                id: filters
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                spacing: 8
                Row {
                    spacing: 6
                    height: 30
                    Label { text: qsTr("Code document :"); anchors.verticalCenter: parent.verticalCenter }
                    AzenzTextField {
                        id: codeFilter
                        objectName: "stockCodeFilter"
                        width: 130
                        height: 30
                        placeholderText: qsTr("ex : STK-001")
                    }
                }
                Row {
                    spacing: 6
                    height: 30
                    Label { text: qsTr("Type :"); anchors.verticalCenter: parent.verticalCenter }
                    AzenzComboBox {
                        id: typeFilter
                        width: 190
                        height: 30
                        model: root.documentTypes
                        currentIndex: 0
                    }
                }
                Row {
                    spacing: 6
                    height: 30
                    Label { text: qsTr("Du :"); anchors.verticalCenter: parent.verticalCenter }
                    DateInput { id: fromDate; width: 128; height: 30 }
                }
                Row {
                    spacing: 6
                    height: 30
                    Label { text: qsTr("À :"); anchors.verticalCenter: parent.verticalCenter }
                    DateInput { id: toDate; width: 128; height: 30 }
                }
                Row {
                    width: Math.min(280, filters.width)
                    height: 30
                    spacing: 8
                    AzenzButton {
                        id: apply
                        objectName: "stockApplyFilter"
                        width: parent.width - reset.width - parent.spacing
                        height: parent.height
                        text: qsTr("Appliquer")
                        iconName: "filter"
                        size: "compact"
                    }
                    IconButton {
                        id: reset
                        objectName: "stockResetFilter"
                        width: 30
                        height: parent.height
                        iconName: "refresh"
                        size: "compact"
                        tooltip: qsTr("Réinitialiser les filtres")
                    }
                }
            }
        }

        Label {
            text: root.filterError
            visible: text !== ""
            color: Colors.danger
            Layout.fillWidth: true
            Layout.leftMargin: 12
        }

        DataGrid {
            id: grid
            objectName: "stockGrid"
            rows: root.rows
            columns: root.columns
            density: "compact"
            footerSummary: qsTr("Lignes : %1 • Sélectionnés : %2").arg(root.rows.length).arg(selectionCount)
            footerHint: qsTr("Défilement continu")
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            Layout.margins: 12
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            color: Colors.surface
            border.color: Colors.border
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                Label {
                    text: qsTr("Entrée : ouvrir le document sélectionné")
                    color: Colors.textSecondary
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                AzenzButton {
                    id: back
                    text: qsTr("Retour")
                    iconName: "left"
                    variant: "secondary"
                    size: "compact"
                }
                AzenzButton {
                    id: footerNew
                    text: qsTr("Nouveau")
                    iconName: "add"
                    size: "compact"
                }
            }
        }
    }
}
