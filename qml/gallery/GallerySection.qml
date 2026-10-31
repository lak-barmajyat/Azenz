import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string title: ""
    property string subtitle: ""
    default property alias content: body.data
    color: "white"
    radius: 8
    border.color: Colors.border
    implicitHeight: body.implicitHeight + heading.implicitHeight + 48
    implicitWidth: 900
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16
        ColumnLayout {
            id: heading
            spacing: 4
            Layout.fillWidth: true
            Label {
                text: root.title
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: Colors.navy
                Layout.fillWidth: true
            }
            Label {
                text: root.subtitle
                visible: text !== ""
                color: Colors.textSecondary
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
        ColumnLayout {
            id: body
            spacing: 12
            Layout.fillWidth: true
        }
    }
}
