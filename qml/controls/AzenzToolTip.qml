import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.ToolTip {
    id: root
    property string placement: "top"
    delay: Theme.tooltipDelay
    timeout: -1
    padding: 6
    implicitHeight: 24
    margins: 8
    x: !parent ? 0 : placement === "left" ? -width - 6 : placement === "right" ? parent.width + 6 : (parent.width - width) / 2
    y: !parent ? 0 : placement === "bottom" ? parent.height + 6 : placement === "left" || placement === "right" ? (parent.height - height) / 2 : -height - 6
    closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutsideParent
    contentItem: Label {
        text: root.text
        color: "white"
        font.pixelSize: 11
    }
    background: Rectangle {
        color: Colors.navy
        radius: 4
    }
}
