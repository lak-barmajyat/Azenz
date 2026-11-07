import QtQuick
import QtQuick.Layouts
import "../../../qml/components"
import "../../../qml/controls"
import "../../../qml/theme"

ColumnLayout {
    id: root
    property var payments: []
    property var paymentMethods: [
        qsTr("Virement Bancaire"), qsTr("Chèque"), qsTr("Traite"),
        qsTr("Espèces"), qsTr("Carte Bancaire")
    ]
    property bool editingPayment: false
    property alias discountText: discount.text
    property alias referenceText: reference.text
    property alias descriptionText: description.text
    property alias amountText: amount.text
    property alias paymentDate: paymentDate
    property alias paymentMethod: method
    property alias applyButton: apply
    property alias addButton: add
    property alias grid: paymentGrid
    spacing: 8

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: 4
        color: Colors.subtle
        border.color: Colors.border
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 10
            Icon {
                name: "tag"
                color: Colors.accent
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
            }
            Label {
                text: qsTr("Remise globale :")
                color: Colors.text
                font.weight: Font.DemiBold
            }
            AzenzTextField {
                id: discount
                inputType: "currency"
                suffix: "MAD"
                text: "0,00"
                Layout.preferredWidth: 130
            }
            Label {
                text: qsTr("Remise commerciale globale appliquée au document (affecte le Total TTC net à payer)")
                color: Colors.textSecondary
                font.italic: true
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            AzenzButton {
                id: apply
                text: qsTr("Appliquer")
                variant: "secondary"
                size: "compact"
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: paymentFields.implicitHeight + 16
        radius: 4
        color: Colors.surface
        border.color: Colors.border
        GridLayout {
            id: paymentFields
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            columns: width < 980 ? 3 : 6
            columnSpacing: 8
            rowSpacing: 8
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 145
                Label { text: qsTr("Référence"); font.pixelSize: 10; color: Colors.textSecondary }
                AzenzTextField {
                    id: reference
                    Layout.fillWidth: true
                    placeholderText: qsTr("Référence")
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: paymentFields.columns === 6 ? 390 : 160
                Label { text: qsTr("Description"); font.pixelSize: 10; color: Colors.textSecondary }
                AzenzTextField {
                    id: description
                    Layout.fillWidth: true
                    placeholderText: qsTr("Description du règlement")
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 130
                Label { text: qsTr("Montant (MAD)"); font.pixelSize: 10; color: Colors.textSecondary }
                AzenzTextField {
                    id: amount
                    inputType: "currency"
                    suffix: ""
                    Layout.fillWidth: true
                    placeholderText: "0,00"
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 130
                Label { text: qsTr("Date"); font.pixelSize: 10; color: Colors.textSecondary }
                DateInput { id: paymentDate; Layout.fillWidth: true }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 175
                Label { text: qsTr("Mode de règlement"); font.pixelSize: 10; color: Colors.textSecondary }
                AzenzComboBox {
                    id: method
                    Layout.fillWidth: true
                    model: root.paymentMethods
                    currentIndex: 0
                }
            }
            AzenzButton {
                id: add
                text: root.editingPayment ? qsTr("Mettre à jour") : qsTr("Ajouter règlement")
                iconName: "add"
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                Layout.preferredWidth: 155
                Layout.minimumWidth: 155
            }
        }
    }

    DataGrid {
        id: paymentGrid
        Layout.fillWidth: true
        Layout.preferredHeight: root.payments.length === 0 ? 132 : 70 + root.payments.length * 28
        Layout.minimumHeight: root.payments.length === 0 ? 132 : 126
        rows: root.payments
        selectable: false
        density: "compact"
        headerBackground: "#EEF2F6"
        headerForeground: Colors.textSecondary
        compactEmptyState: true
        emptyTitle: qsTr("Aucun règlement enregistré")
        footerSummary: root.payments.length === 1 ? qsTr("1 règlement enregistré")
                        : qsTr("%1 règlements enregistrés").arg(root.payments.length)
        footerHint: root.payments.length > 0 ? qsTr("Clic droit sur une ligne pour les options contextuelles") : ""
        footerBackground: "#F8FAFC"
        footerTopBorder: true
        columns: [
            {key: "code", title: qsTr("Code règlement"), width: 145, type: "code", sortable: false},
            {key: "description", title: qsTr("Description"), width: Math.max(260, paymentGrid.width - 565), sortable: false},
            {key: "amountDisplay", title: qsTr("Montant"), width: 125, alignment: "right", sortable: false},
            {key: "dateDisplay", title: qsTr("Date"), width: 105, alignment: "center", sortable: false},
            {key: "method", title: qsTr("Mode"), width: 170, sortable: false}
        ]
    }
}
