import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Item {
    id: root
    property string companyName: "Atlas Distribution"
    property string branchName: "Casablanca • Dépôt Central"
    property string initials: "AD"
    property url logoSource: ""
    property bool collapsed: false
    signal clicked
    implicitWidth: collapsed ? 56 : 224
    implicitHeight: collapsed ? 56 : 72
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        Rectangle {
            width: 30
            height: 30
            radius: 4
            color: "#2A5275"
            Label {
                anchors.centerIn: parent
                text: root.initials
                color: "white"
                font.weight: Font.DemiBold
                visible: root.logoSource.toString() === ""
            }
            Image {
                anchors.fill: parent
                source: root.logoSource
                fillMode: Image.PreserveAspectFit
            }
        }
        ColumnLayout {
            visible: !root.collapsed
            Layout.fillWidth: true
            spacing: 2
            Label {
                text: root.companyName
                color: "white"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            Label {
                text: root.branchName
                color: "#CBD5E1"
                font.pixelSize: 10
                Layout.fillWidth: true
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
