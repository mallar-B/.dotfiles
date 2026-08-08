import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    // These arrays are replaced on every relevant event so QML bindings
    // depending on isOccupied() are reevaluated immediately.
    property var workspaces: []
    property var windows: []

    function isOccupied(workspaceName) {
        let workspaceId = null;

        // Prefer named workspaces (your "1" ... "10" setup), but fall back
        // to niri's per-output numeric index if a workspace has no name.
        for (let i = 0; i < root.workspaces.length; ++i) {
            const workspace = root.workspaces[i];
            if (!workspace)
                continue;

            if (workspace.name === workspaceName) {
                workspaceId = workspace.id;
                break;
            }
        }

        if (workspaceId === null) {
            for (let i = 0; i < root.workspaces.length; ++i) {
                const workspace = root.workspaces[i];
                if (workspace && !workspace.name && String(workspace.idx) === workspaceName) {
                    workspaceId = workspace.id;
                    break;
                }
            }
        }

        if (workspaceId === null)
            return false;

        for (let i = 0; i < root.windows.length; ++i) {
            const window = root.windows[i];
            if (window && window.workspace_id === workspaceId)
                return true;
        }

        return false;
    }

    function replaceWindow(window) {
        if (!window)
            return;

        const updated = root.windows.slice();
        let replaced = false;

        for (let i = 0; i < updated.length; ++i) {
            if (updated[i] && updated[i].id === window.id) {
                updated[i] = window;
                replaced = true;
                break;
            }
        }

        if (!replaced)
            updated.push(window);

        root.windows = updated;
    }

    function removeWindow(windowId) {
        root.windows = root.windows.filter(window => window && window.id !== windowId);
    }

    function handleEvent(line) {
        if (!line || line.trim().length === 0)
            return;

        let event;
        try {
            event = JSON.parse(line);
        } catch (error) {
            console.warn("Could not parse niri event:", error);
            return;
        }

        if (event.WorkspacesChanged) {
            root.workspaces = event.WorkspacesChanged.workspaces || [];
            return;
        }

        if (event.WindowsChanged) {
            root.windows = event.WindowsChanged.windows || [];
            return;
        }

        if (event.WindowOpenedOrChanged) {
            root.replaceWindow(event.WindowOpenedOrChanged.window);
            return;
        }

        if (event.WindowClosed)
            root.removeWindow(event.WindowClosed.id);
    }

    Process {
        id: eventStream
        running: true
        command: ["niri", "msg", "--json", "event-stream"]

        stdout: SplitParser {
            onRead: data => root.handleEvent(data)
        }

        // Normally this lives for the whole niri session. If niri reloads or
        // the IPC stream is interrupted, reconnect instead of silently dying.
        onRunningChanged: {
            if (!running)
                reconnectTimer.restart();
        }
    }

    Timer {
        id: reconnectTimer
        interval: 1000
        repeat: false
        onTriggered: eventStream.running = true
    }
}
