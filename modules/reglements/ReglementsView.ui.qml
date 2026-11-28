import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../../qml/components"
import "../../qml/controls"
import "../../qml/theme"

Rectangle {
    id: root
    property var rows: []
    property int clientCount: 0
    property int supplierCount: 0
    property string totalText: "0,00 MAD"
    property string affectedText: "0,00 MAD"
    property string remainingText: "0,00 MAD"
    property string footerText: ""
    property bool canAddPayment: false
    property alias activeTab: tabs.currentIndex
    property alias filters: filters
    property alias grid: grid
    property alias newButton: newButton
    property alias editButton: editButton
    property alias deleteButton: deleteButton
    property alias duplicateButton: duplicateButton
    property alias printButton: printButton
    property alias exportButton: exportButton
    property alias backButton: backButton

    color: Colors.canvas
    LayoutMirroring.enabled: Theme.rightToLeft
    LayoutMirroring.childrenInherit: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: Colors.surface
            border.color: Colors.border
            radius: 4
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                AzenzButton { id: newButton; text: qsTr("Nouveau"); iconName: "add"; size: "compact" }
                AzenzButton { id: editButton; text: qsTr("Modifier"); iconName: "edit"; variant: "secondary"; size: "compact"; enabled: grid.selectionCount === 1 }
                AzenzButton { id: deleteButton; text: qsTr("Supprimer"); iconName: "delete"; variant: "secondary"; size: "compact"; enabled: grid.selectionCount > 0 }
                AzenzButton { id: duplicateButton; text: qsTr("Dupliquer"); iconName: "copy"; variant: "secondary"; size: "compact"; enabled: grid.selectionCount === 1 }
                AzenzButton { id: printButton; text: qsTr("Imprimer"); iconName: "print"; variant: "secondary"; size: "compact"; enabled: grid.selectionCount > 0 }
                Item { Layout.fillWidth: true }
                AzenzButton { id: exportButton; text: qsTr("Exporter Excel"); iconName: "table"; variant: "secondary"; size: "compact" }
            }
        }

        C.TabBar {
            id: tabs
            Layout.fillWidth: true
            Layout.preferredHeight: 37
            currentIndex: 0
            background: Rectangle {
                color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Colors.border }
            }
            C.TabButton {
                id: clientsTab
                width: 132
                contentItem: RowLayout {
                    spacing: 7
                    Icon { name: "users"; color: clientsTab.checked ? Colors.accent : Colors.textSecondary; Layout.preferredWidth: 17; Layout.preferredHeight: 17 }
                    Label { text: qsTr("Clients"); color: clientsTab.checked ? Colors.navy : Colors.textSecondary; font.weight: clientsTab.checked ? Font.DemiBold : Font.Normal; font.pixelSize: 13 }
                    Badge { text: root.clientCount; variant: "neutral"; Layout.preferredHeight: 17 }
                }
                background: Rectangle {
                    color: clientsTab.checked ? Colors.surface : "transparent"
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: Colors.accent; visible: clientsTab.checked }
                }
            }
            C.TabButton {
                id: suppliersTab
                width: 168
                contentItem: RowLayout {
                    spacing: 7
                    Icon { name: "truck"; color: suppliersTab.checked ? Colors.accent : Colors.textSecondary; Layout.preferredWidth: 17; Layout.preferredHeight: 17 }
                    Label { text: qsTr("Fournisseurs"); color: suppliersTab.checked ? Colors.navy : Colors.textSecondary; font.weight: suppliersTab.checked ? Font.DemiBold : Font.Normal; font.pixelSize: 13 }
                    Badge { text: root.supplierCount; variant: "neutral"; Layout.preferredHeight: 17 }
                }
                background: Rectangle {
                    color: suppliersTab.checked ? Colors.surface : "transparent"
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: Colors.accent; visible: suppliersTab.checked }
                }
            }
        }

        ReglementsFilters {
            id: filters
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            suppliers: tabs.currentIndex === 1
        }

        SearchEntryTable {
            id: grid
            objectName: "reglementsGrid"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: root.height < 600 ? 140 : 156
            rows: root.rows
            selectable: true
            keepEntryVisible: true
            showRowNumber: false
            showTypeIcon: false
            showActions: true
            actionWidth: 64
            allowEdit: false
            allowRemove: false
            requireSelection: false
            addEnabled: root.canAddPayment
            addActionLabel: qsTr("Ajouter règlement")
            localeName: "fr_MA"
            defaultValues: ({mode: qsTr("Virement Bancaire"), status: qsTr("Brouillon"),
                             date: Qt.formatDate(new Date(), "dd/MM/yyyy")})
            columns: [
                {key: "code", title: qsTr("Code règlement"), width: 135, fill: 1.2, editable: true,
                 placeholder: qsTr("REG-...")},
                {key: "tier", title: tabs.currentIndex === 1 ? qsTr("Fournisseur") : qsTr("Client"), width: 220,
                 fill: 2,
                 editable: true, placeholder: tabs.currentIndex === 1 ? qsTr("Fournisseur...") : qsTr("Client...")},
                {key: "mode", title: qsTr("Mode de règlement"), width: 150, fill: 1.7, inputType: "choice",
                 options: [qsTr("Virement Bancaire"), qsTr("Chèque"), qsTr("Traite"), qsTr("Espèces"), qsTr("Carte Bancaire")]},
                {key: "status", title: qsTr("Statut"), width: 110, fill: 1.2, inputType: "choice",
                 options: [qsTr("Brouillon"), qsTr("En attente"), qsTr("Validé")]},
                {key: "date", title: qsTr("Date"), width: 145, fill: 1.2, inputType: "date", alignment: "center"},
                {key: "amount", title: qsTr("Montant (MAD)"), width: 130, fill: 1.2, editable: true, inputType: "currency",
                 decimals: 2, suffix: "MAD", inputSuffix: "", alignment: "right", placeholder: qsTr("0,00")},
                {key: "comment", title: qsTr("Commentaire"), width: 180, fill: 1,
                 editable: true, placeholder: qsTr("Commentaire...")}
            ]
        }

        RowLayout {
            visible: root.height >= 600
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Label { text: root.footerText; color: Colors.textSecondary; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            Label { text: qsTr("Clic droit sur une ligne pour les options contextuelles"); color: Colors.textSecondary; font.pixelSize: 10 }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            color: Colors.surface
            border.color: Colors.border
            radius: 4
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10
                FinancialTotal {
                    title: qsTr("Total règlements")
                    amountText: root.totalText
                    Layout.preferredWidth: root.width < 900 ? 136 : 168
                }
                FinancialTotal {
                    title: qsTr("Montant affecté")
                    amountText: root.affectedText
                    Layout.preferredWidth: root.width < 900 ? 136 : 168
                }
                FinancialTotal {
                    title: qsTr("Montant restant")
                    amountText: root.remainingText
                    emphasized: true
                    Layout.preferredWidth: root.width < 900 ? 155 : 170
                }
                Item { Layout.fillWidth: true }
                AzenzButton { id: backButton; text: qsTr("Retour"); iconName: "left"; variant: "secondary"; size: "compact" }
            }
        }
    }
}
