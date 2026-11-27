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
    property var suppliers: []
    property var articleSearchResults: ({
            field: "",
            query: "",
            items: []
        })
    property bool articleSearchBusy: false
    property var computedDraft: ({})
    property var computedEdit: ({})
    property var documentTypes: []
    property bool lookupsBusy: false
    property bool codeBusy: false
    property var lineColumns: [
        {
            key: "reference",
            title: qsTr("Référence"),
            width: 130,
            searchable: true,
            placeholder: qsTr("Référence...")
        },
        {
            key: "description",
            title: qsTr("Désignation"),
            width: 260,
            fill: 1,
            searchable: true,
            placeholder: qsTr("Rechercher ou saisir un article...")
        },
        {
            key: "quantity",
            title: qsTr("Quantité"),
            width: 78,
            editable: true,
            inputType: "number",
            alignment: "right",
            defaultValue: 1
        },
        {
            key: "priceHT",
            title: qsTr("Prix HT"),
            width: 110,
            editable: true,
            inputType: "currency",
            alignment: "right",
            decimals: 2
        },
        {
            key: "priceTTC",
            title: qsTr("Prix TTC"),
            width: 110,
            alignment: "right",
            decimals: 2
        },
        {
            key: "totalHT",
            title: qsTr("Total HT"),
            width: 120,
            alignment: "right",
            decimals: 2
        },
        {
            key: "vat",
            title: qsTr("TVA"),
            width: 75,
            alignment: "center",
            suffix: "%"
        },
        {
            key: "totalTTC",
            title: qsTr("Total TTC"),
            width: 125,
            alignment: "right",
            decimals: 2
        }
    ]
    property string totalHTText: qsTr("0,00 MAD")
    property string totalVATText: qsTr("0,00 MAD")
    property string totalTTCText: qsTr("0,00 MAD")
    property string errorMessage: ""
    property bool busy: false
    property bool canSave: true
    property string pageTitle: qsTr("Nouveau document")
    property bool canAddLine: false
    property bool canUpdateLine: false
    property alias supplierCode: supplierCode.text
    property alias supplierPicker: supplier
    property alias documentCode: documentCode.text
    property alias documentCodeField: documentCode
    property alias documentType: documentType
    property alias documentDate: documentDate
    property alias activeTab: tabs.currentIndex
    property alias linesTable: lines
    property alias paymentsTab: paymentPanel
    property alias backButton: back
    property alias saveButton: save

    color: Colors.canvas
    LayoutMirroring.enabled: Theme.rightToLeft
    LayoutMirroring.childrenInherit: true

    Item {
        anchors.fill: parent
        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 12
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: root.pageTitle
                    color: Colors.navy
                    font.pixelSize: Typography.section
                    font.weight: Font.Bold
                }
                Label {
                    text: qsTr("Documents  >  Achats  >  %1").arg(root.pageTitle)
                    color: Colors.textSecondary
                    font.pixelSize: Typography.micro
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Badge {
                    text: qsTr("Mode saisie") + "  " + documentType.currentText
                    variant: "info"
                }
            }

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
                        Label {
                            text: qsTr("Code Fournisseur")
                            font.pixelSize: 10
                            color: Colors.textSecondary
                        }
                        AzenzTextField {
                            id: supplierCode
                            objectName: "nouveauDocAchatFournisseurCode"
                            Layout.fillWidth: true
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: documentFields.columns === 5 ? 340 : 170
                        Label {
                            text: qsTr("Fournisseur")
                            font.pixelSize: 10
                            color: Colors.textSecondary
                        }
                        AzenzComboBox {
                            id: supplier
                            objectName: "nouveauDocAchatFournisseur"
                            searchable: true
                            model: root.suppliers
                            enabled: !root.lookupsBusy
                            Layout.fillWidth: true
                            placeholderText: qsTr("Choisir un fournisseur")
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 170
                        Label {
                            text: qsTr("Code Document")
                            font.pixelSize: 10
                            color: Colors.textSecondary
                        }
                        AzenzTextField {
                            id: documentCode
                            objectName: "nouveauDocAchatCode"
                            Layout.fillWidth: true
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 170
                        Label {
                            text: qsTr("Type Document")
                            font.pixelSize: 10
                            color: Colors.textSecondary
                        }
                        AzenzComboBox {
                            id: documentType
                            model: root.documentTypes
                            enabled: !root.lookupsBusy
                            currentIndex: root.documentTypes.length > 0 ? 0 : -1
                            Layout.fillWidth: true
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 170
                        Label {
                            text: qsTr("Date")
                            font.pixelSize: 10
                            color: Colors.textSecondary
                        }
                        DateInput {
                            id: documentDate
                            objectName: "nouveauDocAchatDate"
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            ColumnLayout {
                id: tabWidget
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
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
                                font.pixelSize: Typography.body
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
                                font.pixelSize: Typography.body
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
                    Layout.minimumHeight: 0
                    Layout.topMargin: 8
                    currentIndex: tabs.currentIndex
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 0
                        SearchEntryTable {
                            id: lines
                            objectName: "nouveauDocAchatLines"
                            anchors.fill: parent
                            columns: root.lineColumns
                            rows: root.articleRows
                            searchResults: root.articleSearchResults
                            searchBusy: root.articleSearchBusy
                            localeName: "fr_MA"
                            draftComputed: root.computedDraft
                            editComputed: root.computedEdit
                            defaultValues: ({
                                    quantity: 1,
                                    priceHT: "0,00"
                                })
                            addEnabled: root.canAddLine
                            editEnabled: root.canUpdateLine
                            rowHeight: 44
                            headerHeight: 44
                        }
                    }
                    Flickable {
                        id: paymentScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 0
                        contentWidth: width
                        contentHeight: paymentPanel.height
                        flickableDirection: Flickable.VerticalFlick
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true
                        C.ScrollBar.vertical: AzenzScrollBar {}
                        ColumnLayout {
                            id: paymentPanel
                            property var payments: root.paymentRows
                            objectName: "nouveauDocAchatPayments"
                            width: paymentScroll.width
                            height: Math.max(paymentScroll.height, implicitHeight)
                            property var paymentMethods: [qsTr("Virement Bancaire"), qsTr("Chèque"), qsTr("Traite"), qsTr("Espèces"), qsTr("Carte Bancaire")]
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
                                        suffix: qsTr("MAD")
                                        text: "0,00"
                                        Layout.preferredWidth: 130
                                    }
                                    Label {
                                        text: qsTr("Remise commerciale globale appliquée au document (affecte le Total TTC net à payer)")
                                        color: Colors.textSecondary
                                        font.italic: true
                                        font.pixelSize: Typography.micro
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
                                        Label {
                                            text: qsTr("Référence")
                                            font.pixelSize: 10
                                            color: Colors.textSecondary
                                        }
                                        AzenzTextField {
                                            id: reference
                                            Layout.fillWidth: true
                                            placeholderText: qsTr("Référence")
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: paymentFields.columns === 6 ? 390 : 160
                                        Label {
                                            text: qsTr("Description")
                                            font.pixelSize: 10
                                            color: Colors.textSecondary
                                        }
                                        AzenzTextField {
                                            id: description
                                            Layout.fillWidth: true
                                            placeholderText: qsTr("Description du règlement")
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 130
                                        Label {
                                            text: qsTr("Montant (MAD)")
                                            font.pixelSize: 10
                                            color: Colors.textSecondary
                                        }
                                        AzenzTextField {
                                            id: amount
                                            inputType: "currency"
                                            suffix: ""
                                            Layout.fillWidth: true
                                            placeholderText: qsTr("0,00")
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 130
                                        Label {
                                            text: qsTr("Date")
                                            font.pixelSize: 10
                                            color: Colors.textSecondary
                                        }
                                        DateInput {
                                            id: paymentDate
                                            Layout.fillWidth: true
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 175
                                        Label {
                                            text: qsTr("Mode de règlement")
                                            font.pixelSize: 10
                                            color: Colors.textSecondary
                                        }
                                        AzenzComboBox {
                                            id: method
                                            Layout.fillWidth: true
                                            model: paymentPanel.paymentMethods
                                            currentIndex: 0
                                        }
                                    }
                                    AzenzButton {
                                        id: add
                                        text: paymentPanel.editingPayment ? qsTr("Mettre à jour") : qsTr("Ajouter règlement")
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
                                Layout.preferredHeight: paymentPanel.payments.length === 0 ? 132 : 70 + paymentPanel.payments.length * 28
                                Layout.minimumHeight: paymentPanel.payments.length === 0 ? 132 : 126
                                rows: paymentPanel.payments
                                selectable: false
                                density: "compact"
                                compactEmptyState: true
                                emptyTitle: qsTr("Aucun règlement enregistré")
                                footerSummary: paymentPanel.payments.length === 1 ? qsTr("1 règlement enregistré") : qsTr("%1 règlements enregistrés").arg(paymentPanel.payments.length)
                                footerHint: paymentPanel.payments.length > 0 ? qsTr("Clic droit sur une ligne pour les options contextuelles") : ""
                                footerBackground: Colors.canvas
                                footerTopBorder: true
                                columns: [
                                    {
                                        key: "code",
                                        title: qsTr("Code règlement"),
                                        width: 145,
                                        type: "code",
                                        sortable: false
                                    },
                                    {
                                        key: "description",
                                        title: qsTr("Description"),
                                        width: Math.max(260, paymentGrid.width - 565),
                                        sortable: false
                                    },
                                    {
                                        key: "amountDisplay",
                                        title: qsTr("Montant"),
                                        width: 125,
                                        alignment: "right",
                                        sortable: false
                                    },
                                    {
                                        key: "dateDisplay",
                                        title: qsTr("Date"),
                                        width: 105,
                                        alignment: "center",
                                        sortable: false
                                    },
                                    {
                                        key: "method",
                                        title: qsTr("Mode"),
                                        width: 170,
                                        sortable: false
                                    }
                                ]
                            }
                        }
                    }
                }
            }

            Label {
                text: root.errorMessage
                visible: text !== ""
                color: Colors.danger
                font.pixelSize: Typography.micro
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
                    FinancialTotal {
                        title: qsTr("Total HT")
                        amountText: root.totalHTText
                        Layout.preferredWidth: root.width < 900 ? 136 : 168
                        Layout.fillHeight: true
                    }
                    FinancialTotal {
                        title: qsTr("TVA")
                        amountText: root.totalVATText
                        Layout.preferredWidth: root.width < 900 ? 136 : 168
                        Layout.fillHeight: true
                    }
                    FinancialTotal {
                        title: qsTr("Total TTC")
                        amountText: root.totalTTCText
                        emphasized: true
                        Layout.preferredWidth: root.width < 900 ? 155 : 170
                        Layout.fillHeight: true
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    AzenzButton {
                        id: back
                        text: qsTr("Retour")
                        iconName: "left"
                        variant: "secondary"
                    }
                    AzenzButton {
                        id: save
                        objectName: "nouveauDocAchatSave"
                        text: qsTr("Enregistrer")
                        iconName: "save"
                        loading: root.busy
                        enabled: !root.busy && !root.codeBusy && root.canSave
                    }
                }
            }
        }
    }
}
