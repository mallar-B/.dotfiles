import QtQuick
import Quickshell.Io

Item {
    id: root

    required property var theme
    required property var notifications

    implicitWidth: 0
    implicitHeight: 0
    readonly property bool available: backendLoader.status === Loader.Ready && backendLoader.item !== null
    readonly property bool locked: root.available ? backendLoader.item.locked : false

    function notifyUnavailable(once) {
        const summary = "Lockscreen unavailable";
        const body = "QuickShell could not load the PAM-backed lockscreen. Make sure Quickshell.Services.Pam and Wayland session-lock support are available.";

        if (once)
            root.notifications.showLocalOnce("lockscreen-module-unavailable", summary, body, "dialog-warning");
        else
            root.notifications.showLocal(summary, body, "dialog-warning");
    }

    function lock() {
        if (!root.available) {
            root.notifyUnavailable(false);
            return;
        }

        backendLoader.item.lock();
    }

    Component.onCompleted: {
        backendLoader.setSource(Qt.resolvedUrl("LockBackend.qml"), {
            "theme": root.theme,
            "notifications": root.notifications
        });
        Qt.callLater(() => {
            if (backendLoader.status === Loader.Error)
                root.notifyUnavailable(true);
        });
    }

    Loader {
        id: backendLoader

        onStatusChanged: {
            if (status === Loader.Error)
                root.notifyUnavailable(true);
        }
    }

    // Lets niri keybindings or scripts lock the session without depending on
    // compositor-specific commands:
    //   qs ipc call lockscreen lock
    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            root.lock();
        }

        function isLocked(): bool {
            return root.locked;
        }

        function isAvailable(): bool {
            return root.available;
        }
    }
}
