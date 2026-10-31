import QtQuick
import "../theme"

Rectangle {
    id: root
    property string density: Theme.densityFor(parent)
    property int padding: 16
    default property alias content: body.data
    color: Colors.surface
    radius: 6
    border.color: Colors.border
    implicitWidth: 480
    implicitHeight: body.childrenRect.height + padding * 2
    Item {
        id: body
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
