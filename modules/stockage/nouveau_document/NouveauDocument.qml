import QtQuick

NouveauDocumentView {
    id: root
    property var sourceRows: []
    property var articles: []
    property bool previewMode: false
    property int editingId: -1
    property int nextId: 1
    signal backRequested
    signal documentRequested(string action, var document)
    signal articleSearchRequested(string key, string query)

    rows: sourceRows
    onSourceRowsChanged: {
        rows = sourceRows;
        nextId = sourceRows.reduce(function (maximum, row) { return Math.max(maximum, Number(row.id) || 0); }, 0) + 1;
    }
    columns: [
        { key: "reference", title: qsTr("RÉF"), type: "code", width: 155 },
        { key: "description", title: qsTr("DÉSIGNATION"), width: Math.max(260, grid.width * 0.35) },
        { key: "quantity", title: qsTr("QTÉ"), alignment: "right", width: 120 },
        { key: "comment", title: qsTr("COMMENTAIRE"), width: Math.max(240, grid.width * 0.32) }
    ]

    function draft() {
        return { code: codeField.text, type: typeField.currentText,
            date: dateField.hasValue ? Qt.formatDate(dateField.value, "dd/MM/yyyy") : "",
            status: qsTr("Brouillon"), comment: commentField.text, lines: rows.slice() };
    }
    function clearLine() {
        refField.text = "";
        designationField.text = "";
        quantityField.text = "";
        lineCommentField.text = "";
        editingId = -1;
        grid.selectedIds = [];
        formError = "";
        refField.forceActiveFocus();
    }
    function saveLine() {
        var value = Number(quantityField.text.replace(",", "."));
        if (!refField.text.trim() || !designationField.text.trim() || !isFinite(value) || value <= 0) {
            formError = qsTr("Saisissez une référence, une désignation et une quantité positive.");
            return;
        }
        var result = rows.slice();
        var line = { id: editingId >= 0 ? editingId : nextId++, reference: refField.text.trim(),
            description: designationField.text.trim(), quantity: value.toFixed(2).replace(".", ","), comment: lineCommentField.text.trim() };
        var index = result.findIndex(function (row) { return row.id === editingId; });
        if (index >= 0)
            result[index] = line;
        else
            result.push(line);
        rows = result;
        clearLine();
    }
    function loadLine(record) {
        editingId = record.id;
        refField.text = record.reference;
        designationField.text = record.description;
        quantityField.text = String(record.quantity);
        lineCommentField.text = record.comment || "";
        refField.forceActiveFocus();
    }
    function chooseArticle(article) {
        refField.text = article.reference || "";
        designationField.text = article.description || "";
        articleSuggestions = [];
        quantityField.forceActiveFocus();
    }
    function searchArticles(key, query) {
        if (previewMode) {
            var needle = query.toLowerCase();
            articleSuggestions = articles.filter(function (article) {
                return String(article[key] || "").toLowerCase().indexOf(needle) >= 0;
            }).slice(0, 8);
        } else
            articleSearchRequested(key, query);
    }
    Connections { target: root.refField; function onSearchRequested(key, query) { root.searchArticles(key, query); } function onSuggestionSelected(article) { root.chooseArticle(article); } function onSubmitRequested() { root.saveLine(); } }
    Connections { target: root.designationField; function onSearchRequested(key, query) { root.searchArticles(key, query); } function onSuggestionSelected(article) { root.chooseArticle(article); } function onSubmitRequested() { root.saveLine(); } }
    Connections { target: root.quantityField; function onAccepted() { root.saveLine(); } }
    Connections { target: root.lineCommentField; function onAccepted() { root.saveLine(); } }
    Connections { target: root.saveButton; function onClicked() { root.saveLine(); } }
    Connections { target: root.cancelButton; function onClicked() { root.clearLine(); } }
    Connections {
        target: root.deleteButton
        function onClicked() {
            var ids = root.grid.selectedIds;
            root.rows = root.rows.filter(function (row) { return ids.indexOf(row.id) < 0; });
            root.clearLine();
        }
    }
    Connections { target: root.grid; function onRowActivated(record) { root.loadLine(record); } }
    Connections { target: root.validateButton; function onClicked() { root.documentRequested("validate", root.draft()); } }
    Connections { target: root.backButton; function onClicked() { root.backRequested(); } }
    Connections {
        target: root.newButton
        function onClicked() {
            root.codeField.text = "";
            root.commentField.text = "";
            root.rows = [];
            root.clearLine();
            root.documentRequested("new", root.draft());
        }
    }
}
