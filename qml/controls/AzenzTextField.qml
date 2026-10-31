import QtQuick
import QtQuick.Controls.Basic as C
import "../theme"

C.TextField {
    id: root
    property string density: Theme.densityFor(parent)
    property real cornerRadius: 4
    property string inputType: "text" // text, number, currency, search, password, documentCode
    property string validationState: "default" // default, error, valid
    property string leadingIcon: inputType === "search" ? "search" : inputType === "password" ? "lock" : ""
    property string trailingIcon: ""
    property string trailingToolTip: ""
    property string prefix: ""
    property string suffix: inputType === "currency" ? "MAD" : inputType === "search" && shortcutEnabled ? "Ctrl+K" : ""
    property bool passwordVisible: false
    property bool shortcutEnabled: false
    property bool clearable: inputType === "search"
    signal trailingClicked
    implicitWidth: 240
    implicitHeight: Theme.controlHeight(density)
    leftPadding: 10 + (leadingIcon ? 24 : 0) + (prefix ? prefixLabel.implicitWidth + 8 : 0)
    rightPadding: 10 + (suffix ? suffixLabel.implicitWidth + 8 : 0) + (trailing.visible ? 26 : 0)
    font.family: Typography.latin
    font.pixelSize: density === "comfortable" ? 13 : 12
    font.features: {
        "tnum": 1
    }
    color: enabled ? Colors.text : Colors.disabledText
    placeholderTextColor: Colors.textSecondary
    selectionColor: Colors.rowSelected
    selectedTextColor: Colors.navy
    selectByMouse: true
    hoverEnabled: true
    echoMode: inputType === "password" && !passwordVisible ? TextInput.Password : TextInput.Normal
    horizontalAlignment: inputType === "number" || inputType === "currency" ? TextInput.AlignRight : TextInput.AlignLeft
    inputMethodHints: inputType === "password" ? Qt.ImhHiddenText | Qt.ImhNoPredictiveText : inputType === "number" || inputType === "currency" ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone
    validator: inputType === "number" || inputType === "currency" ? numericValidator : null
    DoubleValidator {
        id: numericValidator
        locale: "fr_FR"
        decimals: root.inputType === "currency" ? 2 : 6
        notation: DoubleValidator.StandardNotation
    }
    background: Rectangle {
        radius: root.cornerRadius
        color: !root.enabled ? Colors.disabled : root.readOnly ? Colors.canvas : Colors.surface
        border.width: root.activeFocus ? 2 : 1
        border.color: root.validationState === "error" ? Colors.danger : root.validationState === "valid" ? Colors.success : root.activeFocus ? Colors.accent : root.hovered ? Colors.borderStrong : Colors.border
    }
    Icon {
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        visible: root.leadingIcon !== ""
        name: root.leadingIcon || "info"
        width: 16
        height: 16
    }
    Label {
        id: prefixLabel
        x: 10 + (root.leadingIcon ? 24 : 0)
        anchors.verticalCenter: parent.verticalCenter
        text: root.prefix
        font.pixelSize: 11
        color: Colors.textSecondary
    }
    Label {
        id: suffixLabel
        anchors.right: parent.right
        anchors.rightMargin: 10 + (trailing.visible ? 26 : 0)
        anchors.verticalCenter: parent.verticalCenter
        text: root.suffix
        font.pixelSize: 11
        color: Colors.textSecondary
    }
    IconButton {
        id: trailing
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        visible: root.inputType === "password" || root.trailingIcon !== "" || (root.clearable && root.text !== "" && !root.readOnly)
        iconName: root.inputType === "password" ? "eye" : root.trailingIcon || "close"
        tooltip: root.trailingToolTip || (root.inputType === "password" ? qsTr("Afficher / masquer le mot de passe") : root.trailingIcon ? qsTr("Options") : qsTr("Effacer"))
        onClicked: {
            if (root.inputType === "password")
                root.passwordVisible = !root.passwordVisible;
            else if (!root.trailingIcon && !root.readOnly)
                root.clear();
            root.forceActiveFocus();
            // Let popup handlers transfer focus after the field receives it.
            root.trailingClicked();
        }
    }
    Shortcut {
        sequence: "Ctrl+K"
        enabled: root.shortcutEnabled && root.visible && root.enabled
        onActivated: root.forceActiveFocus()
    }
}
