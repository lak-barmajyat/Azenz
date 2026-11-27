pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import "../controls"
import "../theme"

Rectangle {
    id: root
    property var columns: [] // {key, title, width, fill, searchable, editable, inputType, suffix, placeholder, defaultValue}
    property var rows: []
    property var defaultValues: ({})
    property var draftComputed: ({})
    property var editComputed: ({})
    property var searchResults: ({field: "", query: "", items: []})
    property bool searchBusy: false
    property bool readOnly: false
    property bool showActions: !readOnly
    property bool allowEdit: true
    property bool allowRemove: true
    property bool requireSelection: true
    property int minimumSearchLength: 1
    property int rowHeight: 44
    property int headerHeight: 44
    property int actionWidth: 76
    property bool showRowNumber: true
    property bool showTypeIcon: true
    property int rowNumberWidth: 34
    property int typeIconWidth: 44
    property string rowTypeIcon: "inventory_2"
    property color headerBackground: Colors.navy
    property color headerForeground: "white"
    property string localeName: Qt.locale().name
    property string suggestionPrimaryKey: "description"
    property string suggestionSecondaryKey: "reference"
    property string addActionLabel: qsTr("Ajouter la ligne")
    property var draft: Object.assign({}, defaultValues)
    property var selectedSuggestion: null
    property var searchFields: ({})
    property bool addEnabled: !requireSelection || selectedSuggestion !== null
    property bool editEnabled: true
    property var editingRowId: null
    property var editDraft: ({})
    property var editSuggestion: null
    readonly property int tableWidth: columns.reduce(function(total, column) {
        return total + (column.width || 140);
    }, (showActions ? actionWidth : 0) +
       (showRowNumber ? rowNumberWidth : 0) +
       (showTypeIcon ? typeIconWidth : 0))
    readonly property int horizontalBarHeight: tableWidth > width - 2 ? 8 : 0
    readonly property real totalFill: columns.reduce(function(total, column) {
        return total + (Number(column.fill) || 0);
    }, 0)

    signal searchRequested(string field, string query)
    signal addRequested(var values, var suggestion)
    signal editRequested(var row)
    signal updateRequested(var row, var values, var suggestion)
    signal removeRequested(var row)

    implicitWidth: 900
    implicitHeight: headerHeight + (rows.length + (readOnly ? 0 : 1)) * rowHeight + 2 + horizontalBarHeight
    radius: 6
    color: Colors.surface
    border.color: Colors.borderStrong
    clip: true

    function setDraftValue(key, value, fromSearch) {
        var next = Object.assign({}, draft);
        next[key] = value;
        draft = next;
        if (fromSearch)
            selectedSuggestion = null;
    }

    function draftValue(key, fallback) {
        return draftComputed[key] !== undefined ? draftComputed[key]
             : draft[key] !== undefined ? draft[key] : fallback;
    }

    function displayValue(column, value) {
        if (value === undefined || value === null || value === "")
            return "";
        var text = column.decimals !== undefined && isFinite(Number(value))
                 ? Number(value).toLocaleString(Qt.locale(localeName), "f", column.decimals)
                 : String(value);
        return text + (column.suffix ? " " + column.suffix : "");
    }

    function columnWidth(column) {
        var extra = Math.max(0, scroll.contentWidth - tableWidth);
        return (column.width || 140) + (totalFill > 0 ? extra * (Number(column.fill) || 0) / totalFill : 0);
    }

    function selectSuggestion(suggestion) {
        draft = Object.assign({}, draft, suggestion);
        selectedSuggestion = suggestion;
    }

    function focusFirstSearch() {
        for (var i = 0; i < columns.length; ++i) {
            var field = searchFields[columns[i].key];
            if (columns[i].searchable === true && field) {
                field.forceActiveFocus();
                return;
            }
        }
    }

    function registerSearchField(key, field) {
        var next = Object.assign({}, searchFields);
        next[key] = field;
        searchFields = next;
    }

    function unregisterSearchField(key, field) {
        if (searchFields[key] !== field)
            return;
        var next = Object.assign({}, searchFields);
        delete next[key];
        searchFields = next;
    }

    function clearDraft() {
        draft = Object.assign({}, defaultValues);
        selectedSuggestion = null;
        Qt.callLater(focusFirstSearch);
    }

    function addDraft() {
        if (!addEnabled || readOnly)
            return;
        addRequested(Object.assign({}, draft, draftComputed), selectedSuggestion);
        clearDraft();
    }

    function beginEdit(row) {
        editingRowId = row.id;
        editDraft = Object.assign({}, row);
        editSuggestion = row;
    }

    function finishEdit() {
        editingRowId = null;
        editDraft = ({});
        editSuggestion = null;
    }

    function setEditValue(key, value) {
        var next = Object.assign({}, editDraft);
        next[key] = value;
        editDraft = next;
    }

    function editValue(key, fallback) {
        return editComputed[key] !== undefined ? editComputed[key]
             : editDraft[key] !== undefined ? editDraft[key] : fallback;
    }

    function selectEditSuggestion(suggestion) {
        editDraft = Object.assign({}, editDraft, suggestion);
        editSuggestion = suggestion;
    }

    function requestUpdate(row) {
        if (editEnabled && editSuggestion)
            updateRequested(row, Object.assign({}, editDraft), editSuggestion);
    }

    Flickable {
        id: scroll
        anchors.fill: parent
        anchors.margins: 1
        anchors.bottomMargin: 1 + root.horizontalBarHeight
        contentWidth: Math.max(width, root.tableWidth)
        contentHeight: tableContent.height
        flickableDirection: Flickable.AutoFlickDirection
        boundsBehavior: Flickable.StopAtBounds
        C.ScrollBar.horizontal: AzenzScrollBar {
            parent: root
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 8
        }
        C.ScrollBar.vertical: AzenzScrollBar {}

        Column {
            id: tableContent
            width: scroll.contentWidth
            spacing: 0

            Rectangle {
                width: parent.width
                height: root.headerHeight
                color: root.headerBackground
                border.color: Colors.border
                Row {
                    anchors.fill: parent
                    Item {
                        visible: root.showRowNumber
                        width: visible ? root.rowNumberWidth : 0
                        height: root.headerHeight
                        Label {
                            anchors.centerIn: parent
                            text: "#"
                            color: root.headerForeground
                            font.pixelSize: 10
                        }
                    }
                    Item {
                        visible: root.showTypeIcon
                        width: visible ? root.typeIconWidth : 0
                        height: root.headerHeight
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Type")
                            color: root.headerForeground
                            font.pixelSize: 10
                            font.letterSpacing: 0.7
                        }
                    }
                    Repeater {
                        model: root.columns
                        Item {
                            id: headerCell
                            required property var modelData
                            width: root.columnWidth(modelData)
                            height: root.headerHeight
                            Label {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                text: (headerCell.modelData.title || "").toUpperCase()
                                color: root.headerForeground
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                font.letterSpacing: 0.7
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: headerCell.modelData.alignment === "right" ? Text.AlignRight
                                                   : headerCell.modelData.alignment === "center" ? Text.AlignHCenter
                                                   : Text.AlignLeft
                                elide: Text.ElideRight
                            }
                        }
                    }
                    Item {
                        visible: root.showActions
                        width: visible ? root.actionWidth : 0
                        height: root.headerHeight
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Actions").toUpperCase()
                            color: root.headerForeground
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            font.letterSpacing: 0.7
                        }
                    }
                }
            }

            Repeater {
                model: root.rows
                Rectangle {
                    id: existingRow
                    required property var modelData
                    required property int index
                    readonly property bool editing: root.editingRowId === modelData.id
                    width: tableContent.width
                    height: root.rowHeight
                    color: rowHover.hovered ? Colors.subtle : index % 2 ? Colors.canvas : Colors.surface
                    HoverHandler { id: rowHover }
                    Row {
                        anchors.fill: parent
                        Item {
                            visible: root.showRowNumber
                            width: visible ? root.rowNumberWidth : 0
                            height: root.rowHeight
                            Label {
                                anchors.centerIn: parent
                                text: existingRow.index + 1
                                color: Colors.textSecondary
                                font.pixelSize: 12
                            }
                        }
                        Item {
                            visible: root.showTypeIcon
                            width: visible ? root.typeIconWidth : 0
                            height: root.rowHeight
                            Icon {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                name: root.rowTypeIcon
                                color: Colors.textSecondary
                            }
                        }
                        Repeater {
                            model: root.columns
                            Item {
                                id: existingCell
                                required property var modelData
                                width: root.columnWidth(modelData)
                                height: root.rowHeight
                                Loader {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    sourceComponent: existingRow.editing && existingCell.modelData.searchable === true
                                                     ? editSearchCell
                                                     : existingRow.editing && existingCell.modelData.editable === true
                                                       ? editInputCell : displayCell
                                }
                                Component {
                                    id: displayCell
                                    Label {
                                        text: root.displayValue(existingCell.modelData,
                                                existingRow.editing
                                                ? root.editValue(existingCell.modelData.key, "")
                                                : existingRow.modelData[existingCell.modelData.key])
                                        color: existingCell.modelData.key === "reference" ? Colors.navy : Colors.text
                                        font.pixelSize: 12
                                        font.weight: existingCell.modelData.key === "description" ? Font.Medium : Font.Normal
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: existingCell.modelData.alignment === "right" ? Text.AlignRight
                                                           : existingCell.modelData.alignment === "center" ? Text.AlignHCenter
                                                           : Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                }
                                Component {
                                    id: editSearchCell
                                    SearchEntryField {
                                        searchKey: existingCell.modelData.key
                                        inlineMode: true
                                        minimumSearchLength: root.minimumSearchLength
                                        value: String(root.editDraft[searchKey] ?? "")
                                        primaryKey: root.suggestionPrimaryKey
                                        secondaryKey: root.suggestionSecondaryKey
                                        suggestions: root.searchResults.field === searchKey &&
                                                     root.searchResults.query === text
                                                     ? root.searchResults.items || [] : []
                                        searchBusy: root.searchBusy
                                        onValueEdited: function(value) { root.setEditValue(searchKey, value); }
                                        onSearchRequested: function(key, query) { root.searchRequested(key, query); }
                                        onSuggestionSelected: function(suggestion) { root.selectEditSuggestion(suggestion); }
                                        onSubmitRequested: root.requestUpdate(existingRow.modelData)
                                    }
                                }
                                Component {
                                    id: editInputCell
                                    SearchEntryInlineField {
                                        text: String(root.editDraft[existingCell.modelData.key] ?? "")
                                        inputType: existingCell.modelData.inputType || "text"
                                        suffix: existingCell.modelData.suffix || ""
                                        horizontalAlignment: existingCell.modelData.alignment === "right"
                                                             ? TextInput.AlignRight : TextInput.AlignLeft
                                        onTextEdited: root.setEditValue(existingCell.modelData.key, text)
                                        onAccepted: root.requestUpdate(existingRow.modelData)
                                    }
                                }
                            }
                        }
                        Row {
                            visible: root.showActions
                            width: visible ? root.actionWidth : 0
                            height: root.rowHeight
                            spacing: 2
                            opacity: existingRow.editing || rowHover.hovered ? 1 : 0
                            IconButton {
                                visible: root.allowEdit && !root.readOnly && !existingRow.editing
                                iconName: "edit"
                                tooltip: qsTr("Modifier")
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    root.beginEdit(existingRow.modelData);
                                    root.editRequested(existingRow.modelData);
                                }
                            }
                            IconButton {
                                visible: existingRow.editing && !root.readOnly
                                iconName: "check"
                                tooltip: qsTr("Enregistrer la ligne")
                                enabled: root.editEnabled
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.requestUpdate(existingRow.modelData)
                            }
                            IconButton {
                                visible: existingRow.editing && !root.readOnly
                                iconName: "close"
                                tooltip: qsTr("Annuler la modification")
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.finishEdit()
                            }
                            IconButton {
                                visible: root.allowRemove && !root.readOnly && !existingRow.editing
                                iconName: "delete"
                                tooltip: qsTr("Supprimer")
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.removeRequested(existingRow.modelData)
                            }
                        }
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Colors.border
                    }
                }
            }

            Rectangle {
                id: draftRow
                visible: !root.readOnly
                width: tableContent.width
                height: visible ? root.rowHeight : 0
                color: Colors.canvas
                Row {
                    anchors.fill: parent
                    Item {
                        visible: root.showRowNumber
                        width: visible ? root.rowNumberWidth : 0
                        height: root.rowHeight
                        Label {
                            anchors.centerIn: parent
                            text: "*"
                            color: Colors.textSecondary
                            font.pixelSize: 12
                        }
                    }
                    Item {
                        visible: root.showTypeIcon
                        width: visible ? root.typeIconWidth : 0
                        height: root.rowHeight
                        Icon {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            name: "add_circle"
                            color: Colors.textSecondary
                        }
                    }
                    Repeater {
                        model: root.columns
                        Item {
                            id: draftCell
                            required property var modelData
                            width: root.columnWidth(modelData)
                            height: root.rowHeight
                            Loader {
                                id: fieldLoader
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                anchors.topMargin: draftCell.modelData.searchable === true || draftCell.modelData.editable === true ? 0 : 4
                                anchors.bottomMargin: draftCell.modelData.searchable === true || draftCell.modelData.editable === true ? 0 : 4
                                sourceComponent: draftCell.modelData.searchable === true ? searchCell
                                               : draftCell.modelData.editable === true ? inputCell : valueCell
                            }
                            Component {
                                id: searchCell
                                SearchEntryField {
                                    objectName: "searchEntry_" + searchKey
                                    searchKey: draftCell.modelData.key
                                    inlineMode: true
                                    Component.onCompleted: root.registerSearchField(searchKey, this)
                                    Component.onDestruction: root.unregisterSearchField(searchKey, this)
                                    minimumSearchLength: root.minimumSearchLength
                                    value: String(root.draftValue(searchKey, ""))
                                    placeholderText: draftCell.modelData.placeholder || qsTr("Search article")
                                    primaryKey: root.suggestionPrimaryKey
                                    secondaryKey: root.suggestionSecondaryKey
                                    suggestions: root.searchResults.field === searchKey &&
                                                 root.searchResults.query === text
                                                 ? root.searchResults.items || [] : []
                                    searchBusy: root.searchBusy
                                    onValueEdited: function(value) {
                                        root.setDraftValue(searchKey, value, true);
                                    }
                                    onSearchRequested: function(key, query) {
                                        root.searchRequested(key, query);
                                    }
                                    onSuggestionSelected: function(suggestion) {
                                        root.selectSuggestion(suggestion);
                                    }
                                    onSubmitRequested: root.addDraft()
                                }
                            }
                            Component {
                                id: inputCell
                                SearchEntryInlineField {
                                    text: String(root.draftValue(draftCell.modelData.key,
                                                 draftCell.modelData.defaultValue ?? ""))
                                    inputType: draftCell.modelData.inputType || "text"
                                    suffix: draftCell.modelData.suffix || ""
                                    placeholderText: draftCell.modelData.placeholder || ""
                                    horizontalAlignment: draftCell.modelData.alignment === "right"
                                                         ? TextInput.AlignRight : TextInput.AlignLeft
                                    onTextEdited: root.setDraftValue(draftCell.modelData.key, text, false)
                                    onAccepted: root.addDraft()
                                }
                            }
                            Component {
                                id: valueCell
                                Label {
                                    text: root.displayValue(draftCell.modelData,
                                        root.draftValue(draftCell.modelData.key,
                                                        draftCell.modelData.defaultValue ?? ""))
                                    color: Colors.textSecondary
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: draftCell.modelData.alignment === "right" ? Text.AlignRight
                                                         : draftCell.modelData.alignment === "center" ? Text.AlignHCenter
                                                         : Text.AlignLeft
                                }
                            }
                        }
                    }
                    Item {
                        visible: root.showActions
                        width: visible ? root.actionWidth : 0
                        height: root.rowHeight
                        C.AbstractButton {
                            id: addButton
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            enabled: root.addEnabled
                            hoverEnabled: true
                            focusPolicy: Qt.StrongFocus
                            Accessible.name: root.addActionLabel
                            background: Item {}
                            contentItem: Icon {
                                name: "add_box"
                                color: Colors.accent
                                opacity: addButton.enabled ? 1 : 0.55
                            }
                            AzenzToolTip {
                                text: root.addActionLabel
                                visible: addButton.hovered || addButton.visualFocus
                            }
                            onClicked: root.addDraft()
                        }
                    }
                }
            }
        }
    }
}
