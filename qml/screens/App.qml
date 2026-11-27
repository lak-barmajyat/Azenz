import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import "../components"

ApplicationWindow {
    id: window
    width: 1600
    height: 1000
    minimumWidth: 1200
    minimumHeight: 700
    visible: true
    title: "AZENZ • Aperçu Connexion & Ventes"
    flags: Qt.Window | Qt.FramelessWindowHint
    Component.onCompleted: Qt.callLater(function () {
        if (window.visibility === Window.Windowed) {
            window.x = Screen.virtualX + (Screen.width - window.width) / 2;
            window.y = Screen.virtualY + (Screen.height - window.height) / 2;
        }
    })
    property int visibilityBeforeFullScreen: Window.Windowed
    property var normalBounds: Qt.rect(0, 0, width, height)
    function rememberNormalBounds() {
        if (visibility === Window.Windowed)
            normalBounds = Qt.rect(x, y, width, height);
    }
    function restoreNormal() {
        var bounds = normalBounds;
        showNormal();
        Qt.callLater(function () {
            if (window.visibility === Window.Windowed) {
                window.x = bounds.x;
                window.y = bounds.y;
                window.width = bounds.width;
                window.height = bounds.height;
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
    Shortcut { sequence: "F11"; onActivated: window.toggleFullScreen() }
    Shortcut { sequence: "Escape"; enabled: window.visibility === Window.FullScreen; onActivated: window.toggleFullScreen() }
    ScreensPreview {
        anchors.fill: parent
        screen: Qt.application.arguments.indexOf("--reglements") >= 0 ? "payments"
                : Qt.application.arguments.indexOf("--nouveau-document") >= 0 ? "new-document"
                : Qt.application.arguments.indexOf("--ventes") >= 0 ? "ventes" : "login"
        onCloseRequested: window.close()
        onMinimizeRequested: window.showMinimized()
        onMaximizeRequested: window.toggleMaximize()
        onFullScreenRequested: window.toggleFullScreen()
    }
    WindowResizeHandles { anchors.fill: parent; targetWindow: window }
}
