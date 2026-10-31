pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import "../controls"
import "../theme"

C.MenuBar {
    id: root
    property bool dark: false
    signal commandTriggered(string command)
    implicitHeight: 32
    delegate: C.MenuBarItem {
        id: item
        implicitHeight: 32
        contentItem: Label {
            text: item.text
            color: root.dark ? "#E2E8F0" : Colors.text
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            color: item.highlighted || item.hovered ? root.dark ? Colors.navHover : Colors.rowHover : "transparent"
            border.color: item.visualFocus ? Colors.accent : "transparent"
            radius: 3
        }
    }
    background: Rectangle {
        color: root.dark ? "#0B243A" : Colors.surface
    }
    DropdownMenu {
        title: qsTr("Fichier")
        DropdownMenuItem {
            text: qsTr("Nouveau document")
            iconName: "add"
            shortcutText: "Ctrl+N"
            onTriggered: root.commandTriggered("new")
        }
        DropdownMenuItem {
            text: qsTr("Ouvrir…")
            iconName: "open"
            shortcutText: "Ctrl+O"
            onTriggered: root.commandTriggered("open")
        }
        DropdownMenuItem {
            text: qsTr("Enregistrer")
            iconName: "save"
            shortcutText: "Ctrl+S"
            onTriggered: root.commandTriggered("save")
        }
        DropdownMenuItem {
            text: qsTr("Imprimer")
            iconName: "print"
            shortcutText: "Ctrl+P"
            onTriggered: root.commandTriggered("print")
        }
        MenuSeparator {}
        DropdownMenuItem {
            text: qsTr("Quitter")
            iconName: "logout"
            shortcutText: "Alt+F4"
            onTriggered: root.commandTriggered("quit")
        }
    }
    DropdownMenu {
        title: qsTr("Édition")
        DropdownMenuItem {
            text: qsTr("Annuler")
            onTriggered: root.commandTriggered("undo")
        }
        DropdownMenuItem {
            text: qsTr("Rétablir")
            onTriggered: root.commandTriggered("redo")
        }
    }
    DropdownMenu {
        title: qsTr("Affichage")
        DropdownMenuItem {
            text: qsTr("Volet latéral")
            checkable: true
            checked: true
            onTriggered: root.commandTriggered("sidebar")
        }
    }
    DropdownMenu {
        title: qsTr("Outils")
        DropdownMenuItem {
            text: qsTr("Préférences")
            iconName: "settings"
            onTriggered: root.commandTriggered("settings")
        }
    }
    DropdownMenu {
        title: qsTr("Aide")
        DropdownMenuItem {
            text: qsTr("À propos d'AZENZ")
            iconName: "info"
            onTriggered: root.commandTriggered("about")
        }
    }
}
