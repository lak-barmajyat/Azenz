import QtQuick
import "../controls"

Item {
    id: root
    property alias checked: checkbox.checked
    property alias checkState: checkbox.checkState
    property alias tristate: checkbox.tristate
    signal toggled
    implicitWidth: 36
    implicitHeight: 28
    AzenzCheckBox {
        id: checkbox
        anchors.centerIn: parent
        width: 16
        height: 24
        nextCheckState: function () {
            return checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked;
        }
        onToggled: root.toggled()
    }
}
