import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import "../modules/login" as LoginModule
import "../modules/ventes/liste_ventes" as SalesModule

ApplicationWindow {
    id: app

    width: 1600
    height: 1000
    minimumWidth: 1200
    minimumHeight: 700

    visible: true
    title: "Azenz"

    flags: Qt.Window | Qt.FramelessWindowHint
    property bool authenticationAvailable: false
    property bool signedIn: false
    property var salesRecords: []
    property bool connected: false
    property var authModel: null
    signal salesActionRequested(string action, var records)
    signal navigationRequested(string page)
    function completeAuthentication(success, message) {
        login.completeAuthentication(success, message);
    }
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
        onLoginRequested: function (username, password, language) {
            if (app.authenticationAvailable)
                app.authModel.authenticate(username, password, language);
            else
                app.completeAuthentication(false, "Le service d'authentification n'est pas encore connecté.");
        }
        onAuthenticated: function (username) {
            sales.userName = username;
            app.signedIn = true;
        }
        onQuitRequested: app.close()
        onMinimizeRequested: app.showMinimized()
        onMaximizeRequested: app.toggleMaximize()
    }
    SalesModule.Sales {
        id: sales
        anchors.fill: parent
        visible: app.signedIn
        sourceRows: app.salesRecords
        connected: app.connected
        connectionText: connected ? "Connecté" : "Hors connexion"
        onActionRequested: function (action, records) {
            app.salesActionRequested(action, records);
        }
        onNavigationRequested: function (page) {
            app.navigationRequested(page);
        }
        onBackRequested: app.signedIn = false
        onQuitRequested: app.close()
        onMinimizeRequested: app.showMinimized()
        onMaximizeRequested: app.toggleMaximize()
    }
    Connections {
        target: app.authModel
        function onAuthenticationCompleted(success, message, username) {
            if (success) {
                sales.userName = username;
                app.signedIn = true;
                login.completeAuthentication(true, "");
            } else {
                login.completeAuthentication(false, message);
            }
        }
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
