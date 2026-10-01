import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: app

    width: 1280
    height: 720
    minimumWidth: 1024
    minimumHeight: 600

    visible: true
    title: "Azenz"

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: "../modules/login/Login.qml"
    }
}
