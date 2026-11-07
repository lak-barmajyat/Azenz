import QtQuick
import "../../qml/components"
import "ReglementsSample.js" as Sample

ReglementsView {
    id: root
    objectName: "reglementsScreen"
    property bool previewMode: false
    property var sourceRows: []
    property var appliedFilters: ({})
    readonly property string category: activeTab === 1 ? "fournisseurs" : "clients"
    readonly property var categoryRows: sourceRows.filter(function(row) { return row.category === root.category; })
    readonly property var filteredRows: categoryRows.filter(function(row) { return root.matches(row); })
    readonly property real totalAmount: categoryRows.reduce(function(sum, row) { return sum + Number(row.amount || 0); }, 0)
    readonly property real affectedAmount: categoryRows.reduce(function(sum, row) { return sum + (row.affected ? Number(row.amount || 0) : 0); }, 0)

    signal actionRequested(string action, var records)
    signal backRequested
    signal filterApplied(var filters)

    rows: filteredRows
    clientCount: sourceRows.filter(function(row) { return row.category === "clients"; }).length
    supplierCount: sourceRows.filter(function(row) { return row.category === "fournisseurs"; }).length
    totalText: formatMoney(totalAmount)
    affectedText: formatMoney(affectedAmount)
    remainingText: formatMoney(totalAmount - affectedAmount)
    footerText: qsTr("%1 règlements %2 affichés • %3 validés / %4 en attente")
                .arg(filteredRows.length)
                .arg(activeTab === 1 ? qsTr("fournisseurs") : qsTr("clients"))
                .arg(filteredRows.filter(function(row) { return row.status === "Validé"; }).length)
                .arg(filteredRows.filter(function(row) { return row.status === "En attente"; }).length)

    function formatMoney(value) {
        return Number(value).toLocaleString(Qt.locale("fr_MA"), "f", 2) + " MAD";
    }

    function dateNumber(text) {
        var parts = String(text || "").split("/");
        return parts.length === 3 ? Number(parts[2]) * 10000 + Number(parts[1]) * 100 + Number(parts[0]) : 0;
    }

    function matches(row) {
        var f = appliedFilters;
        if (f.code && String(row.code).toLowerCase().indexOf(f.code) < 0) return false;
        if (f.tierCode && String(row.tierCode).toLowerCase().indexOf(f.tierCode) < 0) return false;
        if (f.tier && String(row.tier).toLowerCase().indexOf(f.tier) < 0) return false;
        if (f.comment && String(row.comment).toLowerCase().indexOf(f.comment) < 0) return false;
        if (f.mode && row.mode !== f.mode) return false;
        if (f.status && row.status !== f.status) return false;
        var date = dateNumber(row.date);
        if (f.start && date < f.start) return false;
        if (f.end && date > f.end) return false;
        return true;
    }

    function applyFilters() {
        filters.startDate.commit();
        filters.endDate.commit();
        if (filters.startDate.validationState === "error" || filters.endDate.validationState === "error")
            return;
        appliedFilters = {
            code: filters.codeText.trim().toLowerCase(),
            tierCode: filters.tierCodeText.trim().toLowerCase(),
            tier: filters.tierText.trim().toLowerCase(),
            comment: filters.commentText.trim().toLowerCase(),
            mode: filters.modePicker.currentIndex > 0 ? filters.modePicker.currentText : "",
            status: filters.statusPicker.currentIndex > 0 ? filters.statusPicker.currentText : "",
            start: filters.startDate.hasValue ? dateNumber(Qt.formatDate(filters.startDate.value, "dd/MM/yyyy")) : 0,
            end: filters.endDate.hasValue ? dateNumber(Qt.formatDate(filters.endDate.value, "dd/MM/yyyy")) : 0
        };
        grid.selectedIds = [];
        filterApplied(appliedFilters);
    }

    function resetFilters() {
        filters.resetFields();
        appliedFilters = {};
        grid.selectedIds = [];
        filterApplied(appliedFilters);
    }

    function selectedRows() {
        return filteredRows.filter(function(row) { return grid.selectedIds.indexOf(row.id) >= 0; });
    }

    onActiveTabChanged: {
        if (filters) {
            filters.clearQueries();
            appliedFilters = {};
            grid.selectedIds = [];
        }
    }
    onPreviewModeChanged: if (previewMode) {
        sourceRows = Sample.rows.slice();
        activeTab = 1;
        filters.startDate.value = new Date(2025, 7, 1);
        filters.startDate.hasValue = true;
        filters.endDate.value = new Date(2025, 7, 31);
        filters.endDate.hasValue = true;
    }

    Connections { target: root.filters; function onApplyRequested() { root.applyFilters(); } function onResetRequested() { root.resetFilters(); } }
    Connections { target: root.newButton; function onClicked() { root.actionRequested("new", []); } }
    Connections { target: root.editButton; function onClicked() { root.actionRequested("edit", root.selectedRows()); } }
    Connections { target: root.deleteButton; function onClicked() { root.actionRequested("delete", root.selectedRows()); } }
    Connections { target: root.duplicateButton; function onClicked() { root.actionRequested("duplicate", root.selectedRows()); } }
    Connections { target: root.printButton; function onClicked() { root.actionRequested("print", root.selectedRows()); } }
    Connections { target: root.exportButton; function onClicked() { root.actionRequested("export", root.filteredRows); } }
    Connections { target: root.backButton; function onClicked() { root.backRequested(); } }
    Connections {
        target: root.grid
        function onRowActivated(record) { root.actionRequested("edit", [record]); }
        function onContextMenuRequested(record, x, y) {
            rowMenu.targetRecord = record;
            rowMenu.popup(root.grid, x, y);
        }
    }
    ContextMenu {
        id: rowMenu
        ContextMenuItem { text: qsTr("Modifier"); iconName: "edit"; onTriggered: root.actionRequested("edit", [rowMenu.targetRecord]) }
        ContextMenuItem { text: qsTr("Dupliquer"); iconName: "copy"; onTriggered: root.actionRequested("duplicate", [rowMenu.targetRecord]) }
        ContextMenuItem { text: qsTr("Supprimer"); iconName: "delete"; destructive: true; onTriggered: root.actionRequested("delete", [rowMenu.targetRecord]) }
    }
}
