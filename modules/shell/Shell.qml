import QtQuick

ShellView {
    id: root
    property string currentPage: "dashboard"
    property var sales: pageLoader.item
    signal pageRequested(string page)

    Loader {
        id: pageLoader
        anchors.fill: root.contentFrame
        source: root.currentPage === "sales"
                ? "../ventes/liste_ventes/ListeVentes.qml"
                : ""
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

    onNavigationRequested: function (page) {
        showPage(page);
    }
}
