import QtQuick

ShellView {
    id: root
    property var pageData: []
    property var purchaseRows: []
    property var paymentRows: []
    property var stockRows: []
    property var stockDocumentLines: []
    property var stockArticles: []
    property string documentAction: "new"
    property int documentId: 0
    property string stockDocumentAction: "new"
    property int stockDocumentId: 0
    documentPageTitle: documentAction === "edit" ? qsTr("Modifier le document")
                       : documentAction === "duplicate" ? qsTr("Dupliquer le document")
                       : qsTr("Nouveau document")
    readonly property var sales: root.currentPage === "sales" && pageLoader.status === Loader.Ready
                                 ? pageLoader.item : null
    readonly property var purchases: root.currentPage === "purchases"
                                     && pageLoader.status === Loader.Ready
                                     ? pageLoader.item : null
    readonly property var document: root.currentPage === "sales/new" && pageLoader.status === Loader.Ready
                                    ? pageLoader.item : null
    readonly property var purchaseDocument: root.currentPage === "purchases/new"
                                            && pageLoader.status === Loader.Ready
                                            ? pageLoader.item : null
    readonly property var payments: root.currentPage === "payments" && pageLoader.status === Loader.Ready
                                    ? pageLoader.item : null
    readonly property var stock: root.currentPage === "stock" && pageLoader.status === Loader.Ready
                                 ? pageLoader.item : null
    readonly property var stockDocument: root.currentPage === "stock/new" && pageLoader.status === Loader.Ready
                                         ? pageLoader.item : null
    signal pageRequested(string page)
    signal salesActionRequested(string action, var records)
    signal purchaseActionRequested(string action, var records)
    signal paymentActionRequested(string action, var records)
    signal stockActionRequested(string action, var records)
    signal stockDocumentRequested(string action, var document)
    signal stockArticleSearchRequested(string key, string query)

    Loader {
        id: pageLoader
        anchors.fill: root.contentFrame
        source: root.currentPage === "sales"
                ? "../ventes/liste_ventes/ListeVentes.qml"
                : root.currentPage === "purchases"
                ? "../achats/liste_achats/ListeAchats.qml"
                : root.currentPage === "sales/new"
                ? "../ventes/nouveau_doc/NouveauDoc.qml"
                : root.currentPage === "purchases/new"
                ? "../achats/nouveau_doc/NouveauDoc.qml"
                : root.currentPage === "payments"
                ? "../reglements/Reglements.qml"
                : root.currentPage === "stock"
                ? "../stockage/liste_stock/ListeStock.qml"
                : root.currentPage === "stock/new"
                ? "../stockage/nouveau_document/NouveauDocument.qml" : ""
        onLoaded: {
            if (root.currentPage === "sales") {
                item.previewMode = root.previewMode;
                item.sourceRows = root.pageData;
            } else if (root.currentPage === "purchases") {
                item.previewMode = root.previewMode;
                item.sourceRows = root.purchaseRows;
            } else if (root.currentPage === "sales/new") {
                item.previewMode = root.previewMode;
                root.document.openDocument(root.documentAction, root.documentId);
            } else if (root.currentPage === "payments") {
                item.sourceRows = root.paymentRows;
                item.previewMode = root.previewMode;
            } else if (root.currentPage === "stock") {
                item.sourceRows = root.stockRows;
                item.previewMode = root.previewMode;
            } else if (root.currentPage === "stock/new") {
                item.previewMode = root.previewMode;
                if (root.previewMode) {
                    item.sourceRows = root.stockDocumentLines;
                    item.articles = root.stockArticles;
                }
                item.openDocument(root.stockDocumentAction, root.stockDocumentId);
            }
        }
        Connections {
            target: root.sales
            ignoreUnknownSignals: true
            function onBackRequested() {
                root.showPage("dashboard");
            }
            function onActionRequested(action, records) {
                if (action === "new") {
                    root.documentAction = "new";
                    root.documentId = 0;
                    root.showPage("sales/new");
                } else if (["edit", "open", "duplicate"].indexOf(action) >= 0 && records.length === 1) {
                    root.documentAction = action === "duplicate" ? "duplicate" : "edit";
                    root.documentId = records[0].id;
                    root.showPage("sales/new");
                } else {
                    root.salesActionRequested(action, records);
                }
            }
        }
        Connections {
            target: root.purchases
            ignoreUnknownSignals: true
            function onBackRequested() {
                root.showPage("dashboard");
            }
            function onActionRequested(action, records) {
                if (action === "new") {
                    root.purchaseDocumentAction = "new";
                    root.purchaseDocumentId = 0;
                    root.showPage("purchases/new");
                } else if (["edit", "open", "duplicate"].indexOf(action) >= 0 && records.length === 1) {
                    root.purchaseDocumentAction = action === "duplicate" ? "duplicate" : "edit";
                    root.purchaseDocumentId = records[0].id;
                    root.showPage("purchases/new");
                } else {
                    root.purchaseActionRequested(action, records);
                }
            }
        }
        Connections {
            target: root.document
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("sales"); }
        }
        Connections {
            target: root.purchaseDocument
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("purchases"); }
        }
        Connections {
            target: root.payments
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("dashboard"); }
            function onActionRequested(action, records) { root.paymentActionRequested(action, records); }
        }
        Connections {
            target: root.stock
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("dashboard"); }
            function onActionRequested(action, records) {
                if (action === "new") {
                    root.stockDocumentAction = "new";
                    root.stockDocumentId = 0;
                    root.showPage("stock/new");
                } else if (["edit", "open", "duplicate"].indexOf(action) >= 0 && records.length === 1) {
                    root.stockDocumentAction = action === "duplicate" ? "duplicate" : "edit";
                    root.stockDocumentId = records[0].id;
                    root.showPage("stock/new");
                } else
                    root.stockActionRequested(action, records);
            }
        }
        Connections {
            target: root.stockDocument
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("stock"); }
            function onDocumentRequested(action, document) { root.stockDocumentRequested(action, document); }
            function onArticleSearchRequested(key, query) { root.stockArticleSearchRequested(key, query); }
        }
    }

    function showPage(page) {
        currentPage = page;
        pageRequested(page);
    }

    onPageDataChanged: if (root.sales)
        root.sales.sourceRows = pageData;
    onPurchaseRowsChanged: if (root.purchases)
        root.purchases.sourceRows = purchaseRows;
    onPaymentRowsChanged: if (root.payments)
        root.payments.sourceRows = paymentRows;
    onStockRowsChanged: if (root.stock)
        root.stock.sourceRows = stockRows;
    onStockDocumentLinesChanged: if (root.stockDocument)
        root.stockDocument.sourceRows = stockDocumentLines;
    onStockArticlesChanged: if (root.stockDocument)
        root.stockDocument.articles = stockArticles;

    onNavigationRequested: function (page) {
        showPage(page);
    }

    Connections {
        target: root.titleBar
        function onCloseRequested() { root.quitRequested(); }
        function onMinimizeRequested() { root.minimizeRequested(); }
        function onMaximizeRequested() { root.maximizeRequested(); }
        function onFullScreenRequested() { root.fullScreenRequested(); }
    }
    Connections {
        target: root.menuBar
        function onCommandTriggered(command) {
            if (command === "quit")
                root.quitRequested();
            else if (command === "sidebar")
                root.sidebar.collapsed = !root.sidebar.collapsed;
        }
    }
    Connections {
        target: root.sidebar
        function onNavigate(page) { root.navigationRequested(page); }
    }
}
