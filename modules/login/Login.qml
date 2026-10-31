import QtQuick
import "LoginCopy.js" as LoginCopy
import "../../qml/components"

LoginView {
    id: root
    signal loginRequested(string username, string password, string language)
    signal quitRequested
    signal minimizeRequested
    signal maximizeRequested
    signal passwordResetRequested
    signal authenticated(string username)
    copy: LoginCopy.translations[language] || LoginCopy.translations.fr
    onLanguageChanged: languageControl.currentIndex = Math.max(0, ["fr", "ar", "en"].indexOf(language))

    function submit() {
        if (busy)
            return;
        errorMessage = "";
        usernameField.validationState = username.trim() ? "default" : "error";
        passwordField.validationState = password ? "default" : "error";
        if (!username.trim() || !password) {
            errorMessage = copy.required;
            if (!username.trim())
                usernameField.forceActiveFocus();
            else
                passwordField.forceActiveFocus();
            return;
        }
        busy = true;
        loginRequested(username.trim(), password, language);
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
            errorMessage = message || "Connexion refusée.";
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
        target: root.languageControl
        function onActivated(index) {
            root.language = root.languageControl.currentValue;
            root.errorMessage = "";
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
        title: root.copy.forgot
        message: root.copy.help
    }
}
