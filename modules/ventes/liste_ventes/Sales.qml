import QtQuick
import "../../../qml/components"

SalesView {
    id: root
    property var sourceRows: []
    property var appliedFilters: ({
            code: "",
            type: "",
            from: null,
            to: null
        })
    property bool updatingFilters: false
    property var pendingDelete: []
    signal actionRequested(string action, var records)
    signal filtersChanged(var filters)
    signal navigationRequested(string page)
    signal backRequested
    signal quitRequested
    signal minimizeRequested
    signal maximizeRequested
    readonly property var selectedRecords: sourceRows.filter(function (row) {
        return root.grid.selectedIds.indexOf(row.id) >= 0;
    })
    records: sourceRows.filter(function (row) {
        var f = root.appliedFilters;
        var date = root.dateValue(row.date);
        return (!f.code || String(row.documentCode).toLowerCase().indexOf(f.code) >= 0) && (!f.type || row.documentType === f.type) && (f.from === null || date >= f.from) && (f.to === null || date <= f.to);
    })
    totalHT: records.reduce(function (sum, row) {
        return sum + Number(row.ht || 0);
    }, 0)
    totalVAT: records.reduce(function (sum, row) {
        return sum + Number(row.vat || 0);
    }, 0)
    totalTTC: records.reduce(function (sum, row) {
        return sum + Number(row.ttc || 0);
    }, 0)
    columns: [
        {
            key: "clientCode",
            title: "CODE CLIENT",
            type: "code",
            width: 110
        },
        {
            key: "client",
            title: "CLIENT",
            width: Math.max(260, grid.width - 838)
        },
        {
            key: "documentCode",
            title: "CODE DOC",
            type: "code",
            width: 108
        },
        {
            key: "documentType",
            title: "TYPE",
            type: "status",
            alignment: "center",
            width: 100,
            sortable: false
        },
        {
            key: "date",
            title: "DATE",
            type: "date",
            alignment: "center",
            width: 104
        },
        {
            key: "ht",
            title: "TOTAL HT",
            type: "currency",
            suffix: "MAD",
            alignment: "right",
            width: 128
        },
        {
            key: "vat",
            title: "TVA (20%)",
            type: "currency",
            suffix: "MAD",
            alignment: "right",
            width: 120
        },
        {
            key: "ttc",
            title: "TOTAL TTC",
            type: "currency",
            suffix: "MAD",
            alignment: "right",
            width: 132
        }
    ]
    function dateValue(value) {
        if (value instanceof Date)
            return new Date(value.getFullYear(), value.getMonth(), value.getDate()).getTime();
        var p = String(value).split("/");
        return p.length === 3 ? new Date(Number(p[2]), Number(p[1]) - 1, Number(p[0])).getTime() : new Date(value).getTime();
    }
    function applyFilters() {
        if (updatingFilters)
            return;
        updatingFilters = true;
        fromDate.commit();
        toDate.commit();
        updatingFilters = false;
        if (fromDate.validationState === "error" || toDate.validationState === "error") {
            filterError = "Veuillez saisir des dates valides (JJ/MM/AAAA).";
            return;
        }
        var from = fromDate.hasValue ? dateValue(fromDate.value) : null;
        var to = toDate.hasValue ? dateValue(toDate.value) : null;
        if (from !== null && to !== null && from > to) {
            filterError = "La date de début doit précéder la date de fin.";
            return;
        }
        filterError = "";
        appliedFilters = {
            code: codeFilter.text.trim().toLowerCase(),
            type: typeFilter.currentValue || "",
            from: from,
            to: to
        };
        filtersChanged(appliedFilters);
    }
    function resetFilters() {
        updatingFilters = true;
        codeFilter.text = "";
        typeFilter.currentIndex = 0;
        fromDate.hasValue = false;
        fromDate.text = "";
        fromDate.validationState = "default";
        toDate.hasValue = false;
        toDate.text = "";
        toDate.validationState = "default";
        updatingFilters = false;
        applyFilters();
    }
    function requestAction(action, target) {
        var selected = target || selectedRecords;
        if (["edit", "duplicate", "open"].indexOf(action) >= 0 && selected.length !== 1)
            return;
        if (["delete", "print"].indexOf(action) >= 0 && selected.length === 0)
            return;
        if (action === "delete") {
            pendingDelete = selected.slice();
            confirmDelete.open();
            return;
        }
        actionRequested(action, action === "export" ? records : selected);
    }
    Connections {
        target: root.codeFilter
        function onTextChanged() {
            root.applyFilters();
        }
    }
    Connections {
        target: root.typeFilter
        function onActivated(index) {
            root.applyFilters();
        }
    }
    Connections {
        target: root.fromDate
        function onDateCleared() {
            root.applyFilters();
        }
        function onDateEdited(value) {
            root.applyFilters();
        }
    }
    Connections {
        target: root.toDate
        function onDateCleared() {
            root.applyFilters();
        }
        function onDateEdited(value) {
            root.applyFilters();
        }
    }
    Connections {
        target: root.applyButton
        function onClicked() {
            root.applyFilters();
        }
    }
    Connections {
        target: root.resetButton
        function onClicked() {
            root.resetFilters();
        }
    }
    Connections {
        target: root.newButton
        function onClicked() {
            root.requestAction("new");
        }
    }
    Connections {
        target: root.newDocumentButton
        function onClicked() {
            root.requestAction("new");
        }
    }
    Connections {
        target: root.editButton
        function onClicked() {
            root.requestAction("edit");
        }
    }
    Connections {
        target: root.deleteButton
        function onClicked() {
            root.requestAction("delete");
        }
    }
    Connections {
        target: root.duplicateButton
        function onClicked() {
            root.requestAction("duplicate");
        }
    }
    Connections {
        target: root.printButton
        function onClicked() {
            root.requestAction("print");
        }
    }
    Connections {
        target: root.exportButton
        function onClicked() {
            root.requestAction("export");
        }
    }
    Connections {
        target: root.refreshButton
        function onClicked() {
            root.requestAction("refresh");
        }
    }
    Connections {
        target: root.backButton
        function onClicked() {
            root.backRequested();
        }
    }
    Connections {
        target: root.sidebar
        function onNavigate(page) {
            root.navigationRequested(page);
        }
    }
    Connections {
        target: root.titleBar
        function onCloseRequested() {
            root.quitRequested();
        }
        function onMinimizeRequested() {
            root.minimizeRequested();
        }
        function onMaximizeRequested() {
            root.maximizeRequested();
        }
    }
    Connections {
        target: root.menuBar
        function onCommandTriggered(command) {
            if (command === "quit")
                root.quitRequested();
            else if (command === "sidebar")
                root.sidebar.collapsed = !root.sidebar.collapsed;
            else
                root.requestAction(command);
        }
    }
    Connections {
        target: root.grid
        function onContextMenuRequested(record, x, y) {
            context.targetRecord = record;
            context.popup(root.grid, x, y);
        }
        function onRowActivated(record) {
            root.requestAction("open", [record]);
        }
        function onRetryRequested() {
            root.requestAction("refresh");
        }
    }
    Shortcut {
        sequence: "F5"
        enabled: root.visible
        onActivated: root.requestAction("refresh")
    }
    Shortcut {
        sequence: "Ctrl+N"
        enabled: root.visible
        onActivated: root.requestAction("new")
    }
    Shortcut {
        sequence: "F2"
        enabled: root.visible && root.grid.activeFocus
        onActivated: root.requestAction("edit")
    }
    Shortcut {
        sequence: "Delete"
        enabled: root.visible && root.grid.activeFocus
        onActivated: root.requestAction("delete")
    }
    ContextMenu {
        id: context
        ContextMenuItem {
            text: "Ouvrir"
            iconName: "open"
            shortcutText: "Entrée"
            onTriggered: root.requestAction("open", [context.targetRecord])
        }
        ContextMenuItem {
            text: "Modifier"
            iconName: "edit"
            shortcutText: "F2"
            onTriggered: root.requestAction("edit", [context.targetRecord])
        }
        ContextMenuItem {
            text: "Dupliquer"
            iconName: "copy"
            onTriggered: root.requestAction("duplicate", [context.targetRecord])
        }
        ContextMenuItem {
            text: "Imprimer"
            iconName: "print"
            onTriggered: root.requestAction("print", [context.targetRecord])
        }
        MenuSeparator {}
        ContextMenuItem {
            text: "Supprimer"
            iconName: "delete"
            destructive: true
            onTriggered: root.requestAction("delete", [context.targetRecord])
        }
    }
    AzenzDialog {
        id: confirmDelete
        objectName: "salesDeleteDialog"
        dialogType: "destructive"
        title: "Confirmer la suppression"
        message: "Supprimer " + root.pendingDelete.length + " document(s) sélectionné(s) ?"
        supportingMessage: "Vérifiez les documents sélectionnés avant de continuer."
        onAccepted: {
            root.actionRequested("delete", root.pendingDelete);
            root.pendingDelete = [];
        }
        onRejected: root.pendingDelete = []
    }
}
