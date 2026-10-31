pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import "../theme"

C.Popup {
    id: root
    property date selectedDate: new Date()
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property date focusedDate: selectedDate
    property int month: focusedDate.getMonth()
    property int year: focusedDate.getFullYear()
    signal dateSelected(date value)
    width: 292
    padding: 12
    margins: 8
    focus: true
    closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutsideParent
    background: Rectangle {
        color: "white"
        radius: 6
        border.color: Colors.borderStrong
    }
    function key(value) {
        return new Date(value.getFullYear(), value.getMonth(), value.getDate()).getTime();
    }
    function allowed(value) {
        return key(value) >= key(minimumDate) && key(value) <= key(maximumDate);
    }
    function choose(value) {
        if (!allowed(value))
            return;
        selectedDate = value;
        dateSelected(value);
        close();
    }
    function shiftMonth(delta) {
        var next = new Date(year, month + delta, 1);
        month = next.getMonth();
        year = next.getFullYear();
        focusedDate = next;
    }
    function moveDay(delta) {
        var next = new Date(focusedDate.getFullYear(), focusedDate.getMonth(), focusedDate.getDate() + delta);
        if (allowed(next)) {
            focusedDate = next;
            month = next.getMonth();
            year = next.getFullYear();
        }
    }
    onOpened: {
        focusedDate = selectedDate;
        month = selectedDate.getMonth();
        year = selectedDate.getFullYear();
        calendar.forceActiveFocus();
    }
    contentItem: ColumnLayout {
        id: calendar
        spacing: 8
        Keys.onLeftPressed: root.moveDay(-1)
        Keys.onRightPressed: root.moveDay(1)
        Keys.onUpPressed: root.moveDay(-7)
        Keys.onDownPressed: root.moveDay(7)
        Keys.onReturnPressed: root.choose(root.focusedDate)
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_PageUp) {
                root.shiftMonth(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_PageDown) {
                root.shiftMonth(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_F3) {
                root.choose(new Date());
                event.accepted = true;
            }
        }
        RowLayout {
            Layout.fillWidth: true
            IconButton {
                iconName: "left"
                tooltip: qsTr("Mois précédent")
                onClicked: root.shiftMonth(-1)
            }
            Label {
                text: new Date(root.year, root.month, 1).toLocaleDateString(Qt.locale("fr_FR"), "MMMM yyyy")
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            IconButton {
                iconName: "right"
                tooltip: qsTr("Mois suivant")
                onClicked: root.shiftMonth(1)
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di"]
                Label {
                    required property string modelData
                    text: modelData
                    font.pixelSize: 11
                    color: Colors.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }
        GridLayout {
            columns: 7
            rowSpacing: 2
            columnSpacing: 2
            Layout.fillWidth: true
            Repeater {
                model: 42
                AzenzButton {
                    required property int index
                    property date day: new Date(root.year, root.month, index + 1 - (new Date(root.year, root.month, 1).getDay() + 6) % 7)
                    property bool selected: root.key(day) === root.key(root.selectedDate)
                    property bool today: root.key(day) === root.key(new Date())
                    text: day.getDate().toString()
                    variant: selected ? "primary" : "ghost"
                    size: "compact"
                    leftPadding: 0
                    rightPadding: 0
                    implicitWidth: 32
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    enabled: root.allowed(day)
                    opacity: day.getMonth() === root.month ? 1 : 0.45
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: "transparent"
                        border.width: 1
                        border.color: Colors.accent
                        visible: parent.today && !parent.selected
                    }
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: 4
                        color: "transparent"
                        border.width: 2
                        border.color: Colors.navy
                        visible: root.key(parent.day) === root.key(root.focusedDate)
                    }
                    onClicked: root.choose(day)
                }
            }
        }
        RowLayout {
            spacing: 2
            AzenzButton {
                text: qsTr("Hier")
                variant: "ghost"
                size: "compact"
                leftPadding: 6
                rightPadding: 6
                onClicked: {
                    var day = new Date();
                    day.setDate(day.getDate() - 1);
                    root.choose(day);
                }
            }
            AzenzButton {
                text: qsTr("Aujourd'hui")
                variant: "ghost"
                size: "compact"
                leftPadding: 6
                rightPadding: 6
                onClicked: root.choose(new Date())
            }
            AzenzButton {
                text: qsTr("Fin de mois")
                variant: "ghost"
                size: "compact"
                leftPadding: 6
                rightPadding: 6
                onClicked: root.choose(new Date(root.year, root.month + 1, 0))
            }
        }
    }
}
