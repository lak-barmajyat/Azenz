import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property int recordCount: 0
    property int selectionCount: 0
    property int totalCount: recordCount
    property string summaryText: qsTr("Lignes : %1 • Sélections : %2 • Affichage continu (%3 affichées sur %4)").arg(recordCount).arg(selectionCount).arg(recordCount).arg(totalCount)
    property string hintText: qsTr("Défilement continu")
    property color backgroundColor: Colors.canvas
    property bool showTopBorder: false
    implicitHeight: 28
    color: backgroundColor
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Colors.border
        visible: root.showTopBorder
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        Label {
            text: root.summaryText
            font.pixelSize: 11
            color: Colors.textSecondary
            Layout.fillWidth: true
        }
        Label {
            text: root.hintText
            font.pixelSize: 11
            color: Colors.textSecondary
            visible: root.width > 680
        }
    }
}
