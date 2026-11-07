import QtQuick
import "../controls"
import "../theme"

Item {
    id: root
    property var value: ""
    property string cellType: "text"
    property string alignment: ["int", "dec", "currency"].indexOf(cellType) >= 0 ? "right" : "left"
    property string statusVariant: "neutral"
    property bool editable: false
    property bool editing: false
    property bool focused: false
    property bool tooltipEnabled: true
    property string suffix: ""
    signal editCommitted(var value)
    implicitWidth: 140
    implicitHeight: 28
    readonly property string displayText: {
        if (value === null || value === undefined)
            return "";
        if (cellType === "date" && value instanceof Date)
            return Qt.formatDate(value, "dd/MM/yyyy");
        if (typeof value === "number" && ["int", "dec", "currency"].indexOf(cellType) >= 0)
            return value.toLocaleString(Qt.locale("fr_FR"), "f", cellType === "int" ? 0 : 2);
        return String(value);
    }
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.navy
        visible: root.focused
    }
    Label {
        id: label
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        visible: !root.editing && ["status", "checkbox", "bool", "paymentMethod"].indexOf(root.cellType) < 0
        text: root.displayText + (root.suffix ? " " + root.suffix : "")
        font.pixelSize: 12
        tabular: true
        horizontalAlignment: root.alignment === "right" ? Text.AlignRight : root.alignment === "center" ? Text.AlignHCenter : Text.AlignLeft
        font.weight: root.cellType === "code" ? Font.Medium : Font.Normal
    }
    Badge {
        anchors.verticalCenter: parent.verticalCenter
        x: root.alignment === "center" ? (parent.width - width) / 2 : 8
        visible: root.cellType === "status"
        text: root.displayText
        variant: root.statusVariant
        dot: false
    }
    Row {
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        visible: root.cellType === "paymentMethod"
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 6
            height: 6
            radius: 3
            color: root.displayText === qsTr("Traite") ? Colors.warning : Colors.success
        }
        Label {
            text: root.displayText
            font.pixelSize: 12
            color: Colors.text
        }
    }
    AzenzCheckBox {
        anchors.centerIn: parent
        visible: root.cellType === "checkbox"
        checked: Boolean(root.value)
        enabled: root.editable
        width: 16
        height: 24
        onToggled: root.editCommitted(checked)
    }
    Icon {
        anchors.centerIn: parent
        name: root.value ? "check" : "minus"
        visible: root.cellType === "bool"
        color: root.value ? Colors.success : Colors.textSecondary
        width: 14
        height: 14
    }
    HoverHandler {
        id: hover
    }
    TapHandler {
        enabled: root.editable
        onDoubleTapped: {
            root.editing = true;
            editor.text = root.displayText;
            editor.forceActiveFocus();
            editor.selectAll();
        }
    }
    AzenzTextField {
        id: editor
        anchors.fill: parent
        visible: root.editing
        inputType: root.cellType === "currency" ? "currency" : root.cellType === "dec" || root.cellType === "int" ? "number" : "text"
        suffix: ""
        onAccepted: {
            if (acceptableInput) {
                root.editCommitted(inputType === "number" || inputType === "currency" ? Number.fromLocaleString(Qt.locale("fr_FR"), text) : text);
                root.editing = false;
            }
        }
        Keys.onEscapePressed: root.editing = false
        onActiveFocusChanged: if (!activeFocus)
            root.editing = false
    }
    AzenzToolTip {
        text: root.displayText
        visible: root.tooltipEnabled && label.truncated && hover.hovered && !root.editing
    }
}
