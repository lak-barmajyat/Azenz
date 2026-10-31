import QtQuick
import "../../modules/login" as LoginModule
import "../../modules/ventes/liste_ventes" as SalesModule
import "../../modules/ventes/liste_ventes/SalesSample.js" as Sample
import "../components"

Item {
    id: root
    width: 1600
    height: 1000
    property string screen: "login"
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
            sales.userName = username;
            root.screen = "sales";
        }
        onQuitRequested: root.closeRequested()
        onMinimizeRequested: root.minimizeRequested()
        onMaximizeRequested: root.maximizeRequested()
    }
    SalesModule.Sales {
        id: sales
        objectName: "salesScreen"
        anchors.fill: parent
        visible: root.screen === "sales"
        previewMode: true
        sourceRows: Sample.rows
        connectionText: "Aperçu local"
        connected: false
        onBackRequested: root.screen = "login"
        onQuitRequested: root.closeRequested()
        onMinimizeRequested: root.minimizeRequested()
        onMaximizeRequested: root.maximizeRequested()
        onNavigationRequested: function (page) {
            if (page !== "sales")
                notices.show("Navigation : " + page, "Ce module n'est pas inclus dans cet aperçu.", "info");
        }
        onActionRequested: function (action, records) {
            if (action === "delete") {
                var ids = records.map(function (row) {
                    return row.id;
                });
                sourceRows = sourceRows.filter(function (row) {
                    return ids.indexOf(row.id) < 0;
                });
                notices.show("Aperçu : suppression", "Les données d'exemple ont été modifiées en mémoire.");
            } else if (action === "refresh") {
                sourceRows = Sample.rows.slice();
                notices.show("Aperçu actualisé", "Les données d'exemple ont été restaurées.");
            } else
                notices.show("Action demandée : " + action, "À connecter au service métier. Aucun document réel n'est modifié.", "info");
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
