import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland

Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    property bool osdVisible: false
    property string osdKind: "volume"
    property string osdTitle: "Volume"
    property string osdDevice: ""
    property int osdPercentage: 0
    property bool osdMuted: false
    property var osdScreen: null

    property bool initialized: false
    property int lastSinkId: -1
    property int lastSourceId: -1
    property double suppressVolumeUntil: 0

    function preferredScreen() {
        const active = ToplevelManager.activeToplevel;
        if (active && active.screens && active.screens.length > 0)
            return active.screens[0];

        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function nodeLabel(node) {
        if (!node)
            return "Unknown device";
        if (node.nickname && node.nickname.length > 0)
            return node.nickname;
        if (node.description && node.description.length > 0)
            return node.description;
        if (node.name && node.name.length > 0)
            return node.name;
        return "Unknown device";
    }

    function showVolume() {
        if (!initialized || !sink || !sink.audio || Date.now() < suppressVolumeUntil)
            return;

        osdKind = "volume";
        osdTitle = sink.audio.muted ? "Muted" : "Volume";
        osdDevice = nodeLabel(sink);
        osdPercentage = Math.round(sink.audio.volume * 100);
        osdMuted = sink.audio.muted;
        show();
    }

    function showOutputDevice() {
        if (!initialized || !sink)
            return;

        osdKind = "output";
        osdTitle = "Audio output";
        osdDevice = nodeLabel(sink);
        osdPercentage = sink.audio ? Math.round(sink.audio.volume * 100) : 0;
        osdMuted = sink.audio ? sink.audio.muted : false;
        show();
    }

    function showInputDevice() {
        if (!initialized || !source)
            return;

        osdKind = "input";
        osdTitle = "Audio input";
        osdDevice = nodeLabel(source);
        osdPercentage = source.audio ? Math.round(source.audio.volume * 100) : 0;
        osdMuted = source.audio ? source.audio.muted : false;
        show();
    }

    function show() {
        const target = preferredScreen();
        if (!target)
            return;

        osdScreen = target;
        osdVisible = true;
        hideTimer.restart();
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Timer {
        id: startupTimer
        interval: 800
        repeat: false
        running: true
        onTriggered: {
            root.lastSinkId = root.sink ? root.sink.id : -1;
            root.lastSourceId = root.source ? root.source.id : -1;
            root.initialized = true;
        }
    }

    Timer {
        id: hideTimer
        interval: 1800
        repeat: false
        onTriggered: root.osdVisible = false
    }

    onSinkChanged: {
        if (!initialized || !sink)
            return;

        if (sink.id !== lastSinkId) {
            lastSinkId = sink.id;
            suppressVolumeUntil = Date.now() + 400;
            Qt.callLater(root.showOutputDevice);
        }
    }

    onSourceChanged: {
        if (!initialized || !source)
            return;

        if (source.id !== lastSourceId) {
            lastSourceId = source.id;
            Qt.callLater(root.showInputDevice);
        }
    }

    Connections {
        target: root.sink && root.sink.audio ? root.sink.audio : null

        function onVolumeChanged() {
            root.showVolume();
        }

        function onMutedChanged() {
            root.showVolume();
        }
    }
}
