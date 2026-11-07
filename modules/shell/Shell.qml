import QtQuick

ShellView {
    id: root
    property var pageData: []
    readonly property var sales: root.currentPage === "sales" && pageLoader.status === Loader.Ready
                                 ? pageLoader.item : null
    readonly property var document: root.currentPage === "sales/new" && pageLoader.status === Loader.Ready
                                    ? pageLoader.item : null
    signal pageRequested(string page)
    signal salesActionRequested(string action, var records)
    signal documentSaveRequested(var document)

    Loader {
        id: pageLoader
        anchors.fill: root.contentFrame
        source: root.currentPage === "sales"
                ? "../ventes/liste_ventes/Ventes.qml"
                : root.currentPage === "sales/new"
                ? "../ventes/nouveau_document/NouveauDocument.qml" : ""
        onLoaded: {
            if (root.currentPage === "sales")
                item.sourceRows = root.pageData;
            else if (root.currentPage === "sales/new")
                item.previewMode = root.previewMode;
        }
        Connections {
            target: root.sales
            ignoreUnknownSignals: true
            function onBackRequested() {
                root.showPage("dashboard");
            }
            function onActionRequested(action, records) {
                if (action === "new")
                    root.showPage("sales/new");
                else
                    root.salesActionRequested(action, records);
            }
        }
        Connections {
            target: root.document
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("sales"); }
            function onSaveRequested(document) { root.documentSaveRequested(document); }
        }
    }

    function showPage(page) {
        currentPage = page;
        pageRequested(page);
    }

    onPageDataChanged: if (root.sales)
        root.sales.sourceRows = pageData;

    onNavigationRequested: function (page) {
        showPage(page);
    }
}
