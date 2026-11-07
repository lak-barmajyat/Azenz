pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import "../controls"
import "../theme"

AzenzTextField {
    id: root
    property string value: ""
    property string searchKey: ""
    property string primaryKey: "description"
    property string secondaryKey: "reference"
    property var suggestions: []
    property bool searchBusy: false
    property int minimumSearchLength: 1
    property bool inlineMode: false
    signal searchRequested(string key, string query)
    signal valueEdited(string value)
    signal suggestionSelected(var suggestion)
    signal submitRequested

    inputType: "search"
    leadingIcon: inlineMode ? "" : "search"
    clearable: !inlineMode
    leftPadding: inlineMode ? 2 : 34
    rightPadding: inlineMode ? 2 : 10
    placeholderTextColor: Colors.textSecondary
    font.italic: inlineMode && text === ""
    background: Rectangle {
        color: root.inlineMode ? "transparent" : Colors.surface
        radius: 3
        border.width: root.inlineMode && !root.activeFocus ? 0 : 1
        border.color: root.activeFocus ? Colors.accent : Colors.border
    }
    onValueChanged: if (text !== value)
        text = value
    onTextEdited: {
        root.valueEdited(text);
        searchTimer.restart();
        if (text.length < root.minimumSearchLength)
            results.close();
    }
    onActiveFocusChanged: {
        if (activeFocus && text.length >= minimumSearchLength)
            searchTimer.restart();
        else
            results.close();
    }
    onSuggestionsChanged: {
        if (activeFocus && text.length >= minimumSearchLength && suggestions.length > 0) {
            resultList.currentIndex = 0;
            results.open();
        } else if (!suggestions.length && !searchBusy)
            results.close();
    }
    onSearchBusyChanged: {
        if (searchBusy && activeFocus && text.length >= minimumSearchLength)
            results.open();
        else if (!searchBusy && !suggestions.length)
            results.close();
    }
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Down && root.suggestions.length > 0) {
            results.open();
            resultList.currentIndex = Math.min(resultList.currentIndex + 1, root.suggestions.length - 1);
        } else if (event.key === Qt.Key_Up && results.visible) {
            resultList.currentIndex = Math.max(0, resultList.currentIndex - 1);
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (results.visible && resultList.currentIndex >= 0)
                root.choose(root.suggestions[resultList.currentIndex]);
            else
                root.submitRequested();
        } else if (event.key === Qt.Key_Escape && results.visible)
            results.close();
        else
            return;
        event.accepted = true;
    }

    function choose(suggestion) {
        searchTimer.stop();
        results.close();
        suggestionSelected(suggestion);
    }

    Timer {
        id: searchTimer
        interval: 180
        onTriggered: if (root.activeFocus && root.text.length >= root.minimumSearchLength)
            root.searchRequested(root.searchKey, root.text)
    }
    C.Popup {
        id: results
        x: 0
        y: root.height
        width: Math.max(root.width, 280)
        height: root.searchBusy ? 40 : Math.min(240, resultList.contentHeight + 8)
        padding: 4
        modal: false
        focus: false
        closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutside
        background: Rectangle {
            radius: 6
            color: Colors.surface
            border.color: Colors.borderStrong
        }
        contentItem: Item {
            ListView {
                id: resultList
                anchors.fill: parent
                model: root.suggestions
                currentIndex: -1
                visible: !root.searchBusy
                clip: true
                delegate: C.ItemDelegate {
                    id: resultItem
                    required property var modelData
                    required property int index
                    width: resultList.width
                    height: 42
                    highlighted: resultList.currentIndex === index
                    onClicked: root.choose(modelData)
                    contentItem: Column {
                        spacing: 2
                        Label {
                            text: String(resultItem.modelData[root.primaryKey] ?? "")
                            color: Colors.text
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Label {
                            text: String(resultItem.modelData[root.secondaryKey] ?? "")
                            color: Colors.textSecondary
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }
            }
            C.BusyIndicator {
                anchors.centerIn: parent
                width: 24
                height: 24
                visible: root.searchBusy
                running: visible
            }
        }
    }
}
