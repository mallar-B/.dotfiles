import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property bool visible: false
    property var targetScreen: null

    function preferredScreen() {
        const active = ToplevelManager.activeToplevel;
        if (active && active.screens && active.screens.length > 0)
            return active.screens[0];

        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function show(screen) {
        targetScreen = screen || preferredScreen();
        visible = targetScreen !== null;
    }

    function hide() {
        visible = false;
    }

    function toggle(screen) {
        if (visible)
            hide();
        else
            show(screen);
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle(root.preferredScreen());
        }

        function show(): void {
            root.show(root.preferredScreen());
        }

        function hide(): void {
            root.hide();
        }
    }
}
