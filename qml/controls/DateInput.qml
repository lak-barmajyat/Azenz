import QtQuick

AzenzTextField {
    id: root
    property date value: new Date()
    property bool hasValue: false
    property alias minimumDate: picker.minimumDate
    property alias maximumDate: picker.maximumDate
    readonly property alias calendarPopup: picker
    signal dateEdited(date value)
    signal dateCleared()
    leadingIcon: ""
    trailingIcon: readOnly ? "lock" : "calendar"
    trailingToolTip: readOnly ? qsTr("Lecture seule") : qsTr("Ouvrir le calendrier")
    placeholderText: "JJ/MM/AAAA"
    validator: RegularExpressionValidator {
        regularExpression: /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/
    }
    text: hasValue ? Qt.formatDate(value, "dd/MM/yyyy") : ""
    onValueChanged: text = hasValue ? Qt.formatDate(value, "dd/MM/yyyy") : ""
    onHasValueChanged: text = hasValue ? Qt.formatDate(value, "dd/MM/yyyy") : ""
    function commit() {
        if (text === "") {
            var wasSet = hasValue;
            hasValue = false;
            validationState = "default";
            if (wasSet)
                dateCleared();
            return;
        }
        var p = text.split("/");
        if (p.length !== 3) {
            validationState = "error";
            return;
        }
        var day = Number(p[0]);
        var month = Number(p[1]);
        var year = Number(p[2]);
        var date = new Date(year, month - 1, day);
        if (date.getDate() !== day || date.getMonth() !== month - 1 || date.getFullYear() !== year || !picker.allowed(date)) {
            validationState = "error";
            return;
        }
        value = date;
        hasValue = true;
        validationState = "default";
        dateEdited(date);
    }
    onEditingFinished: commit()
    onActiveFocusChanged: if (!activeFocus && !readOnly)
        commit()
    function openCalendar() {
        if (readOnly || !enabled)
            return;
        commit();
        // Choosing a day changes the popup's selectedDate, so resync on every open.
        picker.selectedDate = hasValue ? value : new Date();
        picker.open();
    }
    onTrailingClicked: openCalendar()
    Keys.onDownPressed: openCalendar()
    DatePicker {
        id: picker
        y: root.height + 4
        selectedDate: root.value
        onDateSelected: function (date) {
            root.value = date;
            root.hasValue = true;
            root.text = Qt.formatDate(date, "dd/MM/yyyy");
            root.validationState = "default";
            root.dateEdited(date);
            root.forceActiveFocus();
        }
    }
}
