pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.Menu {
    id: root
    property var targetRecord: null
    width: 260
    padding: 4
    margins: 8
    popupType: C.Popup.Item
    closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutside
    delegate: ContextMenuItem {}
    background: Rectangle {
        color: Colors.surface
        radius: 6
        border.color: Colors.borderStrong
    }
}
