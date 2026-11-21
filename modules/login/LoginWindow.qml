import QtQuick
import QtQuick.Controls.Basic

ApplicationWindow {
    width: 980
    height: 680
    minimumWidth: 980
    minimumHeight: 680
    visible: true
    title: qsTr("Azenz — Connexion")

    Login {
        anchors.fill: parent
        onQuitRequested: Qt.quit()
        onAuthenticated: Qt.quit()
    }
}
