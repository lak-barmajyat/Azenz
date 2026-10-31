pragma ComponentBehavior: Bound
import QtQuick

Column {
    id: root
    property int maximumVisible: 4
    property int duration: 5000
    property var notifications: []
    property int nextId: 0
    signal actionTriggered(int notificationId)
    width: 380
    spacing: 8
    z: 40
    move: Transition {
        NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
    }
    ListModel { id: visibleNotifications }
    function fillVisible() {
        var count = Math.min(maximumVisible, notifications.length);
        while (visibleNotifications.count < count)
            visibleNotifications.append(notifications[visibleNotifications.count]);
    }
    function show(title, message, variant, actionText) {
        var id = nextId++;
        notifications = notifications.concat([
            {
                id: id,
                notificationId: id,
                title: title,
                message: message || "",
                variant: variant || "success",
                actionText: actionText || ""
            }
        ]);
        fillVisible();
        return id;
    }
    function dismiss(id) {
        for (var i = 0; i < visibleNotifications.count; ++i) {
            if (visibleNotifications.get(i).notificationId === id) {
                repeater.itemAt(i).dismiss();
                return;
            }
        }
        removeNotification(id);
    }
    function removeNotification(id) {
        for (var i = 0; i < visibleNotifications.count; ++i) {
            if (visibleNotifications.get(i).notificationId === id) {
                visibleNotifications.remove(i);
                break;
            }
        }
        notifications = notifications.filter(function (item) {
            return item.id !== id;
        });
        fillVisible();
    }
    Repeater {
        id: repeater
        model: visibleNotifications
        Toast {
            required property var model
            width: root.width
            title: model.title
            message: model.message
            variant: model.variant
            actionText: model.actionText
            duration: root.duration
            onDismissed: root.removeNotification(model.notificationId)
            onActionTriggered: root.actionTriggered(model.notificationId)
        }
    }
}
