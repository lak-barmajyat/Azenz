import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string variant: "info"
    property string title: "Information"
    property string message: ""
    property string actionText: ""
    property bool closeButton: true
    signal actionTriggered
    signal dismissed
    implicitWidth: 600
    implicitHeight: Math.max(48, content.implicitHeight + 24)
    color: Colors.tint(variant)
    radius: 4
    border.color: Qt.rgba(Colors.semantic(variant).r, Colors.semantic(variant).g, Colors.semantic(variant).b, 0.25)
    Accessible.role: Accessible.AlertMessage
    Accessible.name: title + ". " + message
    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        Icon {
            name: root.variant === "success" ? "success" : root.variant === "warning" ? "warning" : root.variant === "error" || root.variant === "danger" ? "error" : "info"
            color: Colors.semantic(root.variant)
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            Layout.alignment: Qt.AlignTop
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Label {
                text: root.title
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Colors.ink(root.variant)
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Label {
                text: root.message
                visible: text !== ""
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                Layout.fillWidth: true
            }
        }
        AzenzButton {
            text: root.actionText
            visible: text !== ""
            variant: "ghost"
            size: "compact"
            onClicked: root.actionTriggered()
        }
        IconButton {
            visible: root.closeButton
            iconName: "close"
            tooltip: qsTr("Fermer")
            size: "compact"
            onClicked: {
                root.visible = false;
                root.dismissed();
            }
        }
    }
}
