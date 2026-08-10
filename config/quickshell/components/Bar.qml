import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.WindowManager

PanelWindow {
    id: bar

    required property var theme
    required property var launcherController
    required property var notifications
    required property var niriWorkspaces
    required property var lockController

    readonly property var projection: WindowManager.screenProjection(screen)
    implicitWidth: theme.barWidth
    color: theme.bg0
    exclusiveZone: theme.barWidth

    anchors {
        left: true
        top: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "everforest-bar"

    Rectangle {
        anchors.fill: parent
        color: theme.bg0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 4

            IconButton {
                theme: bar.theme
                label: "⌕"
                labelSize: bar.theme.iconSize + 3
                onClicked: bar.launcherController.toggle(bar.screen)
            }

            WorkspaceStrip {
                Layout.alignment: Qt.AlignHCenter
                theme: bar.theme
                projection: bar.projection
                niriWorkspaces: bar.niriWorkspaces
                workspaceCount: 10
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Text {
                    anchors.centerIn: parent
                    width: Math.max(48, parent.height - 18)
                    rotation: -90
                    text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : "niri"
                    color: bar.theme.grey1
                    elide: Text.ElideMiddle
                    horizontalAlignment: Text.AlignHCenter
                    font.family: bar.theme.fontFamily
                    font.pixelSize: bar.theme.textSize - 1
                }
            }

            SysTray {
                Layout.alignment: Qt.AlignHCenter
                theme: bar.theme
            }

            NotificationIndicator {
                Layout.alignment: Qt.AlignHCenter
                theme: bar.theme
                notifications: bar.notifications
            }

            VolumeControl {
                Layout.alignment: Qt.AlignHCenter
                theme: bar.theme
            }

            BatteryControl {
                Layout.alignment: Qt.AlignHCenter
                theme: bar.theme
                notifications: bar.notifications
            }

            ClockDisplay {
                Layout.alignment: Qt.AlignHCenter
                theme: bar.theme
            }

            IconButton {
                id: powerButton
                theme: bar.theme
                label: "⏻"
                labelSize: bar.theme.iconSize + 1
                danger: true
                active: powerPopup.visible
                onClicked: powerPopup.visible = !powerPopup.visible
            }
        }
    }

    PowerMenu {
        id: powerPopup
        theme: bar.theme
        anchorItem: powerButton
        lockController: bar.lockController
    }
}
