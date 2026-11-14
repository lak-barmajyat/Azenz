import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string title: "Total HT"
    property real amount: 0
    property string amountText: ""
    property bool emphasized: false
    implicitWidth: 168
    implicitHeight: 48
    radius: 4
    color: emphasized ? "#F0F6FC" : Colors.canvas
    border.color: emphasized ? Colors.navy : Colors.border
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 3
        Label {
            text: root.title.toUpperCase()
            font.pixelSize: 9
            font.weight: Font.Bold
            color: root.emphasized ? Colors.navy : Colors.textSecondary
        }
        Label {
            text: root.amountText || root.amount.toLocaleString(Qt.locale("fr_FR"), "f", 2) + " MAD"
            tabular: true
            font.pixelSize: root.emphasized ? 15 : 13
            font.weight: Font.Bold
            color: root.emphasized ? Colors.navy : Colors.text
            Layout.fillWidth: true
        }
    }
}
