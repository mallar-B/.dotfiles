import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        screen: modelData
        color: "#18000000"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // NOTE: Bottom layer, not Background and not placed in the overview backdrop.
        // Niri zooms this together with each workspace.
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "workspace-blur"
    }
}
