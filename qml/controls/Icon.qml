import QtQuick
import "../theme"

// Inline vector icons; no network or icon-font dependency at runtime.
Item {
    id: root
    property string name: "info"
    property color color: Colors.textSecondary
    implicitWidth: 18
    implicitHeight: 18
    Image {
        anchors.fill: parent
        source: "data:image/svg+xml;utf8," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="' + root.color + '" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">' + (Icons.paths[root.name] || Icons.paths.info) + '</svg>')
        sourceSize: Qt.size(root.width * 2, root.height * 2)
    }
}
