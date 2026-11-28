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
    property var articleSuggestions: []
    property var documentTypes: []
    property string formError: ""
    property bool busy: false
    property alias codeField: code
    property alias typeField: type
    property alias dateField: documentDate
    property alias commentField: comment
    property alias refField: ref
    property alias designationField: designation
    property alias quantityField: quantity
    property alias lineCommentField: lineComment
    property alias grid: grid
    property alias validateButton: validate
    property alias cancelButton: cancel
    property alias deleteButton: remove
    property alias saveButton: save
    property alias backButton: back
    property alias newButton: create

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: headerColumn.implicitHeight + 20
            color: Colors.surface
            radius: 4
            border.color: Colors.border
            ColumnLayout {
                id: headerColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 8
                Label { text: qsTr("EN-TÊTE DU DOCUMENT"); font.bold: true; font.pixelSize: 11; color: Colors.textSecondary }
                Flow {
                    Layout.fillWidth: true
                    spacing: 9
                    InputField { id: code; width: 148; label: qsTr("Code Doc"); placeholderText: qsTr("STK-2025-001") }
                    Column {
                        width: 185
                        spacing: 4
                        Label { text: qsTr("Type document"); font.pixelSize: 12 }
                        AzenzComboBox { id: type; width: parent.width; model: root.documentTypes; currentIndex: -1 }
                    }
                    Column {
                        width: 125
                        spacing: 4
                        Label { text: qsTr("Date"); font.pixelSize: 12 }
                        DateInput { id: documentDate; width: parent.width; hasValue: true }
                    }
                    InputField { width: 115; label: qsTr("Statut"); text: qsTr("Brouillon"); readOnly: true }
                    InputField { id: comment; width: Math.max(250, root.width - 810); label: qsTr("Commentaire"); placeholderText: qsTr("Motif ou référence du mouvement...") }
                    Column {
                        width: 100
                        spacing: 4
                        Item { height: 16; width: 1 }
                        AzenzButton { id: validate; text: qsTr("Valider"); iconName: "check"; width: parent.width; enabled: !root.busy }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: lineColumn.implicitHeight + 20
            color: Colors.surface
            radius: 4
            border.color: Colors.border
            ColumnLayout {
                id: lineColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: qsTr("SAISIE DE LIGNE ARTICLE"); font.bold: true; font.pixelSize: 11; color: Colors.textSecondary }
                    Item { Layout.fillWidth: true }
                    Label { text: qsTr("Appuyez sur Entrée pour ajouter rapidement"); font.pixelSize: 11; color: Colors.textSecondary }
                }
                Flow {
                    Layout.fillWidth: true
                    spacing: 9
                    Column {
                        width: 160
                        spacing: 4
                        Label { text: qsTr("Réf"); font.pixelSize: 12 }
                        SearchEntryField { id: ref; width: parent.width; searchKey: "reference"; primaryKey: "reference"; secondaryKey: "description"; placeholderText: qsTr("ART-0001"); suggestions: root.articleSuggestions }
                    }
                    Column {
                        width: Math.max(210, root.width * 0.27)
                        spacing: 4
                        Label { text: qsTr("Désignation"); font.pixelSize: 12 }
                        SearchEntryField { id: designation; width: parent.width; searchKey: "description"; placeholderText: qsTr("Désignation de l'article..."); suggestions: root.articleSuggestions }
                    }
                    InputField { id: quantity; width: 112; label: qsTr("Qté"); placeholderText: qsTr("0,00"); inputType: "number" }
                    InputField { id: lineComment; width: Math.max(225, root.width * 0.25); label: qsTr("Commentaire"); placeholderText: qsTr("Lot, emplacement...") }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: root.formError; visible: text !== ""; color: Colors.danger; font.pixelSize: 11; Layout.fillWidth: true }
                    Item { Layout.fillWidth: true }
                    AzenzButton { id: cancel; text: qsTr("Annuler"); variant: "secondary"; size: "compact" }
                    AzenzButton { id: remove; text: qsTr("Supprimer"); iconName: "delete"; variant: "danger"; size: "compact"; enabled: grid.selectionCount > 0 }
                    AzenzButton { id: save; text: qsTr("Enregistrer"); iconName: "save"; size: "compact" }
                }
            }
        }

        DataGrid {
            id: grid
            objectName: "stockDocumentLines"
            rows: root.rows
            columns: root.columns
            rowHeight: 44
            headerHeight: 44
            footerSummary: qsTr("Lignes : %1 • Sélectionnés : %2").arg(root.rows.length).arg(selectionCount)
            footerHint: qsTr("Double-cliquez sur une ligne pour modifier")
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 60
        }
        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            AzenzButton { id: back; text: qsTr("Retour"); iconName: "left"; variant: "secondary"; size: "compact" }
            AzenzButton { id: create; text: qsTr("Nouveau"); iconName: "add"; size: "compact" }
        }
    }
}
