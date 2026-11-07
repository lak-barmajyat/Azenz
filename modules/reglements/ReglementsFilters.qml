import QtQuick
import QtQuick.Layouts
import "../../qml/controls"
import "../../qml/theme"

Rectangle {
    id: root
    property bool suppliers: false
    readonly property bool compact: width < 850
    property alias codeText: code.text
    property alias tierCodeText: tierCode.text
    property alias tierText: tier.text
    property alias commentText: comment.text
    property alias modePicker: mode
    property alias statusPicker: status
    property alias startDate: startDate
    property alias endDate: endDate
    signal applyRequested
    signal resetRequested

    implicitHeight: fields.implicitHeight + 16
    color: Colors.surface
    border.color: Colors.border
    radius: 4

    function clearQueries() {
        code.text = "";
        tierCode.text = "";
        tier.text = "";
        comment.text = "";
        mode.currentIndex = 0;
        status.currentIndex = 0;
    }

    function resetFields() {
        clearQueries();
        startDate.hasValue = false;
        endDate.hasValue = false;
    }

    GridLayout {
        id: fields
        anchors.fill: parent
        anchors.margins: 8
        columns: root.compact ? 3 : 5
        columnSpacing: 8
        rowSpacing: 7

        ColumnLayout {
            Layout.row: 0; Layout.column: 0
            Layout.fillWidth: true; Layout.preferredWidth: 180; Layout.minimumWidth: root.compact ? 0 : 125
            spacing: 3
            Label { text: qsTr("Code règlement").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            AzenzTextField { id: code; objectName: "paymentCodeFilter"; Layout.fillWidth: true; placeholderText: qsTr("Ex: REG-2025...") }
        }
        ColumnLayout {
            Layout.row: 0; Layout.column: 1
            Layout.fillWidth: true; Layout.preferredWidth: 180; Layout.minimumWidth: root.compact ? 0 : 125
            spacing: 3
            Label { text: root.suppliers ? qsTr("Code fournisseur").toUpperCase() : qsTr("Code client").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            AzenzTextField { id: tierCode; Layout.fillWidth: true; placeholderText: root.suppliers ? qsTr("FR-00...") : qsTr("CL-00...") }
        }
        ColumnLayout {
            Layout.row: 0; Layout.column: 2
            Layout.fillWidth: true; Layout.preferredWidth: root.compact ? 220 : 330; Layout.minimumWidth: root.compact ? 0 : 200
            spacing: 3
            Label { text: root.suppliers ? qsTr("Fournisseur").toUpperCase() : qsTr("Client").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            AzenzTextField {
                id: tier
                Layout.fillWidth: true
                inputType: "search"
                placeholderText: root.suppliers ? qsTr("Rechercher fournisseur / raison sociale...") : qsTr("Rechercher par raison sociale...")
            }
        }
        ColumnLayout {
            Layout.row: root.compact ? 1 : 0; Layout.column: root.compact ? 0 : 3
            Layout.fillWidth: true; Layout.preferredWidth: 180; Layout.minimumWidth: root.compact ? 0 : 135
            spacing: 3
            Label { text: qsTr("Mode de règlement").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            AzenzComboBox {
                id: mode
                Layout.fillWidth: true
                model: [qsTr("Tous les modes"), qsTr("Virement Bancaire"), qsTr("Chèque"), qsTr("Traite"), qsTr("Espèces"), qsTr("Carte Bancaire")]
                currentIndex: 0
            }
        }
        ColumnLayout {
            Layout.row: root.compact ? 1 : 0; Layout.column: root.compact ? 1 : 4
            Layout.fillWidth: true; Layout.preferredWidth: 180; Layout.minimumWidth: root.compact ? 0 : 135
            spacing: 3
            Label { text: qsTr("Statut").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            AzenzComboBox { id: status; Layout.fillWidth: true; model: [qsTr("Tous les statuts"), qsTr("Validé"), qsTr("En attente"), qsTr("Brouillon")]; currentIndex: 0 }
        }
        ColumnLayout {
            Layout.row: root.compact ? 2 : 1; Layout.column: 0
            Layout.fillWidth: true; Layout.preferredWidth: 180; Layout.minimumWidth: root.compact ? 0 : 125
            spacing: 3
            Label { text: qsTr("Du").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            DateInput { id: startDate; Layout.fillWidth: true }
        }
        ColumnLayout {
            Layout.row: root.compact ? 2 : 1; Layout.column: 1
            Layout.fillWidth: true; Layout.preferredWidth: 180; Layout.minimumWidth: root.compact ? 0 : 125
            spacing: 3
            Label { text: qsTr("Au").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            DateInput { id: endDate; Layout.fillWidth: true }
        }
        ColumnLayout {
            Layout.row: 1; Layout.column: 2; Layout.columnSpan: root.compact ? 1 : 2
            Layout.fillWidth: true
            spacing: 3
            Label { text: qsTr("Commentaire / note").toUpperCase(); font.pixelSize: 10; color: Colors.textSecondary }
            AzenzTextField { id: comment; Layout.fillWidth: true; placeholderText: qsTr("Filtrer par référence bancaire, motif ou libellé...") }
        }
        RowLayout {
            Layout.row: root.compact ? 2 : 1; Layout.column: root.compact ? 2 : 4
            Layout.fillWidth: true; Layout.alignment: Qt.AlignBottom
            spacing: 8
            AzenzButton { text: qsTr("Appliquer"); iconName: "filter"; size: "compact"; Layout.fillWidth: true; onClicked: root.applyRequested() }
            IconButton { iconName: "refresh"; tooltip: qsTr("Réinitialiser les filtres"); onClicked: root.resetRequested() }
        }
    }
}
