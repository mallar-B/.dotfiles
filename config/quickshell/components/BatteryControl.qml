import QtQuick

Item {
    id: root

    required property var theme
    required property var notifications

    implicitWidth: theme.buttonWidth
    implicitHeight: theme.buttonHeight

    function notifyModuleUnavailable(once) {
        const summary = "Battery module unavailable";
        const body = "Quickshell.Services.UPower could not be loaded. Battery status and power-profile controls are disabled.";

        if (once)
            root.notifications.showLocalOnce("battery-upower-module-unavailable", summary, body, "dialog-warning");
        else
            root.notifications.showLocal(summary, body, "dialog-warning");
    }

    function checkBackendStatus() {
        if (backendLoader.status === Loader.Error)
            root.notifyModuleUnavailable(true);
    }

    Component.onCompleted: {
        backendLoader.setSource(Qt.resolvedUrl("BatteryPowerControl.qml"), {
            "theme": root.theme,
            "notifications": root.notifications
        });
        Qt.callLater(root.checkBackendStatus);
    }

    Loader {
        id: backendLoader
        anchors.fill: parent

        onStatusChanged: {
            if (status === Loader.Error)
                root.notifyModuleUnavailable(true);
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: backendLoader.status === Loader.Error
        radius: root.theme.radius
        color: fallbackMouse.containsMouse ? root.theme.bgRed : "transparent"
        border.width: fallbackMouse.containsMouse ? 1 : 0
        border.color: root.theme.red

        Text {
            anchors.centerIn: parent
            text: ""
            color: root.theme.red
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.iconSize
        }

        MouseArea {
            id: fallbackMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.notifyModuleUnavailable(false)
        }
    }

    HoverTooltip {
        theme: root.theme
        anchorItem: root
        visible: backendLoader.status === Loader.Error && fallbackMouse.containsMouse
        text: "Battery / power-profile module unavailable"
    }
}
