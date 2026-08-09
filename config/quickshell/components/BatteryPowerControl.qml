import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets

Item {
    id: root

    required property var theme
    required property var notifications

    readonly property var battery: UPower.displayDevice
    readonly property bool ready: battery && battery.ready
    readonly property int percentage: ready ? Math.round(battery.percentage) * 100 : 0
    readonly property bool charging: ready && battery.state === UPowerDeviceState.Charging
    readonly property bool fullyCharged: ready && battery.state === UPowerDeviceState.FullyCharged

    implicitWidth: theme.buttonWidth

    Timer {
        interval: 4000
        repeat: false
        running: !root.ready
        onTriggered: {
            if (!root.ready) {
                root.notifications.showLocalOnce(
                    "battery-upower-daemon-unavailable",
                    "Battery service unavailable",
                    "UPower did not become ready. Make sure the UPower daemon is installed and running.",
                    "dialog-warning"
                );
            }
        }
    }
    implicitHeight: theme.buttonHeight

    readonly property string batteryIconName: root.ready && root.battery.iconName
                                               ? String(root.battery.iconName)
                                               : ""
    readonly property string batteryIconSource: root.batteryIconName.length > 0
                                                 ? Quickshell.iconPath(root.batteryIconName, true)
                                                 : ""
    property bool batteryIconWarningShown: false

    function warnBatteryIconUnavailable(detail) {
        if (root.batteryIconWarningShown)
            return;

        root.batteryIconWarningShown = true;
        root.notifications.showLocalOnce(
            "battery-icon-unavailable-" + root.batteryIconName,
            "Battery icon unavailable",
            detail,
            "dialog-warning"
        );
    }

    function checkBatteryIcon() {
        if (!root.ready || root.batteryIconName.length === 0)
            return;

        if (root.batteryIconSource.length === 0) {
            root.warnBatteryIconUnavailable(
                "UPower reported the icon '" + root.batteryIconName
                + "', but Qt could not resolve it from the active icon theme."
            );
        }
    }

    onBatteryIconNameChanged: Qt.callLater(root.checkBatteryIcon)
    onBatteryIconSourceChanged: Qt.callLater(root.checkBatteryIcon)

    function profileGlyph() {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return "";
        case PowerProfile.Performance:
            return ""; 
        case PowerProfile.Balanced:
        default:
            return "";
        }
    }

    function profileLabel() {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return "Power saver";
        case PowerProfile.Performance:
            return "Performance";
        case PowerProfile.Balanced:
        default:
            return "Balanced";
        }
    }

    function stateLabel() {
        if (!ready)
            return "Battery unavailable";

        switch (battery.state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.PendingCharge:
            return "Waiting to charge";
        case UPowerDeviceState.PendingDischarge:
            return "Waiting to discharge";
        case UPowerDeviceState.Empty:
            return "Empty";
        default:
            return UPower.onBattery ? "On battery" : "Plugged in";
        }
    }

    function durationLabel(seconds) {
        if (!seconds || seconds <= 0)
            return "";

        const totalMinutes = Math.round(seconds / 60);
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;

        if (hours > 0 && minutes > 0)
            return hours + "h " + minutes + "m";
        if (hours > 0)
            return hours + "h";
        return minutes + "m";
    }

    function tooltipText() {
        if (!ready)
            return "Battery unavailable • " + profileLabel();

        let text = percentage + "% • " + stateLabel();
        const seconds = charging ? battery.timeToFull : battery.timeToEmpty;
        const duration = durationLabel(seconds);

        if (duration.length > 0)
            text += charging ? " • " + duration + " to full" : " • " + duration + " remaining";

        return text + " • " + profileLabel();
    }

    function profileColor() {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return theme.green;
        case PowerProfile.Performance:
            return theme.orange;
        case PowerProfile.Balanced:
        default:
            return theme.aqua;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: profilePopup.visible ? root.theme.bgGreen
                                    : (batteryMouse.containsMouse ? root.theme.bg2 : "transparent")
        border.width: profilePopup.visible ? 1 : 0
        border.color: root.profileColor()

        IconImage {
            id: batteryIcon
            anchors.centerIn: parent
            implicitSize: root.theme.iconSize + 2
            source: root.batteryIconSource
            visible: root.ready && source.toString().length > 0 && status !== Image.Error

            onStatusChanged: {
                if (status === Image.Error && root.ready && root.batteryIconName.length > 0) {
                    root.warnBatteryIconUnavailable(
                        "Qt found the battery icon name '" + root.batteryIconName
                        + "', but failed to render it. The config is pinned to the Everforest-Dark Qt icon theme."
                    );
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.ready && !batteryIcon.visible
            text: root.percentage + "%"
            color: root.percentage <= 15 ? root.theme.red : root.theme.fg
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.smallTextSize
            font.weight: Font.DemiBold
        }

        Text {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 3
            anchors.bottomMargin: 2
            text: root.profileGlyph()
            color: root.profileColor()
            font.family: root.theme.fontFamily
            font.pixelSize: Math.max(14, root.theme.smallTextSize - 1)
        }

        MouseArea {
            id: batteryMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: profilePopup.visible = !profilePopup.visible
        }
    }

    HoverTooltip {
        theme: root.theme
        anchorItem: root
        visible: batteryMouse.containsMouse && !profilePopup.visible
        text: root.tooltipText()
    }

    PowerProfileMenu {
        id: profilePopup
        theme: root.theme
        anchorItem: root
        notifications: root.notifications
    }
}
