pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root
    property string variant: "table" // table, textBlock, form
    property int rows: variant === "table" ? 5 : 3
    property bool animated: false
    implicitWidth: 500
    implicitHeight: variant === "form" ? rows * 56 + 24 : variant === "table" ? rows * 28 + 24 : rows * 20 + 24
    Accessible.role: Accessible.StaticText
    Accessible.name: qsTr("Chargement des données…")
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: root.variant === "form" ? 12 : 8
        Repeater {
            model: root.rows
            ColumnLayout {
                required property int index
                Layout.fillWidth: true
                spacing: 6
                Rectangle {
                    visible: root.variant === "form"
                    width: 90
                    height: 8
                    radius: 3
                    color: Colors.border
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Repeater {
                        model: root.variant === "table" ? 5 : 1
                        Rectangle {
                            required property int index
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.variant === "form" ? 28 : 12
                            Layout.maximumWidth: root.variant === "textBlock" ? root.width * 0.75 : Infinity
                            radius: 3
                            color: Colors.subtle
                        }
                    }
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
    SequentialAnimation on opacity {
        running: root.visible && root.animated && !Theme.reducedMotion
        loops: Animation.Infinite
        NumberAnimation {
            to: 0.5
            duration: 800
        }
        NumberAnimation {
            to: 1
            duration: 800
        }
    }
}
