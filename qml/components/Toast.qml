import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string variant: "success"
    property string title: qsTr("Opération terminée")
    property string message: ""
    property string actionText: ""
    property bool closeButton: true
    property bool persistent: variant === "warning" || variant === "error" || actionText !== ""
    property int duration: 5000
    property bool closing: false
    property bool entered: false
    property real slideOffset: 24
    opacity: 0
    transform: Translate { x: root.slideOffset }
    function dismiss() {
        if (closing)
            return;
        closing = true;
        entrance.stop();
        departure.start();
    }
    Component.onCompleted: entrance.start()
    ParallelAnimation {
        id: entrance
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 220 }
        NumberAnimation { target: root; property: "slideOffset"; to: 0; duration: 220; easing.type: Easing.OutCubic }
        onFinished: root.entered = true
    }
    SequentialAnimation {
        id: departure
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0; duration: 180 }
            NumberAnimation { target: root; property: "slideOffset"; to: 24; duration: 180; easing.type: Easing.InCubic }
        }
        ScriptAction { script: root.dismissed() }
    }
    signal dismissed
    signal actionTriggered
    implicitWidth: 380
    implicitHeight: content.implicitHeight + 24
    color: "white"
    radius: 6
    border.color: Colors.borderStrong
    Accessible.role: Accessible.AlertMessage
    Accessible.name: title + ". " + message
    Rectangle {
        width: 3
        height: parent.height - 12
        y: 6
        radius: 1
        color: Colors.semantic(root.variant)
    }
    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        Icon {
            name: root.variant === "success" ? "success" : root.variant === "warning" ? "warning" : root.variant === "error" ? "error" : "info"
            color: Colors.semantic(root.variant)
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Label {
                text: root.title
                font.pixelSize: 12
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Label {
                text: root.message
                visible: text !== ""
                font.pixelSize: 12
                color: Colors.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            AzenzButton {
                text: root.actionText
                visible: text !== ""
                size: "compact"
                variant: "ghost"
                onClicked: root.actionTriggered()
            }
        }
        IconButton {
            iconName: "close"
            tooltip: qsTr("Fermer")
            visible: root.closeButton
            size: "compact"
            Layout.alignment: Qt.AlignTop
            onClicked: root.dismiss()
        }
    }
    HoverHandler {
        id: hover
    }
    Timer {
        interval: root.duration
        running: root.visible && root.entered && !root.closing && !root.persistent && !hover.hovered && !root.activeFocus
        onTriggered: root.dismiss()
    }
}
