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
    property bool authenticationAvailable: false
    property bool signedIn: false
    property var salesRecords: []
    property alias sales: shell.sales
    property bool connected: false
    property var authModel: null
    property string currentPage: "dashboard"
    signal salesActionRequested(string action, var records)
    signal navigationRequested(string page)
    onCurrentPageChanged: shell.currentPage = currentPage
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
        onPageRequested: app.currentPage = page
        onQuitRequested: app.close()
        onMinimizeRequested: app.showMinimized()
        onMaximizeRequested: app.toggleMaximize()
    }
    Connections {
        target: app.authModel
        function onAuthenticationCompleted(success, message, username) {
            if (success) {
                shell.userName = username;
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
