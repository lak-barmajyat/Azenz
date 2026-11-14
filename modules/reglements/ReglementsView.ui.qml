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

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label {
                text: qsTr("Règlements")
                color: Colors.navy
                font.pixelSize: 17
                font.weight: Font.Bold
            }
            Label {
                text: qsTr("Finances  >  Règlements")
                color: Colors.textSecondary
                font.pixelSize: 11
                Layout.fillWidth: true
            }
            Badge { text: qsTr("Gestion Trésorerie"); variant: "info" }
        }

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

        DataGrid {
            id: grid
            objectName: "reglementsGrid"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            rows: root.rows
            density: "compact"
            headerBackground: "#EEF2F6"
            headerForeground: Colors.textSecondary
            footerSummary: root.footerText
            footerHint: qsTr("Clic droit sur une ligne pour les options contextuelles")
            footerBackground: "#F8FAFC"
            footerTopBorder: true
            columns: [
                {key: "code", title: qsTr("CODE RÈGLEMENT"), width: 145, type: "code", sortable: false},
                {key: "tier", title: tabs.currentIndex === 1 ? qsTr("FOURNISSEUR") : qsTr("CLIENT"), width: 260, sortable: false},
                {key: "mode", title: qsTr("MODE DE RÈGLEMENT"), width: 160, type: "paymentMethod", sortable: false},
                {key: "status", title: qsTr("STATUT"), width: 100, type: "status", alignment: "center", sortable: false},
                {key: "date", title: qsTr("DATE"), width: 105, type: "date", alignment: "center", sortable: false},
                {key: "amount", title: qsTr("MONTANT (MAD)"), width: 155, type: "currency", suffix: "MAD", alignment: "right", sortable: false},
                {key: "comment", title: qsTr("COMMENTAIRE"), width: Math.max(260, grid.width - 965), sortable: false}
            ]
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
                Repeater {
                    model: [
                        {label: qsTr("TOTAL RÈGLEMENTS"), value: root.totalText, highlighted: false},
                        {label: qsTr("MONTANT AFFECTÉ"), value: root.affectedText, highlighted: false},
                        {label: qsTr("MONTANT RESTANT"), value: root.remainingText, highlighted: true}
                    ]
                    Rectangle {
                        id: totalCard
                        required property var modelData
                        Layout.preferredWidth: modelData.highlighted ? 175 : 140
                        Layout.fillHeight: true
                        radius: 4
                        color: modelData.highlighted ? Colors.navy : Colors.canvas
                        border.color: modelData.highlighted ? Colors.navy : Colors.border
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 2
                            Label { text: totalCard.modelData.label; color: totalCard.modelData.highlighted ? "#CBD5E1" : Colors.textSecondary; font.pixelSize: 9 }
                            Label { text: totalCard.modelData.value; color: totalCard.modelData.highlighted ? "#86EFAC" : Colors.text; font.pixelSize: totalCard.modelData.highlighted ? 15 : 12; font.weight: Font.Bold; tabular: true }
                        }
                    }
                }
                Item { Layout.fillWidth: true }
                AzenzButton { id: backButton; text: qsTr("Retour"); iconName: "left"; variant: "secondary"; size: "compact" }
            }
        }
    }
}
