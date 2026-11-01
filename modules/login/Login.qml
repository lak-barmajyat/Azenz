import QtQuick
import "../../qml/components"

LoginView {
    id: root
    signal loginRequested(string username, string password, string language)
    signal quitRequested
    signal minimizeRequested
    signal maximizeRequested
    signal passwordResetRequested
    signal authenticated(string username)

    function authenticationErrorMessage(code) {
        if (code === "invalid_credentials")
            return qsTr("Nom d'utilisateur ou mot de passe incorrect.");
        if (code === "service_unavailable")
            return qsTr("Le service d'authentification est indisponible.");
        return qsTr("La connexion a échoué.");
    }

    function submit() {
        if (busy)
            return;
        errorMessage = "";
        usernameField.validationState = username.trim() ? "default" : "error";
        passwordField.validationState = password ? "default" : "error";
        if (!username.trim() || !password) {
            errorMessage = qsTr("Saisissez votre nom d'utilisateur et votre mot de passe.");
            if (!username.trim())
                usernameField.forceActiveFocus();
            else
                passwordField.forceActiveFocus();
            return;
        }
        busy = true;
        loginRequested(username.trim(), password, "fr");
    }
    // Authentication is supplied by the host. No credentials are persisted or logged.
    function completeAuthentication(success, message) {
        busy = false;
        password = "";
        passwordField.passwordVisible = false;
        if (success) {
            errorMessage = "";
            authenticated(username.trim());
        } else {
            errorMessage = authenticationErrorMessage(message);
            passwordField.forceActiveFocus();
        }
    }
    Connections {
        target: root.submitButton
        function onClicked() {
            root.submit();
        }
    }
    Connections {
        target: root.usernameField
        function onAccepted() {
            root.passwordField.forceActiveFocus();
        }
    }
    Connections {
        target: root.passwordField
        function onAccepted() {
            root.submit();
        }
    }
    Connections {
        target: root.quitButton
        function onClicked() {
            root.quitRequested();
        }
    }
    Connections {
        target: root.forgotButton
        function onClicked() {
            root.passwordResetRequested();
            help.open();
        }
    }
    Connections {
        target: root.titleBar
        function onCloseRequested() {
            root.quitRequested();
        }
        function onMinimizeRequested() {
            root.minimizeRequested();
        }
        function onMaximizeRequested() {
            root.maximizeRequested();
        }
    }
    AzenzDialog {
        id: help
        dialogType: "information"
        title: qsTr("Mot de passe oublié ?")
        message: qsTr("Contactez votre administrateur pour réinitialiser votre mot de passe.")
    }
}
