import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string label: "Chiffre d'affaires"
    property string value: "149 400,00 MAD"
    property string trend: "+12%"
    property string iconName: "money"
    property bool positive: true
    implicitWidth: 240
    implicitHeight: 96
    color: "white"
    radius: 6
    border.color: Colors.border
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: root.label
                color: Colors.textSecondary
                font.pixelSize: 12
                Layout.fillWidth: true
            }
            Icon {
                name: root.iconName
                color: Colors.navy
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: root.value
                font.pixelSize: 20
                font.weight: Font.Bold
                tabular: true
                Layout.fillWidth: true
            }
            Badge {
                text: root.trend
                visible: text !== ""
                variant: root.positive ? "success" : "danger"
            }
        }
    }
}
