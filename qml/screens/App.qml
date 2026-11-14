import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic

ApplicationWindow {
    id: window
    width: 1600
    height: 1000
    minimumWidth: 1200
    minimumHeight: 700
    visible: true
    title: "AZENZ • Aperçu Connexion & Ventes"
    flags: Qt.Window | Qt.FramelessWindowHint
    function toggleMaximize() {
        if (visibility === Window.Maximized)
            showNormal();
        else
            showMaximized();
    }
    ScreensPreview {
        anchors.fill: parent
        screen: Qt.application.arguments.indexOf("--reglements") >= 0 ? "payments"
                : Qt.application.arguments.indexOf("--nouveau-document") >= 0 ? "new-document"
                : Qt.application.arguments.indexOf("--ventes") >= 0 ? "ventes" : "login"
        onCloseRequested: window.close()
        onMinimizeRequested: window.showMinimized()
        onMaximizeRequested: window.toggleMaximize()
    }
    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 8
        height: 8
        cursorShape: Qt.SizeFDiagCursor
        onPressed: window.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
    }
}
