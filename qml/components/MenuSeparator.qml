import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.MenuSeparator {
    topPadding: 4
    bottomPadding: 4
    contentItem: Rectangle {
        implicitWidth: 200
        implicitHeight: 1
        color: Colors.borderStrong
    }
}
