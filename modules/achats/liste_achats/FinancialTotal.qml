import QtQuick
import QtQuick.Layouts
import "../../../qml/controls"
import "../../../qml/theme"

Rectangle {
    id: root
    property string title: qsTr("Total HT")
    property real amount: 0
    property bool emphasized: false
    implicitWidth: 168
    implicitHeight: 48
    radius: 4
    color: emphasized ? Colors.rowSelected : Colors.canvas
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
            text: root.amount.toLocaleString(Qt.locale("fr_FR"), "f", 2) + qsTr(" MAD")
            tabular: true
            font.pixelSize: root.emphasized ? Typography.subtitle : Typography.body
            font.weight: Font.Bold
            color: root.emphasized ? Colors.navy : Colors.text
            Layout.fillWidth: true
        }
    }
}
