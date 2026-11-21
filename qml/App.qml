import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import "../modules/login" as LoginModule
import "../modules/shell" as ShellModule

ApplicationWindow {
    id: app

    width: 980
    height: 680
    minimumWidth: 980
    minimumHeight: 680
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2

    visible: true
    title: "Azenz"
    color: "transparent"

    flags: Qt.Window | Qt.FramelessWindowHint
    property bool signedIn: false
    property var salesRecords: []
    property var purchaseRecords: []
    property var paymentRecords: []
    property var stockRecords: []
    property var stockDocumentLines: []
    property var stockArticles: []
    property alias sales: shell.sales
    property alias purchases: shell.purchases
    property bool connected: false
    property string currentPage: "dashboard"
    signal salesActionRequested(string action, var records)
    signal purchaseActionRequested(string action, var records)
    signal paymentActionRequested(string action, var records)
    signal stockActionRequested(string action, var records)
    signal stockDocumentRequested(string action, var document)
    signal stockArticleSearchRequested(string key, string query)
    signal navigationRequested(string page)
    onCurrentPageChanged: shell.currentPage = currentPage
    function toggleMaximize() {
        if (visibility === Window.Maximized)
            showNormal();
        else
            showMaximized();
    }
    LoginModule.Login {
        id: login
        anchors.fill: parent
        visible: !app.signedIn
        onAuthenticated: function (username) {
            shell.userName = username;
            app.signedIn = true;
        }
        onQuitRequested: app.close()
        onMinimizeRequested: app.showMinimized()
        onMaximizeRequested: app.toggleMaximize()
    }
    ShellModule.Shell {
        id: shell
        anchors.fill: parent
        visible: app.signedIn
        companyName: "Atlas Distribution"
        userName: "Mohammed"
        connected: app.connected
        pageData: app.salesRecords
        purchaseRows: app.purchaseRecords
        paymentRows: app.paymentRecords
        stockRows: app.stockRecords
        stockDocumentLines: app.stockDocumentLines
        stockArticles: app.stockArticles
        onPageRequested: function (page) {
            app.currentPage = page;
        }
        onSalesActionRequested: function (action, records) {
            app.salesActionRequested(action, records);
        }
        onPurchaseActionRequested: function (action, records) {
            app.purchaseActionRequested(action, records);
        }
        onPaymentActionRequested: function (action, records) {
            app.paymentActionRequested(action, records);
        }
        onStockActionRequested: function (action, records) { app.stockActionRequested(action, records); }
        onStockDocumentRequested: function (action, document) { app.stockDocumentRequested(action, document); }
        onStockArticleSearchRequested: function (key, query) { app.stockArticleSearchRequested(key, query); }
        onQuitRequested: app.close()
        onMinimizeRequested: app.showMinimized()
        onMaximizeRequested: app.toggleMaximize()
    }
    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 8
        height: 8
        cursorShape: Qt.SizeFDiagCursor
        onPressed: app.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
    }
}
