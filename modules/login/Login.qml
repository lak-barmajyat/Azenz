import QtQuick
import "../../qml/components"

LoginView {
    id: root
    signal quitRequested
    signal minimizeRequested
    signal maximizeRequested
    signal passwordResetRequested
    signal authenticated(string username)
    readonly property var backend: typeof loginModel !== "undefined" ? loginModel : null
    busy: backend ? backend.busy : false

    Component.onCompleted: Qt.callLater(function () {
        root.usernameField.forceActiveFocus();
    })

    Connections {
        target: root.backend
        function onAuthenticationCompleted(success, message, username) {
            root.completeAuthentication(success, message, username);
        }
    }

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
        if (previewMode)
            completeAuthentication(true, "", username.trim());
        else if (backend)
            backend.authenticate(username, password);
        else
            completeAuthentication(false, "service_unavailable", "");
    }
    function completeAuthentication(success, message, authenticatedUsername) {
        password = "";
        passwordField.passwordVisible = false;
        if (success) {
            errorMessage = "";
            authenticated(authenticatedUsername);
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
    AzenzDialog {
        id: help
        dialogType: "information"
        title: qsTr("Mot de passe oublié ?")
        message: qsTr("Contactez votre administrateur pour réinitialiser votre mot de passe.")
    }
}
