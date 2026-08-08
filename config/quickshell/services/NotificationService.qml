import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

Scope {
    id: root

    property alias history: historyModel
    readonly property int historyCount: historyModel.count

    property bool toastVisible: false
    property var toastScreen: null
    property string toastAppName: ""
    property string toastSummary: ""
    property string toastBody: ""
    property string toastIcon: ""
    property var activeNotification: null

    function safeString(value) {
        return value === undefined || value === null ? "" : String(value);
    }

    function preferredScreen() {
        const active = ToplevelManager.activeToplevel;
        if (active && active.screens && active.screens.length > 0)
            return active.screens[0];

        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function closeToast(expire) {
        toastVisible = false;
        toastTimer.stop();

        if (!activeNotification)
            return;

        const notification = activeNotification;
        activeNotification = null;

        if (expire)
            notification.expire();
        else
            notification.dismiss();
    }

    function clearHistory() {
        historyModel.clear();
    }

    ListModel {
        id: historyModel
    }

    Timer {
        id: toastTimer
        interval: 6000
        repeat: false
        onTriggered: root.closeToast(true)
    }

    NotificationServer {
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: true
        persistenceSupported: false
        keepOnReload: false

        onNotification: notification => {
            if (root.activeNotification)
                root.closeToast(true);

            notification.tracked = true;
            root.activeNotification = notification;
            root.toastScreen = root.preferredScreen();
            root.toastAppName = root.safeString(notification.appName);
            root.toastSummary = root.safeString(notification.summary);
            root.toastBody = root.safeString(notification.body);
            root.toastIcon = root.safeString(notification.appIcon || notification.image);
            root.toastVisible = root.toastScreen !== null;

            historyModel.insert(0, {
                "appName": root.toastAppName,
                "summary": root.toastSummary,
                "body": root.toastBody,
                "icon": root.toastIcon,
                "time": Qt.formatDateTime(new Date(), "HH:mm")
            });

            while (historyModel.count > 50)
                historyModel.remove(historyModel.count - 1);

            toastTimer.restart();
        }
    }
}
