import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var theme
    required property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Right | Edges.Bottom
    anchor.gravity: Edges.Right | Edges.Top
    anchor.margins.left: 10
    grabFocus: true
    color: "transparent"
    implicitWidth: 190
    implicitHeight: actionColumn.implicitHeight + 20

    function run(command) {
        visible = false;
        Quickshell.execDetached(command);
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius + 2
        color: root.theme.bg0
        border.width: 1
        border.color: root.theme.bg3

        Column {
            id: actionColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Repeater {
                model: [
                    { "label": "Suspend", "command": ["systemctl", "suspend"], "danger": false },
                    { "label": "Log out", "command": ["niri", "msg", "action", "quit", "--skip-confirmation"], "danger": false },
                    { "label": "Reboot", "command": ["systemctl", "reboot"], "danger": true },
                    { "label": "Power off", "command": ["systemctl", "poweroff"], "danger": true }
                ]

                delegate: Rectangle {
                    required property var modelData
                    width: actionColumn.width
                    height: 38
                    radius: root.theme.radius
                    color: actionMouse.containsMouse ? root.theme.bg2 : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: modelData.danger ? root.theme.red : root.theme.fg
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.run(modelData.command)
                    }
                }
            }
        }
    }
}
