import QtQuick
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
    documentTypes: typeOptions()
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
    function typeOptions() {
        var result = [qsTr("Tous les types")];
        rows.forEach(function (row) {
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
    }
    Connections { target: root.newButton; function onClicked() { root.actionRequested("new", []); } }
    Connections { target: root.footerNewButton; function onClicked() { root.actionRequested("new", []); } }
    Connections { target: root.editButton; function onClicked() { root.actionRequested("edit", root.selectedRows()); } }
    Connections {
        target: root.deleteButton
        function onClicked() {
            var selected = root.selectedRows();
            if (root.backend && !root.previewMode) {
                root.pendingDelete = selected;
                confirmDelete.open();
            } else
                root.actionRequested("delete", selected);
        }
    }
    Connections { target: root.duplicateButton; function onClicked() { root.actionRequested("duplicate", root.selectedRows()); } }
    Connections { target: root.printButton; function onClicked() { root.actionRequested("print", root.selectedRows()); } }
    Connections { target: root.exportButton; function onClicked() { root.actionRequested("export", root.rows); } }
    Connections { target: root.columnsButton; function onClicked() { root.actionRequested("columns", root.rows); } }
    Connections {
        target: root.refreshButton
        function onClicked() {
            if (root.backend && !root.previewMode)
                root.backend.refresh();
            else
                root.actionRequested("refresh", []);
        }
    }
    Connections { target: root.applyButton; function onClicked() { root.applyFilters(); } }
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
    Connections { target: root.grid; function onRowActivated(record) { root.actionRequested("open", [record]); } }
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
}
