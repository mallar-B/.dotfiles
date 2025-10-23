import Quickshell
import Quickshell.Services.Notifications
import QtQuick


PanelWindow {
    anchors {
        top: true
        right: true
    }

    implicitHeight: 100
    implicitWidth: 400
    color: "transparent"

    property var notificationsArray: []

    NotificationServer {
        actionsSupported: true
        onNotification: notification => {
            console.log("Notification received:");
            console.log("  App:", notification.appName);
            notificationText.text = notification.summary;
            console.log("  Body:", notification.body);
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 20
        height: parent.height - 10
        color: "red"
        radius: 10
        border.width: 1
        opacity: 0.5

        Text {
            id: notificationText
            anchors.centerIn: parent
            text: ""
            color: "blue"
            font.pixelSize: 14
        }
    }
}
