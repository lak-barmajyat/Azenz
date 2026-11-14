import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../../../qml/components"
import "../../../qml/controls"
import "../../../qml/theme"

Rectangle {
    id: root
    property var articleRows: []
    property var paymentRows: []
    property var clients: []
    property var articleSearchResults: ({field: "", query: "", items: []})
    property var computedDraft: ({})
    property var documentTypes: [
        {text: qsTr("FA — Facture Vente"), value: "FA"},
        {text: qsTr("BL — Bon Livraison"), value: "BL"},
        {text: qsTr("DV — Devis Client"), value: "DV"},
        {text: qsTr("AV — Avoir Client"), value: "AV"}
    ]
    property var lineColumns: [
        {key: "reference", title: qsTr("Référence"), width: 130, searchable: true,
         placeholder: qsTr("Référence...")},
        {key: "description", title: qsTr("Désignation"), width: 260, fill: 1, searchable: true,
         placeholder: qsTr("Rechercher ou saisir un article...")},
        {key: "quantity", title: qsTr("Quantité"), width: 78, editable: true,
         inputType: "number", alignment: "right", defaultValue: 1},
        {key: "priceHT", title: qsTr("Prix HT"), width: 110, editable: true,
         inputType: "currency", alignment: "right", decimals: 2},
        {key: "priceTTC", title: qsTr("Prix TTC"), width: 110, alignment: "right",
         decimals: 2},
        {key: "totalHT", title: qsTr("Total HT"), width: 120, alignment: "right",
         decimals: 2},
        {key: "vat", title: qsTr("TVA"), width: 75, alignment: "center", suffix: "%"},
        {key: "totalTTC", title: qsTr("Total TTC"), width: 125, alignment: "right",
         decimals: 2}
    ]
    property string totalHTText: "0,00 MAD"
    property string totalVATText: "0,00 MAD"
    property string totalTTCText: "0,00 MAD"
    property string errorMessage: ""
    property bool busy: false
    property bool editingLine: false
    property bool canAddLine: false
    property alias clientCode: clientCode.text
    property alias clientPicker: client
    property alias documentCode: documentCode.text
    property alias documentType: documentType
    property alias documentDate: documentDate
    property alias activeTab: tabs.currentIndex
    property alias linesTable: lines
    property alias paymentsTab: payments
    property alias backButton: back
    property alias saveButton: save

    color: Colors.canvas
    LayoutMirroring.enabled: Theme.rightToLeft
    LayoutMirroring.childrenInherit: true

    Flickable {
        id: verticalScroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: content.height + 24
        flickableDirection: Flickable.VerticalFlick
        clip: true
        C.ScrollBar.vertical: AzenzScrollBar {}

        ColumnLayout {
            id: content
            x: 12
            y: 12
            width: verticalScroll.width - 24
            height: Math.max(verticalScroll.height - 24, implicitHeight)
            spacing: 9

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: documentFields.implicitHeight + 16
            color: Colors.surface
            radius: 4
            border.color: Colors.border
            GridLayout {
                id: documentFields
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                columns: width < 1020 ? 3 : 5
                columnSpacing: 9
                rowSpacing: 8
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 170
                    Label { text: qsTr("Code Client"); font.pixelSize: 10; color: Colors.textSecondary }
                    AzenzTextField {
                        id: clientCode
                        readOnly: true
                        Layout.fillWidth: true
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: documentFields.columns === 5 ? 340 : 170
                    Label { text: qsTr("Client"); font.pixelSize: 10; color: Colors.textSecondary }
                    AzenzComboBox {
                        id: client
                        objectName: "newDocumentClient"
                        searchable: true
                        model: root.clients
                        Layout.fillWidth: true
                        placeholderText: qsTr("Choisir un client")
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 170
                    Label { text: qsTr("Code Document"); font.pixelSize: 10; color: Colors.textSecondary }
                    AzenzTextField {
                        id: documentCode
                        objectName: "newDocumentCode"
                        Layout.fillWidth: true
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 170
                    Label { text: qsTr("Type Document"); font.pixelSize: 10; color: Colors.textSecondary }
                    AzenzComboBox {
                        id: documentType
                        model: root.documentTypes
                        currentIndex: 0
                        Layout.fillWidth: true
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 170
                    Label { text: qsTr("Date"); font.pixelSize: 10; color: Colors.textSecondary }
                    DateInput {
                        id: documentDate
                        objectName: "newDocumentDate"
                        Layout.fillWidth: true
                    }
                }
            }
        }

        ColumnLayout {
            id: tabWidget
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

        C.TabBar {
            id: tabs
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            currentIndex: 0
            background: Rectangle {
                color: "transparent"
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Colors.border
                }
            }
            C.TabButton {
                id: linesTab
                width: 130
                contentItem: RowLayout {
                    spacing: 7
                    Icon {
                        name: "list_bulleted"
                        color: linesTab.checked ? Colors.accent : Colors.textSecondary
                        Layout.preferredWidth: 17
                        Layout.preferredHeight: 17
                    }
                    Label {
                        text: qsTr("Lignes")
                        color: linesTab.checked ? Colors.navy : Colors.textSecondary
                        font.weight: linesTab.checked ? Font.DemiBold : Font.Normal
                        font.pixelSize: 13
                    }
                    Rectangle {
                        Layout.preferredWidth: 23
                        Layout.preferredHeight: 17
                        radius: 8
                        color: Colors.subtle
                        Label {
                            anchors.centerIn: parent
                            text: root.articleRows.length
                            color: Colors.textSecondary
                            font.pixelSize: 10
                        }
                    }
                }
                background: Rectangle {
                    color: linesTab.checked ? Colors.surface : "transparent"
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2
                        color: Colors.accent
                        visible: linesTab.checked
                    }
                }
            }
            C.TabButton {
                id: paymentsButton
                width: 145
                contentItem: RowLayout {
                    spacing: 7
                    Icon {
                        name: "payments"
                        color: paymentsButton.checked ? Colors.accent : Colors.textSecondary
                        Layout.preferredWidth: 17
                        Layout.preferredHeight: 17
                    }
                    Label {
                        text: qsTr("Paiement")
                        color: paymentsButton.checked ? Colors.navy : Colors.textSecondary
                        font.weight: paymentsButton.checked ? Font.DemiBold : Font.Normal
                        font.pixelSize: 13
                    }
                    Rectangle {
                        Layout.preferredWidth: 23
                        Layout.preferredHeight: 17
                        radius: 8
                        color: Colors.subtle
                        Label {
                            anchors.centerIn: parent
                            text: root.paymentRows.length
                            color: Colors.textSecondary
                            font.pixelSize: 10
                        }
                    }
                }
                background: Rectangle {
                    color: paymentsButton.checked ? Colors.surface : "transparent"
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2
                        color: Colors.accent
                        visible: paymentsButton.checked
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Colors.border
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 8
            currentIndex: tabs.currentIndex
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                SearchEntryTable {
                    id: lines
                    objectName: "newDocumentLines"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: implicitHeight
                    columns: root.lineColumns
                    rows: root.articleRows
                    searchResults: root.articleSearchResults
                    localeName: "fr_MA"
                    draftComputed: root.computedDraft
                    defaultValues: ({quantity: 1, priceHT: "0,00"})
                    addEnabled: root.canAddLine
                    addActionLabel: root.editingLine ? qsTr("Mettre à jour la ligne")
                                                     : qsTr("Ajouter la ligne")
                    rowHeight: 44
                    headerHeight: 44
                }
            }
            PaymentTab {
                id: payments
                objectName: "newDocumentPayments"
                Layout.fillWidth: true
                Layout.fillHeight: true
                payments: root.paymentRows
            }
        }
        }

        Label {
            text: root.errorMessage
            visible: text !== ""
            color: Colors.danger
            font.pixelSize: 11
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 66
            color: Colors.surface
            radius: 4
            border.color: Colors.border
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                FinancialTotal { title: qsTr("Total HT"); amountText: root.totalHTText; Layout.fillHeight: true }
                FinancialTotal { title: qsTr("TVA"); amountText: root.totalVATText; Layout.fillHeight: true }
                FinancialTotal {
                    title: qsTr("Total TTC")
                    amountText: root.totalTTCText
                    emphasized: true
                    implicitWidth: 170
                    Layout.fillHeight: true
                }
                Item { Layout.fillWidth: true }
                AzenzButton {
                    id: back
                    text: qsTr("Retour")
                    iconName: "left"
                    variant: "secondary"
                }
                AzenzButton {
                    id: save
                    objectName: "newDocumentSave"
                    text: qsTr("Enregistrer")
                    iconName: "save"
                    loading: root.busy
                }
            }
        }
        }
    }
}
