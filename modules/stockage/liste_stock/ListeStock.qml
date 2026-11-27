import QtQuick
import QtQuick.Dialogs
import "../../../qml/components"

ListeStockView {
    id: root
    property var sourceRows: []
    property bool previewMode: false
    property var pendingDelete: []
    // qmllint disable unqualified
    readonly property var backend: typeof listeStockModel !== "undefined" ? listeStockModel : null
    // qmllint enable unqualified
    signal actionRequested(string action, var records)
    signal backRequested

    rows: previewMode ? sourceRows : backend ? backend.records : []
    busy: backend ? backend.busy : false
    documentTypes: typeOptions(sourceRows)
    columns: [
        { key: "code", title: qsTr("CODE DOC"), type: "code", width: 170 },
        { key: "type", title: qsTr("TYPE DE DOC"), type: "status", variantKey: "typeVariant", width: 180 },
        { key: "date", title: qsTr("DATE"), type: "date", width: 130 },
        { key: "status", title: qsTr("STATUT"), type: "status", variantKey: "statusVariant", width: 135 },
        { key: "comment", title: qsTr("COMMENTAIRE"), width: Math.max(280, grid.width - 660) }
    ]

    function selectedRows() {
        return rows.filter(function (row) { return grid.selectedIds.indexOf(row.id) >= 0; });
    }
    function typeOptions(records) {
        var result = [qsTr("Tous les types")];
        records.forEach(function (row) {
            if (result.indexOf(row.type) < 0)
                result.push(row.type);
        });
        return result;
    }
    function applyFilters() {
        var start = fromDate.hasValue ? fromDate.value.getTime() : -Infinity;
        var end = toDate.hasValue ? toDate.value.getTime() : Infinity;
        if (start > end) {
            filterError = qsTr("La date de début doit précéder la date de fin.");
            return;
        }
        filterError = "";
        var code = codeFilter.text.toLowerCase();
        var type = typeFilter.currentIndex > 0 ? documentTypes[typeFilter.currentIndex] : "";
        rows = sourceRows.filter(function (row) {
            var parts = String(row.date || "").split("/");
            var date = parts.length === 3 ? new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0])).getTime() : NaN;
            return String(row.code || "").toLowerCase().indexOf(code) >= 0
                && (!type || row.type === type) && date >= start && date <= end;
        });
        grid.selectedIds = [];
    }
    function requestAction(action, target) {
        if (busy)
            return;
        var selected = target || selectedRows();
        if (["edit", "duplicate", "open"].indexOf(action) >= 0 && selected.length !== 1)
            return;
        if (["delete", "print"].indexOf(action) >= 0 && selected.length === 0)
            return;
        if (action === "delete") {
            if (backend && !previewMode) {
                pendingDelete = selected.slice();
                confirmDelete.open();
            } else
                actionRequested(action, selected);
            return;
        }
        if (action === "print") {
            if (backend && !previewMode)
                backend.printDocuments(selected.map(function (row) { return row.id; }));
            else
                actionRequested(action, selected);
            return;
        }
        if (action === "export") {
            if (backend && !previewMode)
                exportDialog.open();
            else
                actionRequested(action, rows);
            return;
        }
        if (action === "refresh") {
            if (backend && !previewMode)
                backend.refresh();
            else
                actionRequested(action, []);
            return;
        }
        actionRequested(action, selected);
    }
    Component.onCompleted: if (backend && !previewMode) backend.refresh()
    onSourceRowsChanged: if (previewMode) applyFilters()
    Connections {
        target: root.backend
        function onDataChanged() { root.sourceRows = root.backend.records; root.applyFilters(); }
        function onDeleteCompleted(count) { root.filterError = ""; root.applyFilters(); }
        function onLoadFailed(code) { root.filterError = qsTr("Impossible de charger les documents de stock."); }
        function onDeleteFailed(code) {
            root.filterError = code === "negative_stock"
                    ? qsTr("Suppression impossible : le stock deviendrait négatif.")
                    : qsTr("Impossible de supprimer les documents sélectionnés.");
        }
        function onExportFailed(code) {
            root.filterError = qsTr("Impossible d’enregistrer le fichier d’export.");
        }
        function onExportCompleted(path) { root.filterError = ""; }
        function onPrintFailed(code) {
            root.filterError = code === "open_failed"
                    ? qsTr("Le PDF a été créé, mais son ouverture a échoué.")
                    : qsTr("Impossible de créer le document à imprimer.");
        }
        function onPrintCompleted(path) { root.filterError = ""; }
    }
    Connections { target: root.newButton; function onClicked() { root.requestAction("new"); } }
    Connections { target: root.footerNewButton; function onClicked() { root.requestAction("new"); } }
    Connections { target: root.editButton; function onClicked() { root.requestAction("edit"); } }
    Connections { target: root.deleteButton; function onClicked() { root.requestAction("delete"); } }
    Connections { target: root.duplicateButton; function onClicked() { root.requestAction("duplicate"); } }
    Connections { target: root.printButton; function onClicked() { root.requestAction("print"); } }
    Connections { target: root.exportButton; function onClicked() { root.requestAction("export"); } }
    Connections { target: root.refreshButton; function onClicked() { root.requestAction("refresh"); } }
    Connections { target: root.applyButton; function onClicked() { root.applyFilters(); } }
    Connections { target: root.codeFilter; function onTextChanged() { root.applyFilters(); } }
    Connections { target: root.typeFilter; function onCurrentIndexChanged() { root.applyFilters(); } }
    Connections {
        target: root.fromDate
        function onDateEdited(value) { root.applyFilters(); }
        function onDateCleared() { root.applyFilters(); }
    }
    Connections {
        target: root.toDate
        function onDateEdited(value) { root.applyFilters(); }
        function onDateCleared() { root.applyFilters(); }
    }
    Connections {
        target: root.resetButton
        function onClicked() {
            root.codeFilter.text = "";
            root.typeFilter.currentIndex = 0;
            root.fromDate.hasValue = false;
            root.toDate.hasValue = false;
            root.applyFilters();
        }
    }
    Connections { target: root.backButton; function onClicked() { root.backRequested(); } }
    Connections {
        target: root.grid
        function onContextMenuRequested(record, x, y) {
            context.targetRecord = record;
            context.popup(root.grid, x, y);
        }
        function onRowActivated(record) { root.requestAction("open", [record]); }
    }
    ContextMenu {
        id: context
        ContextMenuItem {
            text: qsTr("Ouvrir")
            iconName: "open"
            onTriggered: root.requestAction("open", [context.targetRecord])
        }
        ContextMenuItem {
            text: qsTr("Modifier")
            iconName: "edit"
            onTriggered: root.requestAction("edit", [context.targetRecord])
        }
        ContextMenuItem {
            text: qsTr("Dupliquer")
            iconName: "copy"
            onTriggered: root.requestAction("duplicate", [context.targetRecord])
        }
        ContextMenuItem {
            text: qsTr("Imprimer")
            iconName: "print"
            onTriggered: root.requestAction("print", [context.targetRecord])
        }
        MenuSeparator {}
        ContextMenuItem {
            text: qsTr("Supprimer")
            iconName: "delete"
            destructive: true
            onTriggered: root.requestAction("delete", [context.targetRecord])
        }
    }
    AzenzDialog {
        id: confirmDelete
        dialogType: "destructive"
        title: qsTr("Confirmer la suppression")
        message: qsTr("Supprimer %n document(s) de stock sélectionné(s) ?", "", root.pendingDelete.length)
        supportingMessage: qsTr("Le stock sera recalculé et la suppression sera refusée s’il devient négatif.")
        onAccepted: {
            root.backend.deleteDocuments(root.pendingDelete.map(function (row) { return row.id; }));
            root.pendingDelete = [];
        }
        onRejected: root.pendingDelete = []
    }
    FileDialog {
        id: exportDialog
        title: qsTr("Exporter la liste des documents de stock")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("Fichier Excel CSV (*.csv)")]
        defaultSuffix: "csv"
        onAccepted: root.backend.exportCsv(selectedFile, root.rows)
    }
}
