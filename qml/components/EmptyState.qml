import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Item {
    id: root
    property string variant: "noData"
    property string iconName: variant === "noResults" ? "search" : "empty"
    property string title: variant === "noResults" ? qsTr("Aucun résultat") : qsTr("Aucune donnée disponible")
    property string description: variant === "noResults" ? qsTr("Aucun document ne correspond aux filtres sélectionnés.") : qsTr("Les éléments apparaîtront ici une fois créés.")
    property string actionText: ""
    signal actionTriggered
    implicitWidth: 400
    implicitHeight: 200
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.max(0, Math.min(400, parent.width - 32))
        spacing: 10
        Icon {
            name: root.iconName
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignHCenter
        }
        Label {
            text: root.title
            font.weight: Font.DemiBold
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        Label {
            text: root.description
            color: Colors.textSecondary
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        AzenzButton {
            text: root.actionText
            visible: text !== ""
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.actionTriggered()
        }
    }
}
