import QtQuick
import "../theme"

AzenzTextField {
    id: root
    property real value: 0
    property real minimum: -999999999
    property real maximum: 999999999
    property real stepSize: 1
    property int decimals: 0
    signal valueEdited(real value)
    inputType: "number"
    rightPadding: 32 + (suffix ? 40 : 0)
    text: value.toLocaleString(Qt.locale("fr_FR"), "f", decimals)
    onValueChanged: text = value.toLocaleString(Qt.locale("fr_FR"), "f", decimals)
    function step(direction) {
        if (!readOnly) {
            value = Math.max(minimum, Math.min(maximum, value + stepSize * direction));
            text = value.toLocaleString(Qt.locale("fr_FR"), "f", decimals);
            valueEdited(value);
        }
    }
    onEditingFinished: {
        var parsed = Number.fromLocaleString(Qt.locale("fr_FR"), text);
        if (!isFinite(parsed) || parsed < minimum || parsed > maximum) {
            validationState = "error";
            return;
        }
        value = parsed;
        validationState = "default";
        valueEdited(value);
    }
    Keys.onUpPressed: step(1)
    Keys.onDownPressed: step(-1)
    Column {
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        visible: !root.readOnly
        IconButton {
            iconName: "up"
            tooltip: qsTr("Augmenter")
            width: 24
            height: 14
            onClicked: root.step(1)
        }
        IconButton {
            iconName: "down"
            tooltip: qsTr("Diminuer")
            width: 24
            height: 14
            onClicked: root.step(-1)
        }
    }
}
