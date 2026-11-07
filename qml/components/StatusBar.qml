import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string connectionState: "connected"
    property string userName: "Admin"
    property string companyName: "Atlas Distribution"
    property string fiscalYear: "2026"
    property string language: "FR"
    property string version: "1.0"
    implicitHeight: 28
    implicitWidth: 1000
    color: Colors.canvas
    Rectangle {
        width: parent.width
        height: 1
        color: Colors.border
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12
        ConnectionIndicator {
            connectionState: root.connectionState
        }
        ToolbarSeparator {
            implicitHeight: 14
        }
        Label {
            text: root.userName
            font.pixelSize: 11
            color: Colors.textSecondary
        }
        Label {
            text: root.companyName
            font.pixelSize: 11
            color: Colors.textSecondary
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Exercice %1").arg(root.fiscalYear)
            font.pixelSize: 11
            color: Colors.textSecondary
        }
        Label {
            text: root.language
            font.pixelSize: 11
            color: Colors.textSecondary
        }
        Label {
            text: "v" + root.version
            font.pixelSize: 11
            color: Colors.textSecondary
        }
    }
}
