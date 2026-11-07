import QtQuick
import "../controls"

AzenzButton {
    id: root
    property alias menu: dropdown
    variant: "toolbar"
    iconName: "more"
    tooltip: qsTr("Autres actions")
    implicitWidth: 32
    onClicked: dropdown.popup(root, 0, root.height)
    DropdownMenu {
        id: dropdown
    }
}
