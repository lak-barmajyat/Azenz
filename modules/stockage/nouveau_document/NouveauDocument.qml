import QtQuick

NouveauDocumentView {
    id: root
    property var sourceRows: []
    property var articles: []
    property bool previewMode: false
    property int editingId: -1
    property int nextId: 1
    property string documentMode: "new"
    property int editingDocumentId: 0
    property int sourceDocumentId: 0
    property bool documentReady: false
    // qmllint disable unqualified
    readonly property var backend: typeof nouveauDocumentModel !== "undefined" ? nouveauDocumentModel : null
    // qmllint enable unqualified
    signal backRequested
    signal documentRequested(string action, var document)
    signal articleSearchRequested(string key, string query)

    rows: sourceRows
    documentTypes: backend ? backend.documentTypes : [
        { text: qsTr("Entrée de stock"), value: "ENTREE" },
        { text: qsTr("Sortie de stock"), value: "SORTIE" },
        { text: qsTr("Ajustement"), value: "AJUSTEMENT" },
        { text: qsTr("Inventaire"), value: "INVENTAIRE" }
    ]
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
        return { code: codeField.text, type: typeField.currentValue || "",
            date: dateField.hasValue ? Qt.formatDate(dateField.value, "yyyy-MM-dd") : "",
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
        var selectedType = typeField.currentIndex >= 0 ? documentTypes[typeField.currentIndex] : null;
        var finalCount = selectedType && ["AJUSTEMENT", "INVENTAIRE"].indexOf(selectedType.movementType) >= 0;
        if (!refField.text.trim() || !designationField.text.trim() || !isFinite(value)
                || value < 0 || (!finalCount && value === 0)) {
            formError = finalCount
                    ? qsTr("Saisissez un article et une quantité nulle ou positive.")
                    : qsTr("Saisissez un article et une quantité positive.");
            return;
        }
        var result = rows.slice();
        var suggestion = articleSuggestions.find(function (article) {
            return article.reference === refField.text.trim();
        });
        var existing = result.find(function (row) { return row.id === editingId; });
        var articleId = suggestion ? suggestion.articleId : existing ? existing.articleId : 0;
        if (!articleId) {
            formError = qsTr("Sélectionnez un article dans les résultats de recherche.");
            return;
        }
        var line = { id: editingId >= 0 ? editingId : nextId++, articleId: articleId,
            lineId: existing ? existing.lineId : null, reference: refField.text.trim(),
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
        articleSuggestions = [article];
        quantityField.forceActiveFocus();
    }
    function searchArticles(key, query) {
        if (previewMode) {
            var needle = query.toLowerCase();
            articleSuggestions = articles.filter(function (article) {
                return String(article[key] || "").toLowerCase().indexOf(needle) >= 0;
            }).slice(0, 8);
        } else if (backend)
            backend.searchArticles(key, query);
        else
            articleSearchRequested(key, query);
    }
    function openDocument(action, documentId) {
        documentMode = action === "duplicate" ? "duplicate" : action === "edit" ? "edit" : "new";
        sourceDocumentId = documentId || 0;
        documentReady = false;
        editingDocumentId = documentMode === "edit" ? documentId : 0;
        codeField.text = "";
        typeField.currentIndex = -1;
        commentField.text = "";
        rows = [];
        clearLine();
        if (backend) {
            backend.loadLookups();
        }
    }
    function typeIndex(code) {
        for (var index = 0; index < documentTypes.length; ++index)
            if (documentTypes[index].value === code)
                return index;
        return -1;
    }
    Component.onCompleted: Qt.callLater(function () { if (documentMode === "new") root.openDocument("new", 0); })
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
    Connections {
        target: root.validateButton
        function onClicked() {
            if (root.backend && !root.previewMode)
                root.backend.saveDocument(root.draft(), root.editingDocumentId);
            else
                root.documentRequested("validate", root.draft());
        }
    }
    Connections { target: root.backButton; function onClicked() { root.backRequested(); } }
    Connections {
        target: root.newButton
        function onClicked() {
            root.openDocument("new", 0);
            if (!root.backend)
                root.documentRequested("new", root.draft());
        }
    }
    Connections {
        target: root.backend
        function onLookupsChanged() {
            if (root.sourceDocumentId === 0 && root.typeField.currentIndex < 0
                    && root.documentTypes.length > 0)
                root.typeField.currentIndex = 0;
            if (root.documentTypes.length === 0)
                root.formError = qsTr("Aucun type de document de stock actif n’est configuré.");
            if (root.sourceDocumentId > 0)
                root.backend.loadDocument(root.sourceDocumentId, root.documentMode === "duplicate");
        }
        function onArticleSearchChanged() { root.articleSuggestions = root.backend.articleSearchResults; }
        function onDocumentLoaded(document) {
            root.editingDocumentId = root.documentMode === "edit" ? document.id : 0;
            root.commentField.text = document.comment;
            root.typeField.currentIndex = root.typeIndex(document.type);
            root.dateField.value = new Date(document.date + "T00:00:00");
            root.dateField.hasValue = true;
            root.sourceRows = document.lines;
            root.documentReady = true;
            if (root.documentMode === "duplicate")
                root.backend.generateDocumentCode(root.typeField.currentValue || "");
            else
                root.codeField.text = document.code;
        }
        function onDocumentCodeChanged() { root.codeField.text = root.backend.documentCode; }
        function onCodeGenerationFailed() {
            root.formError = qsTr("Impossible de générer le prochain code document.");
        }
        function onDocumentSaved(documentId, code) {
            root.editingDocumentId = documentId;
            root.codeField.text = code;
            root.backRequested();
        }
        function onValidationFailed(code) {
            root.formError = code === "negative_stock" ? qsTr("Cette opération rendrait le stock négatif.")
                           : qsTr("Vérifiez le type, la date et les lignes du document.");
        }
        function onLoadFailed(code) {
            root.formError = code === "invalid_document"
                    ? qsTr("Ce document n’existe plus.")
                    : qsTr("Impossible de charger les données du document.");
        }
        function onSaveFailed(code) {
            root.formError = code === "negative_stock" ? qsTr("Cette opération rendrait le stock négatif.")
                           : code === "duplicate_code" ? qsTr("Ce code document existe déjà.")
                           : qsTr("Impossible d’enregistrer le document.");
        }
    }
    Connections {
        target: root.typeField
        function onCurrentValueChanged() {
            if (root.backend && root.documentMode !== "edit"
                    && (root.sourceDocumentId === 0 || root.documentReady))
                root.backend.generateDocumentCode(root.typeField.currentValue || "");
        }
    }
}
