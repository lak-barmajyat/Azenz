import QtQuick
import QtQuick.Layouts
import "../../qml/controls"
import "../../qml/components"
import "../../qml/theme"

Rectangle {
    id: root
    width: 1280
    height: 800
    color: Colors.canvas
    property string language: "fr"
    property bool busy: false
    property bool previewMode: false
    property string errorMessage: ""
    property alias username: username.text
    property alias password: password.text
    property alias usernameField: username
    property alias passwordField: password
    property alias submitButton: submit
    property alias quitButton: quit
    property alias forgotButton: forgot
    property alias languageControl: languages
    property alias titleBar: titleBar

    WindowTitleBar {
        id: titleBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }
    Rectangle {
        id: shadow
        x: card.x - 7
        y: card.y + 12
        width: card.width + 14
        height: card.height + 7
        color: "#090F2740"
        radius: 20
    }
    Rectangle {
        id: card
        width: Math.min(860, parent.width - 64)
        height: Math.min(560, parent.height - titleBar.height - 64)
        anchors.horizontalCenter: parent.horizontalCenter
        y: titleBar.height + (parent.height - titleBar.height - height) / 2
        radius: 16
        color: "white"
        border.color: Colors.border
        clip: true
        Rectangle {
            id: brand
            width: parent.width / 2
            height: parent.height
            radius: 16
            clip: true
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#0D2840"
                }
                GradientStop {
                    position: 1
                    color: "#16446C"
                }
            }
            Rectangle {
                anchors.right: parent.right
                width: 16
                height: parent.height
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#0D2840"
                    }
                    GradientStop {
                        position: 1
                        color: "#16446C"
                    }
                }
            }
            Rectangle {
                x: brand.width - 170
                y: -65
                width: 256
                height: 256
                radius: 24
                rotation: 45
                color: "#16F17D24"
            }
            Rectangle {
                x: brand.width - 150
                y: 120
                width: 176
                height: 176
                radius: 16
                rotation: 45
                color: "#0DFFFFFF"
                border.color: "#1AFFFFFF"
            }
            Rectangle {
                x: 48
                y: brand.height - 155
                width: 224
                height: 224
                radius: 24
                rotation: 12
                color: "#13F17D24"
            }
            Rectangle {
                x: brand.width - 145
                y: brand.height - 115
                width: 96
                height: 96
                radius: 12
                rotation: 45
                color: "#20F17D24"
            }
            RowLayout {
                x: 40
                y: 40
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: Colors.accent
                }
                Label {
                    text: "ERP DESKTOP v2.4"
                    color: "#CBD5E1"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    font.letterSpacing: 1
                }
            }
            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                Logo {
                    variant: "dark"
                    Layout.preferredWidth: 132
                    Layout.preferredHeight: 132
                    Layout.bottomMargin: 8
                }
                Label {
                    text: "AZENZ ERP"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: "white"
                }
                Label {
                    text: qsTr("Powerful, modular and intuitive integrated business management solutions.")
                    arabic: root.language === "ar"
                    color: "#CBD5E1"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    lineHeight: 1.4
                }
            }
            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 40
                spacing: 16
                Rectangle {
                    color: "#1AFFFFFF"
                    Layout.fillWidth: true
                    height: 1
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: qsTr("Certified & secure system")
                        arabic: root.language === "ar"
                        color: "#94A3B8"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                    }
                    Label {
                        text: "© 2025 AZENZ"
                        color: "#94A3B8"
                        font.pixelSize: 10
                    }
                }
            }
        }
        Item {
            anchors.left: brand.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            AzenzComboBox {
                id: languages
                objectName: "loginLanguage"
                x: parent.width - width - 40
                y: 32
                width: 124
                height: 28
                model: [
                    {
                        text: "Français",
                        value: "fr"
                    },
                    {
                        text: "العربية",
                        value: "ar"
                    },
                    {
                        text: "English",
                        value: "en"
                    }
                ]
                currentIndex: 0
                enabled: !root.busy
            }
            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                y: 90
                spacing: 14
                LayoutMirroring.enabled: root.language === "ar"
                LayoutMirroring.childrenInherit: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        text: qsTr("Sign in")
                        arabic: root.language === "ar"
                        color: Colors.navy
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }
                    Label {
                        text: qsTr("Enter your credentials to access your workspace.")
                        arabic: root.language === "ar"
                        color: Colors.textSecondary
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        lineHeight: 1.4
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 6
                    Label {
                        text: qsTr("Username")
                        arabic: root.language === "ar"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }
                    AzenzTextField {
                        id: username
                        objectName: "loginUsername"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        cornerRadius: 8
                        LayoutMirroring.enabled: false
                        LayoutMirroring.childrenInherit: true
                        leadingIcon: "users"
                        placeholderText: qsTr("Enter your username")
                        enabled: !root.busy
                        Accessible.name: qsTr("Username")
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: qsTr("Password")
                            arabic: root.language === "ar"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                        AzenzButton {
                            id: forgot
                            text: qsTr("Forgot password?")
                            variant: "ghost"
                            size: "compact"
                            leftPadding: 0
                            rightPadding: 0
                            implicitHeight: 18
                            font.pixelSize: 11
                        }
                    }
                    AzenzTextField {
                        id: password
                        objectName: "loginPassword"
                        inputType: "password"
                        placeholderText: "••••••••"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        cornerRadius: 8
                        LayoutMirroring.enabled: false
                        LayoutMirroring.childrenInherit: true
                        enabled: !root.busy
                        Accessible.name: qsTr("Password")
                    }
                }
                Label {
                    text: root.errorMessage
                    arabic: root.language === "ar"
                    visible: text !== ""
                    color: Colors.danger
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                AzenzButton {
                    id: submit
                    objectName: "loginSubmit"
                    text: root.busy ? qsTr("Signing in…") : qsTr("Sign in")
                    cornerRadius: 8
                    loading: root.busy
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.topMargin: 4
                }
                AzenzButton {
                    id: quit
                    text: qsTr("Quit application")
                    iconName: "logout"
                    cornerRadius: 8
                    variant: "secondary"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        radius: 8
                        color: quit.hovered ? Colors.canvas : "white"
                        border.color: quit.visualFocus ? Colors.accent : Colors.border
                    }
                }
            }
            Label {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 24
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                horizontalAlignment: Text.AlignHCenter
                text: root.previewMode ? qsTr("Local preview • Credentials are not verified") : qsTr("Secure workstation • Local session")
                arabic: root.language === "ar"
                font.pixelSize: 10
                color: "#94A3B8"
            }
        }
    }
}
