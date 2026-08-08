import QtQuick
import Quickshell

Column {
    id: root

    required property var theme
    required property var projection
    required property var niriWorkspaces
    property int workspaceCount: 10
    spacing: 1

    function isActive(workspaceName) {
        if (!projection || !projection.windowsets)
            return false;

        for (let i = 0; i < projection.windowsets.length; ++i) {
            const workspace = projection.windowsets[i];
            if (workspace && workspace.name === workspaceName && workspace.active)
                return true;
        }

        return false;
    }

    function focusWorkspace(workspaceName) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", workspaceName]);
    }

    function focusPreviousWorkspace() {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace-up"]);
    }

    function focusNextWorkspace() {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace-down"]);
    }

    Repeater {
        model: root.workspaceCount

        Item {
            id: workspaceItem
            required property int index

            readonly property string workspaceName: String(index + 1)
            readonly property bool occupied: root.niriWorkspaces.isOccupied(workspaceName)
            readonly property bool current: root.isActive(workspaceName)

            width: root.theme.buttonWidth
            height: root.theme.buttonHeight

            IconButton {
                anchors.fill: parent
                theme: root.theme
                label: workspaceItem.workspaceName
                labelSize: root.theme.textSize
                labelColor: workspaceItem.current
                    ? root.theme.fg
                    : (workspaceItem.occupied ? root.theme.aqua : root.theme.grey1)
                active: workspaceItem.current

                onClicked: root.focusWorkspace(workspaceItem.workspaceName)
                onWheelUp: root.focusPreviousWorkspace()
                onWheelDown: root.focusNextWorkspace()
            }

            // Small dot to denote the workspace contains at least one window.
            Rectangle {
                visible: workspaceItem.occupied
                width: 5
                height: 5
                radius: 3
                color: root.theme.aqua
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
