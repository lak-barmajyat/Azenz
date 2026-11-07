import QtQuick
import QtQuick.Layouts
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string density: Theme.densityFor(parent)
    property int selectionCount: 0
    property var actionAvailability: ({}) // Per-screen permissions override the visual defaults.
    readonly property string selectionContext: selectionCount === 0 ? "none" : selectionCount === 1 ? "single" : "multiple"
    signal actionTriggered(string action)
    implicitHeight: Theme.controlHeight(density)
    implicitWidth: actions.implicitWidth + 24
    color: Colors.surface
    clip: true
    function allowed(key, fallback) {
        return actionAvailability[key] !== undefined ? actionAvailability[key] : fallback;
    }
    RowLayout {
        id: actions
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 6
        AzenzButton {
            text: qsTr("Nouveau")
            iconName: "add"
            size: "compact"
            enabled: root.allowed("new", true)
            onClicked: root.actionTriggered("new")
        }
        ToolbarSeparator {
            Layout.leftMargin: 6
            Layout.rightMargin: 6
        }
        ToolbarGroup {
            AzenzButton {
                text: qsTr("Modifier")
                iconName: "edit"
                variant: "toolbar"
                size: "compact"
                enabled: root.allowed("edit", root.selectionCount === 1)
                onClicked: root.actionTriggered("edit")
            }
            AzenzButton {
                text: qsTr("Supprimer")
                iconName: "delete"
                variant: "toolbar"
                size: "compact"
                enabled: root.allowed("delete", root.selectionCount > 0)
                onClicked: root.actionTriggered("delete")
            }
            AzenzButton {
                text: qsTr("Dupliquer")
                iconName: "copy"
                variant: "toolbar"
                size: "compact"
                enabled: root.allowed("duplicate", root.selectionCount === 1)
                onClicked: root.actionTriggered("duplicate")
            }
        }
        ToolbarSeparator {
            Layout.leftMargin: 6
            Layout.rightMargin: 6
        }
        ToolbarGroup {
            groupType: "output"
            AzenzButton {
                text: qsTr("Imprimer")
                iconName: "print"
                variant: "toolbar"
                size: "compact"
                enabled: root.allowed("print", root.selectionCount > 0)
                onClicked: root.actionTriggered("print")
            }
            AzenzButton {
                text: qsTr("Excel")
                iconName: "table"
                variant: "toolbar"
                size: "compact"
                enabled: root.allowed("export", true)
                onClicked: root.actionTriggered("export")
            }
        }
        OverflowMenuButton {
            menu.contentData: [
                DropdownMenuItem {
                    text: qsTr("Action secondaire")
                    onTriggered: root.actionTriggered("secondary")
                }
            ]
        }
        Item {
            Layout.fillWidth: true
        }
        ToolbarUtilityButton {
            iconName: "refresh"
            tooltip: qsTr("Actualiser")
            onClicked: root.actionTriggered("refresh")
        }
        ToolbarUtilityButton {
            iconName: "columns"
            tooltip: qsTr("Afficher les colonnes")
            onClicked: root.actionTriggered("columns")
        }
    }
}
