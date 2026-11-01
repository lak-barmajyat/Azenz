import QtQuick

ShellView {
    id: root
    property string currentPage: "dashboard"
    property var pageData: []
    signal pageRequested(string page)

    Loader {
        id: pageLoader
        anchors.fill: root.contentFrame
        source: root.currentPage === "sales"
                ? "../ventes/liste_ventes/Ventes.qml"
                : ""
        onLoaded: {
            if (item)
                item.sourceRows = root.pageData;
        }
        Connections {
            target: pageLoader.item
            function onBackRequested() {
                root.showPage("dashboard");
            }
        }
    }

    function showPage(page) {
        currentPage = page;
        pageRequested(page);
    }

    onPageDataChanged: if (pageLoader.item)
        pageLoader.item.sourceRows = pageData;

    onNavigationRequested: function (page) {
        showPage(page);
    }
}
