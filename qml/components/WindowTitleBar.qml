import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property bool dark: false
    property string title: "AZENZ ERP Desktop"
    property string subtitle: ""
    signal minimizeRequested
    signal maximizeRequested
    signal closeRequested
    implicitHeight: dark ? 32 : 36
    color: dark ? "#091C2E" : "white"
    border.color: dark ? "#071928" : Colors.border
    MouseArea {
        anchors.fill: parent
        onPressed: if (root.Window.window)
            root.Window.window.startSystemMove()
        onDoubleClicked: root.maximizeRequested()
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        spacing: 8
        Logo {
            variant: root.dark ? "dark" : "symbol"
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
        Label {
            text: root.title
            color: root.dark ? "white" : Colors.textSecondary
            font.pixelSize: 12
            font.weight: root.dark ? Font.DemiBold : Font.Normal
        }
        Label {
            text: root.subtitle
            visible: text !== ""
            color: "#94A3B8"
            font.pixelSize: 11
            Layout.fillWidth: true
        }
        Item {
            Layout.fillWidth: true
            visible: root.subtitle === ""
        }
        Repeater {
            model: ["minus", "maximize", "close"]
            Rectangle {
                id: windowButton
                required property string modelData
                Layout.preferredWidth: 44
                Layout.fillHeight: true
                color: mouse.containsMouse ? (modelData === "close" ? Colors.danger : root.dark ? "#294459" : Colors.subtle) : "transparent"
                Icon {
                    anchors.centerIn: parent
                    name: windowButton.modelData
                    width: 14
                    height: 14
                    color: root.dark || (windowButton.modelData === "close" && mouse.containsMouse) ? "#CBD5E1" : Colors.textSecondary
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (windowButton.modelData === "minus")
                            root.minimizeRequested();
                        else if (windowButton.modelData === "maximize")
                            root.maximizeRequested();
                        else
                            root.closeRequested();
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: modelData === "minus" ? qsTr("Réduire") : modelData === "maximize" ? qsTr("Agrandir / restaurer") : qsTr("Fermer")
                Accessible.onPressAction: {
                    if (modelData === "minus")
                        root.minimizeRequested();
                    else if (modelData === "maximize")
                        root.maximizeRequested();
                    else
                        root.closeRequested();
                }
            }
        }
    }
}
