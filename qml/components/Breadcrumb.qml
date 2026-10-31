pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

RowLayout {
    id: root
    property var items: [qsTr("Documents"), qsTr("Ventes")]
    signal navigate(int index)
    spacing: 4
    Repeater {
        model: root.items
        RowLayout {
            required property string modelData
            required property int index
            spacing: 4
            AzenzButton {
                text: modelData
                variant: "ghost"
                size: "compact"
                visible: index < root.items.length - 1
                onClicked: root.navigate(index)
            }
            Label {
                text: modelData
                font.weight: Font.DemiBold
                visible: index === root.items.length - 1
            }
            Icon {
                name: "right"
                width: 14
                height: 14
                visible: index < root.items.length - 1
            }
        }
    }
}
