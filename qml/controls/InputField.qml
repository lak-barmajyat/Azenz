import QtQuick
import QtQuick.Layouts
import "../theme"

ColumnLayout {
    id: root
    property string density: Theme.densityFor(parent)
    property string label: ""
    property bool required: false
    property string helperText: ""
    property string errorMessage: ""
    property alias text: input.text
    property alias placeholderText: input.placeholderText
    property alias inputType: input.inputType
    property alias readOnly: input.readOnly
    property alias validationState: input.validationState
    property alias leadingIcon: input.leadingIcon
    property alias trailingIcon: input.trailingIcon
    property alias prefix: input.prefix
    property alias suffix: input.suffix
    property alias field: input
    signal accepted
    spacing: 4
    implicitWidth: 240
    Label {
        text: root.label + (root.required ? " *" : "")
        visible: root.label !== ""
        font.pixelSize: 12
        font.weight: Font.Medium
        Layout.fillWidth: true
    }
    AzenzTextField {
        id: input
        density: root.density
        Layout.fillWidth: true
        Accessible.name: root.label
        onAccepted: root.accepted()
    }
    Label {
        text: root.errorMessage || root.helperText
        visible: text !== ""
        color: root.errorMessage ? Colors.danger : Colors.textSecondary
        font.pixelSize: 11
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
}
