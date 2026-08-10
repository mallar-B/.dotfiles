import QtQuick
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Wayland
import "../components"

Item {
    id: root

    required property var theme
    required property var notifications

    implicitWidth: 0
    implicitHeight: 0
    readonly property bool locked: sessionLock.locked
    readonly property string userName: String(Quickshell.env("USER") || "user")
    readonly property bool responseVisible: pam.responseRequired && pam.responseVisible

    property string currentText: ""
    property string pendingResponse: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property string statusText: ""
    property bool statusError: false

    signal clearInputs

    onCurrentTextChanged: {
        if (currentText.length > 0) {
            showFailure = false;
            if (statusError)
                statusText = "";
            statusError = false;
        }
    }

    function resetUi() {
        root.currentText = "";
        root.pendingResponse = "";
        root.unlockInProgress = false;
        root.showFailure = false;
        root.statusText = "";
        root.statusError = false;
        root.clearInputs();
    }

    function startPam() {
        if (pam.active)
            return true;

        const started = pam.start();
        if (!started) {
            root.statusText = "PAM authentication could not be started";
            root.statusError = true;
        }
        return started;
    }

    function lock() {
        if (sessionLock.locked)
            return;

        root.resetUi();

        if (!root.startPam()) {
            root.notifications.showLocal("Lockscreen authentication unavailable", "PAM could not start, so the session was not locked. Check the local pam/password.conf configuration and Quickshell PAM support.", "dialog-warning");
            return;
        }

        sessionLock.locked = true;
    }

    function tryUnlock() {
        if (!sessionLock.locked || root.unlockInProgress || root.currentText.length === 0)
            return;

        root.unlockInProgress = true;
        root.showFailure = false;
        root.statusError = false;
        root.pendingResponse = root.currentText;

        if (!root.startPam()) {
            root.unlockInProgress = false;
            return;
        }

        if (pam.responseRequired) {
            const response = root.pendingResponse;
            root.pendingResponse = "";
            pam.respond(response);
        } else {
            root.statusText = pam.message || "Waiting for authentication…";
        }
    }

    PamContext {
        id: pam

        // Keep the auth policy with the shell rather than relying on a distro's
        // login/display-manager PAM stack, which may ask questions this UI does not support.
        configDirectory: "../pam"
        config: "password.conf"

        onPamMessage: {
            root.statusError = pam.messageIsError;

            if (pam.responseRequired && !pam.messageIsError) {
                root.statusText = "";
            } else {
                root.statusText = pam.message ? pam.message.trim() : "";
            }

            if (pam.responseRequired && root.pendingResponse.length > 0) {
                const response = root.pendingResponse;
                root.pendingResponse = "";
                pam.respond(response);
            }
        }
        onError: error => {
            root.unlockInProgress = false;
            root.statusText = "Authentication service error: " + PamError.toString(error);
            root.statusError = true;
            root.pendingResponse = "";
            root.currentText = "";
            root.clearInputs();
        }

        onCompleted: result => {
            root.unlockInProgress = false;
            root.pendingResponse = "";

            if (result === PamResult.Success) {
                root.resetUi();
                sessionLock.locked = false;
                return;
            }

            root.currentText = "";
            root.clearInputs();

            if (result === PamResult.Failed) {
                root.showFailure = true;
                root.statusText = "Incorrect password";
                root.statusError = true;
            } else if (result === PamResult.MaxTries) {
                root.statusText = "Too many authentication attempts. Try again.";
                root.statusError = true;
            } else if (root.statusText.length === 0) {
                root.statusText = "Authentication failed to complete";
                root.statusError = true;
            }
        }
    }

    WlSessionLock {
        id: sessionLock
        reloadableId: "everforest-session-lock"
        locked: false

        WlSessionLockSurface {
            color: root.theme.bgDim

            LockSurface {
                anchors.fill: parent
                theme: root.theme
                context: root
            }
        }
    }
}
