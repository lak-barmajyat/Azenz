import QtQuick
import QtQuick.Layouts
import "../../../qml/controls"
import "../../../qml/components"
import "../../../qml/theme"

Rectangle {
    id: root
    color: Colors.canvas
    property var rows: []
    property var columns: [
        {key: "reference", title: qsTr("Réf"), width: 155, searchable: true,
         placeholder: qsTr("Référence...")},
        {key: "description", title: qsTr("Désignation"), width: 280, fill: 2,
         searchable: true, placeholder: qsTr("Rechercher ou saisir un article...")},
        {key: "quantity", title: qsTr("Qté"), width: 105, editable: true,
         inputType: "number", alignment: "right", defaultValue: 1},
        {key: "comment", title: qsTr("Commentaire"), width: 250, fill: 1,
         editable: true, placeholder: qsTr("Lot, emplacement...")}
    ]
    property var articleSearchResults: ({field: "", query: "", items: []})
    property string formError: ""
    property bool canAddLine: false
    property bool canUpdateLine: false
    property alias codeField: code
    property alias typeField: type
    property alias dateField: documentDate
    property alias commentField: comment
    property alias grid: grid
    property alias validateButton: validate
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
                        AzenzComboBox { id: type; width: parent.width; model: [qsTr("Entrée de stock"), qsTr("Sortie de stock"), qsTr("Ajustement"), qsTr("Inventaire")]; currentIndex: 0 }
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
                        Item { width: 1; height: 16 }
                        AzenzButton { id: validate; text: qsTr("Valider"); iconName: "check"; width: parent.width }
                    }
                }
            }
        }

        SearchEntryTable {
            id: grid
            objectName: "stockDocumentLines"
            rows: root.rows
            columns: root.columns
            searchResults: root.articleSearchResults
            selectable: false
            showRowNumber: false
            showTypeIcon: false
            alwaysShowRowActions: true
            actionWidth: 76
            requireSelection: false
            addEnabled: root.canAddLine
            editEnabled: root.canUpdateLine
            addActionLabel: qsTr("Ajouter la ligne")
            localeName: "fr_MA"
            defaultValues: ({quantity: 1})
            rowHeight: 44
            headerHeight: 44
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: root.height < 600 ? 140 : 180
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 18
            Label { text: qsTr("Lignes : %1").arg(root.rows.length); color: Colors.textSecondary; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            Label { text: root.formError !== "" ? root.formError : qsTr("Modifier ou supprimer depuis Actions"); color: root.formError !== "" ? Colors.danger : Colors.textSecondary; font.pixelSize: 11 }
        }
        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            AzenzButton { id: back; text: qsTr("Retour"); iconName: "left"; variant: "secondary"; size: "compact" }
            AzenzButton { id: create; objectName: "stockNewDocument"; text: qsTr("Nouveau"); iconName: "add"; size: "compact" }
        }
    }
}
