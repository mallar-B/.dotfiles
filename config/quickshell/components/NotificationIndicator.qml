import QtQuick

Item {
    id: root

    required property var theme
    required property var notifications

    implicitWidth: theme.buttonWidth
    implicitHeight: theme.buttonHeight

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: notificationMouse.containsMouse || historyPopup.visible ? root.theme.bg2 : "transparent"
        border.width: historyPopup.visible ? 1 : 0
        border.color: root.theme.yellow

        Text {
            anchors.centerIn: parent
            text: "🔔"
            color: root.theme.yellow
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.iconSize + 2
        }

        Rectangle {
            visible: root.notifications.historyCount > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.rightMargin: 1
            implicitWidth: Math.max(18, badgeText.implicitWidth + 8)
            implicitHeight: 18
            radius: 9
            color: root.theme.red
            border.width: 1
            border.color: root.theme.bg0

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: String(Math.min(99, root.notifications.historyCount))
                color: root.theme.bg0
                font.family: root.theme.fontFamily
                font.pixelSize: 10
                font.bold: true
            }
        }

        MouseArea {
            id: notificationMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: historyPopup.visible = !historyPopup.visible
        }
    }

    NotificationHistory {
        id: historyPopup
        theme: root.theme
        notifications: root.notifications
        anchorItem: root
    }
}
