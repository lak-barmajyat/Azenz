import QtQuick

ListeStockView {
    id: root
    property var sourceRows: []
    property bool previewMode: false
    signal actionRequested(string action, var records)
    signal backRequested

    rows: sourceRows
    documentTypes: [qsTr("Tous les types"), qsTr("Entrée de stock"), qsTr("Sortie de stock"), qsTr("Ajustement"), qsTr("Inventaire")]
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
    onSourceRowsChanged: applyFilters()
    Connections { target: root.newButton; function onClicked() { root.actionRequested("new", []); } }
    Connections { target: root.footerNewButton; function onClicked() { root.actionRequested("new", []); } }
    Connections { target: root.editButton; function onClicked() { root.actionRequested("edit", root.selectedRows()); } }
    Connections { target: root.deleteButton; function onClicked() { root.actionRequested("delete", root.selectedRows()); } }
    Connections { target: root.duplicateButton; function onClicked() { root.actionRequested("duplicate", root.selectedRows()); } }
    Connections { target: root.printButton; function onClicked() { root.actionRequested("print", root.selectedRows()); } }
    Connections { target: root.exportButton; function onClicked() { root.actionRequested("export", root.rows); } }
    Connections { target: root.columnsButton; function onClicked() { root.actionRequested("columns", root.rows); } }
    Connections { target: root.refreshButton; function onClicked() { root.actionRequested("refresh", []); } }
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
}
