pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import "../controls"
import "../theme"

Rectangle {
    id: root
    property string density: Theme.densityFor(parent)
    property color headerBackground: Colors.header
    property color headerForeground: Colors.navy
    property var rows: [] // Plain JS record array; replace after backend updates.
    property var columns: [] // {key, title, width, type, alignment, sortable, editable}
    property string idRole: "id"
    property string viewState: "default" // default, loading, empty, error
    property bool selectable: true
    property bool multiSelection: true
    property var selectedIds: []
    property int currentRow: -1
    property int currentColumn: 0
    property int totalCount: rows.length
    property string errorMessage: qsTr("Impossible de charger les données.")
    property int sortColumn: -1
    property string sortDirection: "asc"
    property real resizeStartWidth: 0
    property int selectionAnchor: -1
    readonly property int selectionCount: selectedIds.length
    readonly property int tableWidth: columns.reduce(function (sum, column) {
        return sum + (column.width || 140);
    }, selectable ? 36 : 0)
    readonly property var displayRows: {
        var result = rows.slice();
        if (sortColumn >= 0 && sortColumn < columns.length) {
            var field = columns[sortColumn].key;
            var type = columns[sortColumn].type;
            result.sort(function (a, b) {
                var av = a[field], bv = b[field];
                if (type === "date") {
                    av = dateNumber(av);
                    bv = dateNumber(bv);
                }
                var order = typeof av === "number" && typeof bv === "number" ? av - bv : String(av || "").localeCompare(String(bv || ""));
                return sortDirection === "asc" ? order : -order;
            });
        }
        return result;
    }
    readonly property int eligibleCount: rows.filter(function (row) {
        return row.enabled !== false;
    }).length
    signal rowActivated(var record)
    signal contextMenuRequested(var record, real x, real y)
    signal cellEdited(var record, string key, var value)
    signal retryRequested
    signal loadMoreRequested
    implicitWidth: 1080
    implicitHeight: 320
    color: Colors.surface
    border.color: Colors.border
    radius: 6
    clip: true
    activeFocusOnTab: true
    function rowId(record) {
        return record[idRole];
    }
    function dateNumber(value) {
        if (value instanceof Date)
            return value.getTime();
        var parts = String(value).split("/");
        return parts.length === 3 ? new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0])).getTime() : new Date(value).getTime();
    }
    function isSelected(record) {
        return selectedIds.indexOf(rowId(record)) >= 0;
    }
    function toggle(record) {
        if (!selectable || record.enabled === false)
            return;
        var id = rowId(record), values = selectedIds.slice(), i = values.indexOf(id);
        if (i >= 0)
            values.splice(i, 1);
        else if (multiSelection)
            values.push(id);
        else
            values = [id];
        selectedIds = values;
    }
    function focusRow(index) {
        currentRow = Math.max(0, Math.min(displayRows.length - 1, index));
        list.positionViewAtIndex(currentRow, ListView.Contain);
        forceActiveFocus();
    }
    function requestContext(index, x, y) {
        focusRow(index);
        contextMenuRequested(displayRows[index], x, y);
    }
    onRowsChanged: {
        selectedIds = selectedIds.filter(function (id) {
            return rows.some(function (row) {
                return row[idRole] === id && row.enabled !== false;
            });
        });
        if (currentRow >= rows.length)
            currentRow = rows.length - 1;
    }
    Keys.onPressed: function (event) {
        if (viewState !== "default" || !displayRows.length)
            return;
        if (event.key === Qt.Key_Down)
            focusRow(currentRow + 1);
        else if (event.key === Qt.Key_Up)
            focusRow(currentRow - 1);
        else if (event.key === Qt.Key_Home)
            focusRow(0);
        else if (event.key === Qt.Key_End)
            focusRow(displayRows.length - 1);
        else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            currentColumn = Math.max(0, Math.min(columns.length - 1, currentColumn + (event.key === Qt.Key_Left ? -1 : 1)));
            var cellX = selectable ? 36 : 0;
            for (var c = 0; c < currentColumn; ++c)
                cellX += columns[c].width || 140;
            if (cellX < horizontal.contentX)
                horizontal.contentX = cellX;
            else if (cellX + (columns[currentColumn].width || 140) > horizontal.contentX + horizontal.width)
                horizontal.contentX = cellX + (columns[currentColumn].width || 140) - horizontal.width;
        } else if (event.key === Qt.Key_Space && currentRow >= 0)
            toggle(displayRows[currentRow]);
        else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && currentRow >= 0 && displayRows[currentRow].enabled !== false)
            rowActivated(displayRows[currentRow]);
        else if ((event.key === Qt.Key_Menu || event.key === Qt.Key_F10 && event.modifiers & Qt.ShiftModifier) && currentRow >= 0)
            requestContext(currentRow, 40, Math.max(36, (currentRow + 1) * Theme.rowHeight(density) - list.contentY));
        else
            return;
        event.accepted = true;
    }
    Flickable {
        id: horizontal
        anchors.fill: parent
        anchors.bottomMargin: footer.height
        anchors.margins: 1
        contentWidth: Math.max(width, root.tableWidth)
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        C.ScrollBar.horizontal: AzenzScrollBar {}
        DataGridHeader {
            id: gridHeader
            headerBackground: root.headerBackground
            headerForeground: root.headerForeground
            columns: root.columns
            density: root.density
            selectable: root.selectable
            selectionState: root.selectionCount === 0 ? Qt.Unchecked : root.selectionCount === root.eligibleCount ? Qt.Checked : Qt.PartiallyChecked
            sortColumn: root.sortColumn
            sortDirection: root.sortDirection
            onSelectAllRequested: function (checked) {
                root.selectedIds = checked ? root.rows.filter(function (row) {
                    return row.enabled !== false;
                }).slice(0, root.multiSelection ? root.rows.length : 1).map(function (row) {
                    return root.rowId(row);
                }) : [];
            }
            onSortRequested: function (column) {
                root.sortDirection = root.sortColumn === column && root.sortDirection === "asc" ? "desc" : "asc";
                root.sortColumn = column;
                root.currentRow = -1;
            }
            onResizeStarted: function (column) {
                root.resizeStartWidth = root.columns[column].width || 140;
            }
            onResizeRequested: function (column, delta) {
                var cols = root.columns.slice();
                cols[column] = Object.assign({}, cols[column], {
                    width: Math.max(64, root.resizeStartWidth + delta)
                });
                root.columns = cols;
            }
        }
        ListView {
            id: list
            y: gridHeader.height
            width: horizontal.contentWidth
            height: horizontal.height - gridHeader.height - 8
            model: root.viewState === "default" ? root.displayRows : []
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            onMovementEnded: if (atYEnd && root.rows.length < root.totalCount)
                root.loadMoreRequested()
            C.ScrollBar.vertical: AzenzScrollBar {
                parent: root
                anchors.right: parent.right
                y: gridHeader.height
                height: list.height
            }
            delegate: DataGridRow {
                required property var modelData
                required property int index
                width: list.width
                height: Theme.rowHeight(root.density)
                density: root.density
                record: modelData
                columns: root.columns
                selectable: root.selectable
                selected: root.isSelected(modelData)
                focused: root.activeFocus && root.currentRow === index
                focusedColumn: root.currentColumn
                enabled: modelData.enabled !== false
                onSelectionToggled: {
                    root.toggle(modelData);
                    root.focusRow(index);
                    root.selectionAnchor = index;
                }
                onPressed: function (modifiers) {
                    root.focusRow(index);
                    if (root.multiSelection && modifiers & Qt.ControlModifier) {
                        root.toggle(modelData);
                        root.selectionAnchor = index;
                    } else if (root.multiSelection && root.selectable && modifiers & Qt.ShiftModifier && root.selectionAnchor >= 0) {
                        root.selectedIds = root.displayRows.slice(Math.min(index, root.selectionAnchor), Math.max(index, root.selectionAnchor) + 1).filter(function (row) {
                            return row.enabled !== false;
                        }).map(function (row) {
                            return root.rowId(row);
                        });
                    } else
                        root.selectionAnchor = index;
                }
                onContextRequested: function (x, y) {
                    var point = mapToItem(root, x, y);
                    root.requestContext(index, point.x, point.y);
                }
                onCellEdited: function (key, value) {
                    root.cellEdited(modelData, key, value);
                }
            }
        }
    }
    Loader {
        anchors.fill: parent
        anchors.topMargin: Theme.headerHeight(root.density)
        anchors.bottomMargin: footer.height
        active: root.viewState !== "default" || root.rows.length === 0
        sourceComponent: root.viewState === "loading" ? loading : root.viewState === "error" ? error : empty
    }
    Component {
        id: loading
        Skeleton {
            variant: "table"
            rows: 6
        }
    }
    Component {
        id: error
        EmptyState {
            title: root.errorMessage
            description: qsTr("Vérifiez la connexion ou réessayez.")
            iconName: "error"
            actionText: qsTr("Réessayer")
            onActionTriggered: root.retryRequested()
        }
    }
    Component {
        id: empty
        EmptyState {
            variant: "noResults"
        }
    }
    DataGridFooter {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        recordCount: root.rows.length
        selectionCount: root.selectionCount
        totalCount: root.totalCount
    }
}
