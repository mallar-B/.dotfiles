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
    property var localNoticeKeys: ({})

    function safeString(value) {
        return value === undefined || value === null ? "" : String(value);
    }

    function addHistory(appName, summary, body, icon) {
        historyModel.insert(0, {
            "appName": root.safeString(appName),
            "summary": root.safeString(summary),
            "body": root.safeString(body),
            "icon": root.safeString(icon),
            "time": Qt.formatDateTime(new Date(), "HH:mm")
        });

        while (historyModel.count > 50)
            historyModel.remove(historyModel.count - 1);
    }

    function showLocal(summary, body, icon) {
        if (root.activeNotification)
            root.closeToast(true);
        else {
            root.toastVisible = false;
            toastTimer.stop();
        }

        root.activeNotification = null;
        root.toastScreen = root.preferredScreen();
        root.toastAppName = "QuickShell";
        root.toastSummary = root.safeString(summary);
        root.toastBody = root.safeString(body);
        root.toastIcon = root.safeString(icon);
        root.toastVisible = root.toastScreen !== null;

        root.addHistory(root.toastAppName, root.toastSummary, root.toastBody, root.toastIcon);

        if (root.toastVisible)
            toastTimer.restart();
    }

    function showLocalOnce(key, summary, body, icon) {
        const noticeKey = root.safeString(key);
        if (noticeKey.length > 0 && root.localNoticeKeys[noticeKey])
            return;

        if (noticeKey.length > 0)
            root.localNoticeKeys[noticeKey] = true;

        root.showLocal(summary, body, icon);
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

            root.addHistory(root.toastAppName, root.toastSummary, root.toastBody, root.toastIcon);

            toastTimer.restart();
        }
    }
}
