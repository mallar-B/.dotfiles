import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland

Scope {
    id: root

    required property QtObject lockController
    property QtObject notifications: null

    property int lockTimeoutSeconds: 300
    property int suspendTimeoutSeconds: 900

    property bool inhibited: false
    property string inhibitMode: ""

    property bool suspendPending: false
    property bool suspending: false
    property bool settingsLoaded: false

    readonly property bool locked: lockController && lockController.locked === true

    readonly property bool mediaPlaying: {
        const players = Mpris.players.values;

        for (let i = 0; i < players.length; ++i) {
            if (players[i].isPlaying)
                return true;
        }

        return false;
    }

    readonly property bool blocked: inhibited || mediaPlaying

    readonly property string statusText: {
        if (inhibited)
            return "Idle inhibited • " + (inhibitMode === "indefinite" ? "indefinite" : inhibitMode);

        if (mediaPlaying)
            return "Media playing • idle inhibited";

        return "Lock " + timeoutLabel(lockTimeoutSeconds) + " • suspend " + timeoutLabel(suspendTimeoutSeconds);
    }

    // ------------------------------------------------------------
    // Persistence
    // ------------------------------------------------------------

    FileView {
        id: settingsFile

        path: Quickshell.statePath("idle-manager.json")
        blockLoading: true
        printErrors: false
    }

    Component.onCompleted: {
        try {
            const data = JSON.parse(settingsFile.text());

            if (typeof data.lock === "number")
                lockTimeoutSeconds = data.lock;

            if (typeof data.suspend === "number")
                suspendTimeoutSeconds = data.suspend;
        } catch (_) {}

        settingsLoaded = true;
    }

    function saveSettings() {
        if (!settingsLoaded)
            return;

        settingsFile.setText(JSON.stringify({
            "lock": lockTimeoutSeconds,
            "suspend": suspendTimeoutSeconds
        }));
    }

    onLockTimeoutSecondsChanged: saveSettings()
    onSuspendTimeoutSecondsChanged: saveSettings()

    // ------------------------------------------------------------
    // Idle monitoring
    // ------------------------------------------------------------

    IdleMonitor {
        id: lockMonitor

        enabled: root.lockTimeoutSeconds > 0 && !root.locked && !root.blocked && !root.suspendPending && !root.suspending

        timeout: root.lockTimeoutSeconds
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle)
                root.requestLock();
        }
    }

    IdleMonitor {
        id: suspendMonitor

        enabled: root.suspendTimeoutSeconds > 0 && !root.blocked && !root.suspendPending && !root.suspending && !resumeGuard.running

        timeout: root.suspendTimeoutSeconds
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle)
                root.requestSuspend();
        }
    }

    // ------------------------------------------------------------
    // Lock / suspend
    // ------------------------------------------------------------

    Connections {
        target: root.lockController

        function onLockedChanged() {
            if (root.suspendPending && root.lockController.locked) {
                Qt.callLater(root.performSuspend);
            }
        }
    }

    Timer {
        id: suspendAfterLockTimer

        interval: 500

        onTriggered: {
            if (!root.suspendPending)
                return;

            root.performSuspend();
        }
    }

    Timer {
        id: lockTimeout

        interval: 5000

        onTriggered: {
            if (!root.suspendPending)
                return;

            root.suspendPending = false;

            root.notify("Suspend cancelled", "The session could not be locked.");
        }
    }

    Process {
        id: suspendProcess

        // stderr: StdioCollector {
        //     onStreamFinished: {
        //         if (text.length > 0)
        //             console.warn("systemctl suspend:", text);
        //     }
        // }

        onExited: function (exitCode, exitStatus) {

            root.suspending = false;
            resumeGuard.restart();
        }
    }

    // Disabling/re-enabling the IdleMonitor gives it a fresh timeout
    // after resume.
    Timer {
        id: resumeGuard
        interval: 1000
    }

    function requestLock() {
        if (!locked && !blocked)
            lockController.lock();
    }

    function requestSuspend() {
        if (blocked || suspendPending || suspending)
            return;

        if (locked) {
            performSuspend();
            return;
        }

        suspendPending = true;
        lockTimeout.restart();
        lockController.lock();
        suspendAfterLockTimer.restart();
    }

    function performSuspend() {
        if (blocked) {
            suspendPending = false;
            return;
        }

        suspendAfterLockTimer.stop();
        lockTimeout.stop();

        suspendPending = false;
        suspending = true;

        suspendProcess.exec(["systemctl", "suspend"]);
    }

    // ------------------------------------------------------------
    // Manual inhibition
    // ------------------------------------------------------------

    Timer {
        id: inhibitTimer

        onTriggered: root.stopInhibiting(false)
    }

    function inhibit(seconds, mode) {
        inhibited = true;
        inhibitMode = mode;

        if (seconds > 0) {
            inhibitTimer.interval = seconds * 1000;
            inhibitTimer.restart();
        } else {
            inhibitTimer.stop();
        }

        notify("Idle inhibition enabled", mode === "indefinite" ? "Automatic idle actions are inhibited indefinitely." : "Automatic idle actions are inhibited for " + mode + ".");
    }

    function inhibitOneHour() {
        inhibit(3600, "1h");
    }

    function inhibitThreeHours() {
        inhibit(10800, "3h");
    }

    function inhibitIndefinitely() {
        inhibit(0, "indefinite");
    }

    function stopInhibiting(showNotification) {
        const wasInhibited = inhibited;

        inhibitTimer.stop();

        inhibited = false;
        inhibitMode = "";

        if (wasInhibited && showNotification !== false) {
            notify("Idle inhibition disabled", "Automatic idle actions are active again.");
        }
    }

    // ------------------------------------------------------------
    // Settings
    // ------------------------------------------------------------

    function setLockTimeout(seconds) {
        lockTimeoutSeconds = seconds;
    }

    function setSuspendTimeout(seconds) {
        suspendTimeoutSeconds = seconds;
    }

    function timeoutLabel(seconds) {
        if (seconds === 0)
            return "never";

        if (seconds >= 3600)
            return "after " + (seconds / 3600) + "h";

        return "after " + (seconds / 60) + "m";
    }

    function notify(title, body) {
        if (notifications && typeof notifications.showLocal === "function") {
            notifications.showLocal(title, body, "preferences-system-time");
        }
    }
}
