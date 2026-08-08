import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ListView {
    id: tray

    required property var theme

    Layout.preferredWidth: theme.buttonWidth
    Layout.preferredHeight: Math.min(108, count * 32)

    visible: count > 0
    clip: true
    spacing: 2
    model: SystemTray.items

    delegate: Rectangle {
        id: trayButton

        required property var modelData
        property var trayItem: modelData

        readonly property string tooltipHeading: {
            if (trayItem.tooltipTitle && trayItem.tooltipTitle.length > 0)
                return trayItem.tooltipTitle;

            if (trayItem.title && trayItem.title.length > 0)
                return trayItem.title;

            return trayItem.id || "";
        }

        readonly property string tooltipText: {
            const heading = tooltipHeading;
            const description = trayItem.tooltipDescription || "";

            if (heading.length > 0 && description.length > 0 && description !== heading)
                return heading + " — " + description;

            return heading.length > 0 ? heading : description;
        }

        width: tray.theme.buttonWidth
        height: 30
        radius: tray.theme.radius

        color: trayMouse.containsMouse ? tray.theme.bg2 : "transparent"

        IconImage {
            anchors.centerIn: parent
            implicitSize: tray.theme.iconSize
            source: trayButton.trayItem.icon
        }

        MouseArea {
            id: trayMouse

            anchors.fill: parent
            hoverEnabled: true

            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

            onClicked: event => {
                if (event.button === Qt.MiddleButton) {
                    trayButton.trayItem.secondaryActivate();
                    return;
                }

                if (event.button === Qt.RightButton || trayButton.trayItem.onlyMenu) {
                    if (trayButton.trayItem.hasMenu)
                        trayMenu.visible = true;

                    return;
                }

                trayButton.trayItem.activate();
            }

            onWheel: event => {
                trayButton.trayItem.scroll(event.angleDelta.y, false);
            }
        }

        HoverTooltip {
            theme: tray.theme
            anchorItem: trayButton
            text: trayButton.tooltipText

            visible: trayMouse.containsMouse && trayButton.tooltipText.length > 0 && !trayMenu.visible
        }

        TrayMenu {
            id: trayMenu

            theme: tray.theme
            menu: trayButton.trayItem.menu
            anchorItem: trayButton
        }
    }
}
