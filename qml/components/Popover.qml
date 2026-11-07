import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.Popup {
    width: 300
    padding: 12
    margins: 8
    focus: true
    modal: false
    popupType: C.Popup.Item
    closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutsideParent
    background: Rectangle {
        color: Colors.surface
        radius: 6
        border.color: Colors.borderStrong
    }
}
