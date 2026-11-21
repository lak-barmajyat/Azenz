import QtQuick

ShellView {
    id: root
    property var pageData: []
    property var paymentRows: []
    property string documentAction: "new"
    property int documentId: 0
    documentPageTitle: documentAction === "edit" ? qsTr("Modifier le document")
                       : documentAction === "duplicate" ? qsTr("Dupliquer le document")
                       : qsTr("Nouveau document")
    readonly property var sales: root.currentPage === "sales" && pageLoader.status === Loader.Ready
                                 ? pageLoader.item : null
    readonly property var document: root.currentPage === "sales/new" && pageLoader.status === Loader.Ready
                                    ? pageLoader.item : null
    readonly property var payments: root.currentPage === "payments" && pageLoader.status === Loader.Ready
                                    ? pageLoader.item : null
    signal pageRequested(string page)
    signal salesActionRequested(string action, var records)
    signal paymentActionRequested(string action, var records)

    Loader {
        id: pageLoader
        anchors.fill: root.contentFrame
        source: root.currentPage === "sales"
                ? "../ventes/liste_ventes/ListeVentes.qml"
                : root.currentPage === "sales/new"
                ? "../ventes/nouveau_doc/NouveauDoc.qml"
                : root.currentPage === "payments"
                ? "../reglements/Reglements.qml" : ""
        onLoaded: {
            if (root.currentPage === "sales") {
                item.previewMode = root.previewMode;
                item.sourceRows = root.pageData;
            } else if (root.currentPage === "sales/new") {
                item.previewMode = root.previewMode;
                root.document.openDocument(root.documentAction, root.documentId);
            } else if (root.currentPage === "payments") {
                item.sourceRows = root.paymentRows;
                item.previewMode = root.previewMode;
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
            target: root.document
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("sales"); }
        }
        Connections {
            target: root.payments
            ignoreUnknownSignals: true
            function onBackRequested() { root.showPage("dashboard"); }
            function onActionRequested(action, records) { root.paymentActionRequested(action, records); }
        }
    }

    function showPage(page) {
        currentPage = page;
        pageRequested(page);
    }

    onPageDataChanged: if (root.sales)
        root.sales.sourceRows = pageData;
    onPaymentRowsChanged: if (root.payments)
        root.payments.sourceRows = paymentRows;

    onNavigationRequested: function (page) {
        showPage(page);
    }

    Connections {
        target: root.titleBar
        function onCloseRequested() { root.quitRequested(); }
        function onMinimizeRequested() { root.minimizeRequested(); }
        function onMaximizeRequested() { root.maximizeRequested(); }
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
