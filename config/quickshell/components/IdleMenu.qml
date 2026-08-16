import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var theme
    required property Item anchorItem
    required property QtObject idleService

    property var lockOptions: [
        {
            "label": "1m",
            "seconds": 60
        },
        {
            "label": "3m",
            "seconds": 3 * 60
        },
        {
            "label": "5m",
            "seconds": 5 * 60
        },
        {
            "label": "10m",
            "seconds": 10 * 60
        },
        {
            "label": "15m",
            "seconds": 15 * 60
        },
        {
            "label": "Never",
            "seconds": 0
        }
    ]

    property var suspendOptions: [
        {
            "label": "5m",
            "seconds": 5 * 60
        },
        {
            "label": "10m",
            "seconds": 10 * 60
        },
        {
            "label": "15m",
            "seconds": 15 * 60
        },
        {
            "label": "30m",
            "seconds": 30 * 60
        },
        {
            "label": "1h",
            "seconds": 60 * 60
        },
        {
            "label": "Never",
            "seconds": 0
        }
    ]

    anchor.item: anchorItem

    anchor.edges: Edges.Right

    anchor.gravity: Edges.Right

    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide

    anchor.margins.left: 10

    grabFocus: true
    color: "transparent"

    implicitWidth: 320

    implicitHeight: menuColumn.implicitHeight + 20

    Rectangle {
        anchors.fill: parent

        radius: root.theme.radius + 2

        color: root.theme.bg0

        border.width: 1

        border.color: root.theme.bg3

        Column {
            id: menuColumn

            anchors.fill: parent
            anchors.margins: 10

            spacing: 8

            // ====================================================
            // HEADER
            // ====================================================

            Item {
                width: menuColumn.width

                height: 44

                Column {
                    anchors.left: parent.left

                    anchors.right: parent.right

                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 1

                    Text {
                        text: "Idle manager"

                        color: root.theme.fg

                        font.family: root.theme.fontFamily

                        font.pixelSize: root.theme.textSize

                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width

                        text: root.idleService.statusText

                        color: root.theme.grey1

                        elide: Text.ElideRight

                        font.family: root.theme.fontFamily

                        font.pixelSize: root.theme.smallTextSize
                    }
                }
            }

            Rectangle {
                width: menuColumn.width

                height: 1

                color: root.theme.bg3
            }

            // ====================================================
            // LOCK TIMEOUT
            // ====================================================

            Text {
                text: "Lock after"

                color: root.theme.grey1

                font.family: root.theme.fontFamily

                font.pixelSize: root.theme.smallTextSize
            }

            Flow {
                width: menuColumn.width

                height: childrenRect.height

                spacing: 5

                Repeater {
                    model: root.lockOptions

                    delegate: Rectangle {
                        id: lockOption

                        required property var modelData

                        readonly property bool selected: root.idleService.lockTimeoutSeconds === modelData.seconds

                        width: Math.max(42, lockOptionText.implicitWidth + 16)

                        height: 30

                        radius: root.theme.radius

                        color: selected ? root.theme.bgGreen : lockOptionMouse.containsMouse ? root.theme.bg2 : "transparent"

                        border.width: selected ? 1 : 0

                        border.color: root.theme.green

                        Text {
                            id: lockOptionText

                            anchors.centerIn: parent

                            text: lockOption.modelData.label

                            color: lockOption.selected ? root.theme.green : root.theme.fg

                            font.family: root.theme.fontFamily

                            font.pixelSize: root.theme.smallTextSize
                        }

                        MouseArea {
                            id: lockOptionMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: root.idleService.setLockTimeout(lockOption.modelData.seconds)
                        }
                    }
                }
            }

            // ====================================================
            // SUSPEND TIMEOUT
            // ====================================================

            Text {
                text: "Suspend after"

                color: root.theme.grey1

                font.family: root.theme.fontFamily

                font.pixelSize: root.theme.smallTextSize
            }

            Flow {
                width: menuColumn.width

                height: childrenRect.height

                spacing: 5

                Repeater {
                    model: root.suspendOptions

                    delegate: Rectangle {
                        id: suspendOption

                        required property var modelData

                        readonly property bool selected: root.idleService.suspendTimeoutSeconds === modelData.seconds

                        width: Math.max(42, suspendOptionText.implicitWidth + 16)

                        height: 30

                        radius: root.theme.radius

                        color: selected ? root.theme.bgGreen : suspendOptionMouse.containsMouse ? root.theme.bg2 : "transparent"

                        border.width: selected ? 1 : 0

                        border.color: root.theme.green

                        Text {
                            id: suspendOptionText

                            anchors.centerIn: parent

                            text: suspendOption.modelData.label

                            color: suspendOption.selected ? root.theme.green : root.theme.fg

                            font.family: root.theme.fontFamily

                            font.pixelSize: root.theme.smallTextSize
                        }

                        MouseArea {
                            id: suspendOptionMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: root.idleService.setSuspendTimeout(suspendOption.modelData.seconds)
                        }
                    }
                }
            }

            // ====================================================
            // MEDIA STATE
            // ====================================================

            Text {
                text: root.idleService.mediaPlaying ? "Media playback: inhibiting idle" : "Media playback: no active player"

                color: root.idleService.mediaPlaying ? root.theme.aqua : root.theme.grey1

                font.family: root.theme.fontFamily

                font.pixelSize: root.theme.smallTextSize
            }

            Rectangle {
                width: menuColumn.width

                height: 1

                color: root.theme.bg3
            }

            // ====================================================
            // MANUAL INHIBITION
            // ====================================================

            Text {
                text: "Manual inhibition"

                color: root.theme.grey1

                font.family: root.theme.fontFamily

                font.pixelSize: root.theme.smallTextSize
            }

            Row {
                spacing: 5

                Repeater {
                    model: [
                        {
                            "label": "1 hour",
                            "mode": "1h"
                        },
                        {
                            "label": "3 hours",
                            "mode": "3h"
                        },
                        {
                            "label": "Indefinite",
                            "mode": "indefinite"
                        }
                    ]

                    delegate: Rectangle {
                        id: inhibitOption

                        required property var modelData

                        readonly property bool selected: root.idleService.inhibited && root.idleService.inhibitMode === modelData.mode

                        width: Math.max(74, inhibitOptionText.implicitWidth + 18)

                        height: 32

                        radius: root.theme.radius

                        color: selected ? root.theme.bgGreen : inhibitOptionMouse.containsMouse ? root.theme.bg2 : "transparent"

                        border.width: selected ? 1 : 0

                        border.color: root.theme.green

                        Text {
                            id: inhibitOptionText

                            anchors.centerIn: parent

                            text: inhibitOption.modelData.label

                            color: inhibitOption.selected ? root.theme.green : root.theme.fg

                            font.family: root.theme.fontFamily

                            font.pixelSize: root.theme.smallTextSize
                        }

                        MouseArea {
                            id: inhibitOptionMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                if (inhibitOption.modelData.mode === "1h") {
                                    root.idleService.inhibitOneHour();
                                } else if (inhibitOption.modelData.mode === "3h") {
                                    root.idleService.inhibitThreeHours();
                                } else {
                                    root.idleService.inhibitIndefinitely();
                                }
                            }
                        }
                    }
                }
            }

            // ====================================================
            // STOP MANUAL INHIBITION
            // ====================================================

            Rectangle {
                visible: root.idleService.inhibited

                width: menuColumn.width

                height: visible ? 34 : 0

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
