pragma ComponentBehavior: Bound
import QtQuick
import "../theme"

Rectangle {
    id: root
    property var record: ({})
    property var columns: []
    property string density: Theme.densityFor(parent)
    property bool selected: false
    property bool focused: false
    property int focusedColumn: -1
    property bool selectable: true
    signal selectionToggled
    signal pressed(int modifiers)
    signal contextRequested(real x, real y)
    signal cellEdited(string key, var value)
    implicitHeight: Theme.rowHeight(density)
    color: !enabled ? Colors.disabled : selected ? Colors.rowSelected : hover.hovered ? Colors.rowHover : "white"
    border.width: focused ? 1 : 0
    border.color: Colors.navy
    HoverHandler {
        id: hover
    }
    TapHandler {
        id: rowTap
        acceptedButtons: Qt.LeftButton
        onTapped: root.pressed(rowTap.point.modifiers)
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: function (eventPoint) {
            root.contextRequested(eventPoint.position.x, eventPoint.position.y);
        }
    }
    Row {
        anchors.fill: parent
        DataGridSelectionCell {
            visible: root.selectable
            height: parent.height
            checked: root.selected
            onToggled: root.selectionToggled()
        }
        Repeater {
            model: root.columns
            DataGridCell {
                required property var modelData
                required property int index
                width: modelData.width || 140
                height: root.height
                value: root.record[modelData.key]
                cellType: modelData.type || "text"
                suffix: modelData.suffix || ""
                alignment: modelData.alignment || (["currency", "int", "dec"].indexOf(cellType) >= 0 ? "right" : "left")
                statusVariant: root.record.statusVariant || "neutral"
                editable: modelData.editable === true
                focused: root.focused && root.focusedColumn === index
                onEditCommitted: function (value) {
                    root.cellEdited(modelData.key, value);
                }
            }
        }
    }
    Rectangle {
        width: 3
        height: parent.height
        color: Colors.accent
        visible: root.selected
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Colors.subtle
    }
}
