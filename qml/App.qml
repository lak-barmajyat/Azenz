import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import "../modules/login" as LoginModule
import "../modules/shell" as ShellModule
import "components"

ApplicationWindow {
    id: app

    width: 980
    height: 680
    minimumWidth: 980
    minimumHeight: 680

    visibility: Window.Maximized
    title: "Azenz"
    color: "transparent"

    flags: Qt.Window | Qt.FramelessWindowHint
    Component.onCompleted: Qt.callLater(function () {
        app.normalBounds = Qt.rect(Screen.virtualX + (Screen.width - 980) / 2,
                                   Screen.virtualY + (Screen.height - 680) / 2, 980, 680);
    })
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
    property int visibilityBeforeFullScreen: Window.Windowed
    property var normalBounds: Qt.rect(0, 0, 980, 680)
    signal salesActionRequested(string action, var records)
    signal purchaseActionRequested(string action, var records)
    signal paymentActionRequested(string action, var records)
    signal stockActionRequested(string action, var records)
    signal stockDocumentRequested(string action, var document)
    signal stockArticleSearchRequested(string key, string query)
    signal navigationRequested(string page)
    onCurrentPageChanged: shell.currentPage = currentPage
    function rememberNormalBounds() {
        if (visibility === Window.Windowed)
            normalBounds = Qt.rect(x, y, width, height);
    }
    function restoreNormal() {
        var bounds = normalBounds;
        showNormal();
        Qt.callLater(function () {
            if (app.visibility === Window.Windowed) {
                app.x = bounds.x;
                app.y = bounds.y;
                app.width = bounds.width;
                app.height = bounds.height;
            }
        });
    }
    function toggleMaximize() {
        if (visibility === Window.Maximized || visibility === Window.FullScreen)
            restoreNormal();
        else {
            rememberNormalBounds();
            showMaximized();
        }
    }
    function toggleFullScreen() {
        if (visibility === Window.FullScreen) {
            if (visibilityBeforeFullScreen === Window.Maximized)
                showMaximized();
            else
                restoreNormal();
        } else {
            rememberNormalBounds();
            visibilityBeforeFullScreen = visibility;
            showFullScreen();
        }
    }
    Shortcut { sequence: "F11"; enabled: app.signedIn; onActivated: app.toggleFullScreen() }
    Shortcut { sequence: "Escape"; enabled: app.visibility === Window.FullScreen; onActivated: app.toggleFullScreen() }
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
        onFullScreenRequested: app.toggleFullScreen()
    }
    WindowResizeHandles { anchors.fill: parent; targetWindow: app }
}
