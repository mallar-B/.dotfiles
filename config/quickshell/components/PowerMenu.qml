pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root

    required property var theme
    required property Item anchorItem
    required property var lockController

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
                    { "label": "Lock", "icon": "system-lock-screen-symbolic", "kind": "lock", "danger": false },
                    { "label": "Suspend", "icon": "system-suspend-symbolic", "command": ["systemctl", "suspend"], "danger": false },
                    { "label": "Log out", "icon": "system-log-out-symbolic", "command": ["niri", "msg", "action", "quit", "--skip-confirmation"], "danger": false },
                    { "label": "Reboot", "icon": "system-reboot-symbolic", "command": ["systemctl", "reboot"], "danger": true },
                    { "label": "Power off", "icon": "system-shutdown-symbolic", "command": ["systemctl", "poweroff"], "danger": true }
                ]

                delegate: Rectangle {
                    id: actionItem
                    required property var modelData
                    width: actionColumn.width
                    height: 38
                    radius: root.theme.radius
                    color: actionMouse.containsMouse ? root.theme.bg2 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        IconImage {
                            id: actionIcon
                            Layout.alignment: Qt.AlignVCenter
                            implicitSize: 16
                            source: Quickshell.iconPath(actionItem.modelData.icon, true)
                            visible: source.toString().length > 0
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: actionItem.modelData.label
                            color: actionItem.modelData.danger ? root.theme.red : root.theme.fg
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textSize
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (actionItem.modelData.kind === "lock") {
                                root.visible = false;
                                root.lockController.lock();
                            } else {
                                root.run(actionItem.modelData.command);
                            }
                        }
                    }
                }
            }
        }
    }
}
