import QtQuick

NouveauDocumentView {
    id: root
    property var sourceRows: []
    property var articles: []
    property bool previewMode: false
    property int nextId: 1
    signal backRequested
    signal documentRequested(string action, var document)
    signal articleSearchRequested(string key, string query)

    rows: sourceRows
    onSourceRowsChanged: {
        rows = sourceRows;
        nextId = sourceRows.reduce(function (maximum, row) { return Math.max(maximum, Number(row.id) || 0); }, 0) + 1;
    }
    canAddLine: validLine(grid.draft)
    canUpdateLine: validLine(grid.editDraft)

    function draft() {
        return { code: codeField.text, type: typeField.currentText,
            date: dateField.hasValue ? Qt.formatDate(dateField.value, "dd/MM/yyyy") : "",
            status: qsTr("Brouillon"), comment: commentField.text, lines: rows.slice() };
    }
    function validLine(values) {
        var quantity = Number(String(values.quantity || "").replace(",", "."));
        return String(values.reference || "").trim() !== "" &&
               String(values.description || "").trim() !== "" &&
               isFinite(quantity) && quantity > 0;
    }
    function clearLine() {
        grid.clearDraft();
        grid.finishEdit();
        grid.selectedIds = [];
        formError = "";
    }
    function saveLine(values, record) {
        if (!validLine(values)) {
            formError = qsTr("Saisissez une référence, une désignation et une quantité positive.");
            return;
        }
        var value = Number(String(values.quantity).replace(",", "."));
        var result = rows.slice();
        var line = { id: record ? record.id : nextId++, reference: String(values.reference).trim(),
            description: String(values.description).trim(), quantity: value.toFixed(2).replace(".", ","),
            comment: String(values.comment || "").trim() };
        var index = record ? result.findIndex(function (row) { return row.id === record.id; }) : -1;
        if (index >= 0)
            result[index] = line;
        else
            result.push(line);
        rows = result;
        formError = "";
        if (record)
            grid.finishEdit();
    }
    function searchArticles(key, query) {
        if (previewMode) {
            var needle = query.toLowerCase();
            var matches = articles.filter(function (article) {
                return String(article[key] || "").toLowerCase().indexOf(needle) >= 0;
            }).slice(0, 8);
            articleSearchResults = {field: key, query: query, items: matches};
        } else
            articleSearchRequested(key, query);
    }
    Connections {
        target: root.grid
        function onSearchRequested(key, query) { root.searchArticles(key, query); }
        function onAddRequested(values) { root.saveLine(values, null); }
        function onUpdateRequested(record, values) { root.saveLine(values, record); }
        function onRemoveRequested(record) {
            root.rows = root.rows.filter(function (row) { return row.id !== record.id; });
        }
    }
    Connections { target: root.validateButton; function onClicked() { root.documentRequested("validate", root.draft()); } }
    Connections { target: root.backButton; function onClicked() { root.backRequested(); } }
    Connections {
        target: root.newButton
        function onClicked() {
            root.codeField.text = "";
            root.commentField.text = "";
            root.rows = [];
            root.nextId = 1;
            root.clearLine();
            root.documentRequested("new", root.draft());
        }
    }
}
