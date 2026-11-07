import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string text: "Neutral"
    property string variant: "neutral"
    property bool filled: false
    property bool dot: false
    implicitHeight: 20
    implicitWidth: contents.implicitWidth + 16
    radius: 10
    color: filled ? Colors.ink(variant) : Colors.tint(variant)
    border.color: filled ? "transparent" : Qt.rgba(Colors.semantic(variant).r, Colors.semantic(variant).g, Colors.semantic(variant).b, 0.2)
    Accessible.role: Accessible.StaticText
    Accessible.name: text
    RowLayout {
        id: contents
        anchors.centerIn: parent
        spacing: 5
        Rectangle {
            visible: root.dot
            width: 6
            height: 6
            radius: 3
            color: root.filled ? "white" : Colors.semantic(root.variant)
        }
        Label {
            text: root.text
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: root.filled ? "white" : Colors.ink(root.variant)
        }
    }
}
