pragma ComponentBehavior: Bound
import QtQuick
import "../theme"

Row {
    id: root
    property var columns: []
    property bool selectable: true
    property int selectionState: Qt.Unchecked
    property int sortColumn: -1
    property string sortDirection: "asc"
    property string density: Theme.densityFor(parent)
    property color headerBackground: Colors.header
    property color headerForeground: Colors.navy
    signal selectAllRequested(bool checked)
    signal sortRequested(int column)
    signal resizeStarted(int column)
    signal resizeRequested(int column, real delta)
    height: Theme.headerHeight(density)
    DataGridSelectionCell {
        Rectangle { anchors.fill: parent; color: root.headerBackground; z: -1 }
        width: 36
        height: root.height
        visible: root.selectable
        checkState: root.selectionState
        tristate: true
        onToggled: root.selectAllRequested(checked)
    }
    Repeater {
        model: root.columns
        DataGridHeaderCell {
            required property var modelData
            required property int index
            text: modelData.title
            width: modelData.width || 140
            height: root.height
            alignment: modelData.alignment || "left"
            headerBackground: root.headerBackground
            headerForeground: root.headerForeground
            sortable: modelData.sortable !== false
            sortDirection: root.sortColumn === index ? root.sortDirection : "none"
            onClicked: if (sortable)
                root.sortRequested(index)
            onResizeStarted: root.resizeStarted(index)
            onResizeBy: function (delta) {
                root.resizeRequested(index, delta);
            }
        }
    }
}
