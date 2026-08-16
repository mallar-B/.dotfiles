import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Item {
    id: root

    required property var theme
    required property QtObject idleService
    required property QtObject targetWindow

    implicitWidth: theme.buttonWidth
    implicitHeight: theme.buttonHeight

    IdleInhibitor {
        window: root.targetWindow
        enabled: root.idleService.blocked
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius

        color: root.idleService.inhibited || popup.visible ? root.theme.bgGreen : mouse.containsMouse ? root.theme.bg2 : "transparent"

        border.width: root.idleService.blocked || popup.visible ? 1 : 0

        border.color: root.idleService.mediaPlaying && !root.idleService.inhibited ? root.theme.aqua : root.theme.green

        IconImage {
            id: icon

            anchors.centerIn: parent
            implicitSize: root.theme.iconSize

            source: Quickshell.iconPath(root.idleService.mediaPlaying ? "media-playback-start-symbolic" : root.idleService.inhibited ? "media-playback-pause-symbolic" : "preferences-system-time-symbolic", true)
        }

        Text {
            visible: root.idleService.inhibited

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 3

            text: root.idleService.inhibitMode === "indefinite" ? "∞" : root.idleService.inhibitMode === "3h" ? "3" : "1"

            color: root.theme.green
            font.pixelSize: root.theme.smallTextSize
        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true

            onClicked: popup.visible = !popup.visible
        }
    }

    HoverTooltip {
        theme: root.theme
        anchorItem: root

        visible: mouse.containsMouse && !popup.visible

        text: root.idleService.statusText
    }

    PopupWindow {
        id: popup

        anchor.item: root
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right
        anchor.margins.left: 10

        grabFocus: true
        color: "transparent"

        implicitWidth: 300
        implicitHeight: content.implicitHeight + 20

        Rectangle {
            anchors.fill: parent

            radius: root.theme.radius + 2
            color: root.theme.bg0

            border.width: 1
            border.color: root.theme.bg3

            Column {
                id: content

                anchors.fill: parent
                anchors.margins: 10

                spacing: 8

                Text {
                    text: "Idle manager"
                    color: root.theme.fg

                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textSize
                    font.bold: true
                }

                Text {
                    text: root.idleService.statusText
                    color: root.theme.grey1

                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.smallTextSize
                }

                Rectangle {
                    width: content.width
                    height: 1
                    color: root.theme.bg3
                }

                Repeater {
                    model: [
                        {
                            title: "Lock after",
                            type: "lock",
                            options: [["1m", 60], ["3m", 180], ["5m", 300], ["10m", 600], ["15m", 900], ["Never", 0]]
                        },
                        {
                            title: "Suspend after",
                            type: "suspend",
                            options: [["5m", 300], ["10m", 600], ["15m", 900], ["30m", 1800], ["1h", 3600], ["Never", 0]]
                        }
                    ]

                    delegate: Column {
                        id: section

                        required property var modelData

                        width: content.width
                        spacing: 4

                        readonly property int current: modelData.type === "lock" ? root.idleService.lockTimeoutSeconds : root.idleService.suspendTimeoutSeconds

                        Text {
                            text: section.modelData.title
                            color: root.theme.grey1

                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.smallTextSize
                        }

                        Flow {
                            width: section.width
                            spacing: 4

                            Repeater {
                                model: section.modelData.options

                                delegate: Rectangle {
                                    id: choice

                                    required property var modelData

                                    readonly property bool selected: section.current === modelData[1]

                                    width: Math.max(40, label.implicitWidth + 14)

                                    height: 28
                                    radius: root.theme.radius

                                    color: selected ? root.theme.bgGreen : choiceMouse.containsMouse ? root.theme.bg2 : "transparent"

                                    border.width: selected ? 1 : 0
                                    border.color: root.theme.green

                                    Text {
                                        id: label

                                        anchors.centerIn: parent
                                        text: choice.modelData[0]

                                        color: choice.selected ? root.theme.green : root.theme.fg

                                        font.family: root.theme.fontFamily

                                        font.pixelSize: root.theme.smallTextSize
                                    }

                                    MouseArea {
                                        id: choiceMouse

                                        anchors.fill: parent
                                        hoverEnabled: true

                                        onClicked: {
                                            if (section.modelData.type === "lock") {
                                                root.idleService.setLockTimeout(choice.modelData[1]);
                                            } else {
                                                root.idleService.setSuspendTimeout(choice.modelData[1]);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    text: root.idleService.mediaPlaying ? "Media playing • idle inhibited" : "Media playback idle"

                    color: root.idleService.mediaPlaying ? root.theme.aqua : root.theme.grey1

                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.smallTextSize
                }

                Rectangle {
                    width: content.width
                    height: 1
                    color: root.theme.bg3
                }

                Text {
                    text: "Manual inhibition"
                    color: root.theme.grey1

                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.smallTextSize
                }

                Row {
                    spacing: 4

                    Repeater {
                        model: [["1 hour", "1h"], ["3 hours", "3h"], ["Indefinite", "indefinite"]]

                        delegate: Rectangle {
                            id: inhibitChoice

                            required property var modelData

                            readonly property bool selected: root.idleService.inhibitMode === modelData[1]

                            width: inhibitLabel.implicitWidth + 16
                            height: 30

                            radius: root.theme.radius

                            color: selected ? root.theme.bgGreen : inhibitMouse.containsMouse ? root.theme.bg2 : "transparent"

                            border.width: selected ? 1 : 0
                            border.color: root.theme.green

                            Text {
                                id: inhibitLabel

                                anchors.centerIn: parent
                                text: inhibitChoice.modelData[0]

                                color: inhibitChoice.selected ? root.theme.green : root.theme.fg

                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize
                            }

                            MouseArea {
                                id: inhibitMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    const mode = inhibitChoice.modelData[1];

                                    if (mode === "1h")
                                        root.idleService.inhibitOneHour();
                                    else if (mode === "3h")
                                        root.idleService.inhibitThreeHours();
                                    else
                                        root.idleService.inhibitIndefinitely();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.idleService.inhibited

                    width: content.width
                    height: visible ? 30 : 0
                    radius: root.theme.radius

                    color: stopMouse.containsMouse ? root.theme.bgRed : "transparent"

                    Text {
                        anchors.centerIn: parent

                        text: "Stop inhibiting"
                        color: root.theme.red

                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.smallTextSize
                    }

                    MouseArea {
                        id: stopMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: root.idleService.stopInhibiting()
                    }
                }
            }
        }
    }
}
