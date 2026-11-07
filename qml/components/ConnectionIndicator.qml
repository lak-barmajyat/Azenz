import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

RowLayout {
    id: root
    property string connectionState: "connected"
    property string text: connectionState === "connected" ? qsTr("Connecté") : connectionState === "connecting" ? qsTr("Connexion…") : qsTr("Déconnecté")
    spacing: 6
    implicitHeight: 20
    Rectangle {
        width: 6
        height: 6
        radius: 3
        color: root.connectionState === "connected" ? Colors.success : root.connectionState === "connecting" ? Colors.warning : Colors.danger
    }
    Label {
        text: root.text
        color: Colors.textSecondary
        font.pixelSize: 11
    }
}
