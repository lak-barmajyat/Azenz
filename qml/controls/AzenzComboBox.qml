pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../theme"

C.Control {
    id: root
    property string density: Theme.densityFor(parent)
    property var model: [] // strings or {text, value, enabled}
    property int currentIndex: -1
    property bool searchable: false
    property string placeholderText: qsTr("Sélectionner…")
    property string validationState: "default"
    readonly property string currentText: currentIndex >= 0 && currentIndex < model.length ? labelFor(model[currentIndex]) : ""
    readonly property var currentValue: currentIndex >= 0 && currentIndex < model.length ? model[currentIndex].value !== undefined ? model[currentIndex].value : model[currentIndex] : null
    property alias popup: popup
    signal activated(int index)
    implicitWidth: 240
    implicitHeight: Theme.controlHeight(density)
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    Accessible.role: Accessible.ComboBox
    Accessible.name: currentText || placeholderText
    function labelFor(entry) {
        return typeof entry === "string" ? entry : entry.text || "";
    }
    function allowed(index) {
        return index >= 0 && index < model.length && model[index].enabled !== false;
    }
    function choose(index) {
        if (!allowed(index))
            return;
        currentIndex = index;
        activated(index);
        popup.close();
        forceActiveFocus();
    }
    function move(delta) {
        for (var i = list.currentIndex + delta; i >= 0 && i < filtered.length; i += delta) {
            if (allowed(filtered[i])) {
                list.currentIndex = i;
                list.positionViewAtIndex(i, ListView.Contain);
                return;
            }
        }
    }
    readonly property var filtered: {
        var result = [];
        for (var i = 0; i < model.length; ++i)
            if (!search.text || labelFor(model[i]).toLowerCase().indexOf(search.text.toLowerCase()) >= 0)
                result.push(i);
        return result;
    }
    Keys.onSpacePressed: popup.open()
    Keys.onReturnPressed: popup.open()
    Keys.onDownPressed: popup.open()
    background: Rectangle {
        radius: 4
        color: root.enabled ? "white" : Colors.disabled
        border.width: root.activeFocus ? 2 : 1
        border.color: root.validationState === "error" ? Colors.danger : root.activeFocus ? Colors.accent : root.hovered ? Colors.borderStrong : Colors.border
    }
    contentItem: Label {
        text: root.currentText || root.placeholderText
        leftPadding: 10
        rightPadding: 32
        color: !root.enabled ? Colors.disabledText : root.currentIndex < 0 ? Colors.textSecondary : Colors.text
        font.pixelSize: 12
    }
    Icon {
        name: popup.opened ? "up" : "down"
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.forceActiveFocus();
            popup.open();
        }
    }
    C.Popup {
        id: popup
        y: root.height + 4
        width: root.width
        padding: 4
        margins: 8
        focus: true
        closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutsideParent
        onOpened: {
            search.text = "";
            list.currentIndex = -1;
            root.move(1);
            if (root.searchable)
                search.forceActiveFocus();
            else
                list.forceActiveFocus();
        }
        background: Rectangle {
            color: "white"
            radius: 6
            border.color: Colors.borderStrong
        }
        contentItem: ColumnLayout {
            spacing: 4
            Keys.onDownPressed: root.move(1)
            Keys.onUpPressed: root.move(-1)
            Keys.onReturnPressed: {
                if (list.currentIndex >= 0)
                    root.choose(root.filtered[list.currentIndex]);
            }
            AzenzTextField {
                id: search
                inputType: "search"
                visible: root.searchable
                Layout.fillWidth: true
                placeholderText: qsTr("Rechercher…")
                onTextChanged: {
                    list.currentIndex = -1;
                    root.move(1);
                }
            }
            ListView {
                id: list
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(224, contentHeight)
                clip: true
                model: root.filtered
                boundsBehavior: Flickable.StopAtBounds
                C.ScrollBar.vertical: AzenzScrollBar {}
                delegate: C.ItemDelegate {
                    id: option
                    required property int modelData
                    required property int index
                    width: list.width
                    height: 28
                    enabled: root.allowed(modelData)
                    highlighted: list.currentIndex === index
                    contentItem: Label {
                        text: root.labelFor(root.model[modelData])
                        font.pixelSize: 12
                        color: enabled ? Colors.text : Colors.disabledText
                        rightPadding: 20
                    }
                    background: Rectangle {
                        color: option.highlighted || option.hovered ? Colors.rowHover : "white"
                        radius: 3
                    }
                    Icon {
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        name: "check"
                        color: Colors.accent
                        visible: root.currentIndex === modelData
                        width: 14
                        height: 14
                    }
                    onClicked: root.choose(modelData)
                }
            }
            Label {
                text: root.filtered.length + qsTr(" résultat(s)")
                font.pixelSize: 11
                color: Colors.textSecondary
                Layout.leftMargin: 6
                Layout.preferredHeight: 24
            }
        }
    }
}
