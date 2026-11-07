import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../controls"
import "../theme"

C.Dialog {
    id: root
    property string dialogType: "confirmation" // confirmation, destructive, warning, information, error
    property string size: "small"
    property string message: qsTr("Souhaitez-vous continuer cette opération ?")
    property string supportingMessage: ""
    property bool showIcon: true
    property bool closeButton: true
    property bool showCancel: dialogType !== "information"
    property string confirmText: dialogType === "destructive" ? qsTr("Supprimer") : dialogType === "information" ? qsTr("Compris") : dialogType === "error" ? qsTr("Réessayer") : qsTr("Confirmer")
    property string cancelText: qsTr("Annuler")
    property Item returnFocusItem: null
    width: Math.min(parent ? parent.width - 32 : 420, size === "medium" ? 540 : 420)
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? Math.max(16, (parent.height - height) / 2) : 0
    modal: true
    focus: true
    padding: 16
    margins: 16
    popupType: C.Popup.Item
    closePolicy: C.Popup.CloseOnEscape
    title: qsTr("Confirmer l'action")
    onAboutToShow: {
        if (root.parent && root.parent.Window.window)
            returnFocusItem = root.parent.Window.window.activeFocusItem;
    }
    onOpened: {
        if (dialogType === "destructive" && showCancel)
            cancel.forceActiveFocus();
        else
            confirm.forceActiveFocus();
    }
    onClosed: if (returnFocusItem)
        returnFocusItem.forceActiveFocus()
    background: Rectangle {
        color: Colors.surface
        radius: 6
        border.color: Colors.borderStrong
    }
    C.Overlay.modal: Rectangle {
        color: Colors.scrim
    }
    header: Rectangle {
        implicitHeight: 40
        color: "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 8
            Icon {
                visible: root.showIcon
                name: root.dialogType === "destructive" || root.dialogType === "warning" ? "warning" : root.dialogType === "error" ? "error" : "info"
                color: root.dialogType === "destructive" || root.dialogType === "error" ? Colors.danger : root.dialogType === "warning" ? Colors.warning : Colors.navy
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
            }
            Label {
                text: root.title
                font.weight: Font.DemiBold
                font.pixelSize: 15
                Layout.fillWidth: true
            }
            IconButton {
                id: close
                visible: root.closeButton
                iconName: "close"
                tooltip: qsTr("Fermer")
                onClicked: root.reject()
                KeyNavigation.tab: root.showCancel ? cancel : confirm
                KeyNavigation.backtab: confirm
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Colors.border
        }
    }
    contentItem: ColumnLayout {
        spacing: 12
        Label {
            text: root.message
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        Label {
            text: root.supportingMessage
            visible: text !== ""
            wrapMode: Text.WordWrap
            color: Colors.textSecondary
            font.pixelSize: 12
            Layout.fillWidth: true
        }
    }
    footer: Item {
        implicitHeight: 64
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            AzenzButton {
                id: cancel
                text: root.cancelText
                variant: "secondary"
                visible: root.showCancel
                onClicked: root.reject()
                KeyNavigation.tab: confirm
                KeyNavigation.backtab: root.closeButton ? close : confirm
            }
            AzenzButton {
                id: confirm
                text: root.confirmText
                variant: root.dialogType === "destructive" ? "danger" : "primary"
                onClicked: root.accept()
                KeyNavigation.tab: root.closeButton ? close : root.showCancel ? cancel : confirm
                KeyNavigation.backtab: root.showCancel ? cancel : root.closeButton ? close : confirm
            }
        }
    }
}
