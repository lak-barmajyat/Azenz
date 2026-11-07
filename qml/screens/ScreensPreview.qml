import QtQuick
import "../../modules/login" as LoginModule
import "../../modules/shell" as ShellModule
import "../../modules/ventes/liste_ventes/VentesSample.js" as Sample
import "../components"

Item {
    id: root
    width: 1600
    height: 1000
    property string screen: "login"
    onScreenChanged: if (screen !== "login")
        shell.currentPage = screen === "ventes" ? "sales"
                            : screen === "new-document" ? "sales/new" : screen
    signal closeRequested
    signal minimizeRequested
    signal maximizeRequested
    LoginModule.Login {
        id: login
        objectName: "loginScreen"
        anchors.fill: parent
        visible: root.screen === "login"
        previewMode: true
        onLoginRequested: function (username, password, language) {
            login.completeAuthentication(true, "");
        }
        onAuthenticated: function (username) {
            shell.userName = username;
            root.screen = "ventes";
        }
        onQuitRequested: root.closeRequested()
        onMinimizeRequested: root.minimizeRequested()
        onMaximizeRequested: root.maximizeRequested()
    }
    ShellModule.Shell {
        id: shell
        objectName: "previewShell"
        anchors.fill: parent
        visible: root.screen !== "login"
        previewMode: true
        currentPage: root.screen === "ventes" ? "sales"
                     : root.screen === "new-document" ? "sales/new"
                     : root.screen === "login" ? "dashboard" : root.screen
        pageData: Sample.rows
        connected: false
        onQuitRequested: root.closeRequested()
        onMinimizeRequested: root.minimizeRequested()
        onMaximizeRequested: root.maximizeRequested()
        onPageRequested: function (page) {
            root.screen = page === "sales" ? "ventes"
                          : page === "sales/new" ? "new-document" : page;
            if (page !== "sales" && page !== "sales/new" && page !== "payments" && page !== "dashboard")
                notices.show(qsTr("Navigation : %1").arg(page),
                             qsTr("Ce module n'est pas inclus dans cet aperçu."), "info");
        }
        onSalesActionRequested: function (action, records) {
            if (action === "delete") {
                var ids = records.map(function (row) {
                    return row.id;
                });
                shell.pageData = shell.pageData.filter(function (row) {
                    return ids.indexOf(row.id) < 0;
                });
                notices.show(qsTr("Aperçu : suppression"), qsTr("Les données d'exemple ont été modifiées en mémoire."));
            } else if (action === "refresh") {
                shell.pageData = Sample.rows.slice();
                notices.show(qsTr("Aperçu actualisé"), qsTr("Les données d'exemple ont été restaurées."));
            } else
                notices.show(qsTr("Action demandée : %1").arg(action),
                             qsTr("À connecter au service métier. Aucun document réel n'est modifié."), "info");
        }
        onDocumentSaveRequested: function (document) {
            notices.show(qsTr("Document prêt à enregistrer"),
                         qsTr("Aperçu local : aucun document réel n'a été enregistré."), "info");
        }
        onPaymentActionRequested: function (action, records) {
            notices.show(qsTr("Action règlement : %1").arg(action),
                         qsTr("Aperçu local : aucun règlement réel n'a été modifié."), "info");
        }
    }
    ToastHost {
        id: notices
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        anchors.topMargin: 70
    }
}
