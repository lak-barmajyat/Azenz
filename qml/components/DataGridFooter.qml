import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property int recordCount: 0
    property int selectionCount: 0
    property int totalCount: recordCount
    implicitHeight: 28
    color: Colors.canvas
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        Label {
            text: qsTr("Lignes : %1 • Sélections : %2 • Affichage continu (%3 affichées sur %4)").arg(root.recordCount).arg(root.selectionCount).arg(root.recordCount).arg(root.totalCount)
            font.pixelSize: 11
            color: Colors.textSecondary
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Défilement continu")
            font.pixelSize: 11
            color: Colors.textSecondary
            visible: root.width > 680
        }
    }
}
