import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    required property var theme

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink && sink.audio
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property int percentage: ready ? Math.round(sink.audio.volume * 100) : 0

    implicitWidth: theme.buttonWidth
    implicitHeight: theme.buttonHeight

    function setVolume(value) {
        if (!ready)
            return;

        sink.audio.volume = Math.max(0, Math.min(1.5, value));
    }

    function changeVolume(delta) {
        if (ready)
            setVolume(sink.audio.volume + delta);
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: volumeMouse.containsMouse ? root.theme.bg2 : "transparent"

        VolumeGlyph {
            anchors.centerIn: parent
            width: root.theme.iconSize + 2
            height: root.theme.iconSize + 2
            percentage: root.percentage
            muted: !root.ready || root.muted
            glyphColor: (!root.ready || root.muted) ? root.theme.red : root.theme.blue
        }

        MouseArea {
            id: volumeMouse
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                if (root.ready)
                    root.sink.audio.muted = !root.sink.audio.muted;
            }

            onWheel: event => {
                if (event.angleDelta.y > 0)
                    root.changeVolume(0.05);
                else if (event.angleDelta.y < 0)
                    root.changeVolume(-0.05);
            }
        }
    }

    HoverTooltip {
        theme: root.theme
        anchorItem: root
        visible: volumeMouse.containsMouse
        text: root.ready ? root.percentage + "% (max 150%)" : "Audio unavailable"
    }
}
