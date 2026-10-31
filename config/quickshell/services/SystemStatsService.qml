import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // ------------------------------------------------------------
    // Overlay state
    // ------------------------------------------------------------

    property bool visible: false
    property bool expanded: false
    property var targetScreen: null

    // ------------------------------------------------------------
    // Live stats
    // ------------------------------------------------------------

    property real cpuUsage: 0
    property real cpuTemp: -1
    property real gpuUsage: -1
    property real gpuTemp: -1
    property real ramUsage: 0
    property real ramTemp: -1
    property real memUsed: 0
    property real memTotal: 0

    property bool isAmd: false
    property bool boost: false
    property bool boostKnown: false

    property var disks: []

    // ------------------------------------------------------------
    // Delta tracking (CPU jiffies, disk sectors)
    // ------------------------------------------------------------

    property double lastCpuTotal: -1
    property double lastCpuIdle: -1
    property double lastTick: 0
    property var lastDiskSectors: ({})

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

    function toggleExpanded() {
        expanded = !expanded;
    }

    // ------------------------------------------------------------
    // Sampling
    // ------------------------------------------------------------

    function handleLine(line) {
        if (!line || line.trim().length === 0)
            return;

        let data;
        try {
            data = JSON.parse(line);
        } catch (error) {
            console.warn("Could not parse system stats:", error);
            return;
        }

        updateCpu(data);
        updateMemory(data);
        updateGpu(data);
        updateBoost(data);
        updateTemps(data);
        updateDisks(data);
    }

    function updateCpu(data) {
        if (typeof data.cpuTotal !== "number" || typeof data.cpuIdle !== "number")
            return;

        if (lastCpuTotal >= 0 && data.cpuTotal > lastCpuTotal) {
            const totalDelta = data.cpuTotal - lastCpuTotal;
            const idleDelta = data.cpuIdle - lastCpuIdle;

            cpuUsage = Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100));
        }

        lastCpuTotal = data.cpuTotal;
        lastCpuIdle = data.cpuIdle;
    }

    function updateMemory(data) {
        if (typeof data.memTotal !== "number" || data.memTotal <= 0)
            return;

        const totalBytes = data.memTotal * 1024;
        const usedBytes = (data.memTotal - data.memAvailable) * 1024;

        memTotal = totalBytes;
        memUsed = usedBytes;
        ramUsage = Math.max(0, Math.min(100, (usedBytes / totalBytes) * 100));
    }

    function updateGpu(data) {
        if (typeof data.gpuUsage === "number")
            gpuUsage = Math.max(0, Math.min(100, data.gpuUsage));
        else
            gpuUsage = -1;
    }

    function updateBoost(data) {
        isAmd = data.amd === true;

        if (typeof data.boost === "number") {
            boostKnown = true;
            boost = data.boost !== 0;
        } else {
            boostKnown = false;
            boost = false;
        }
    }

    function updateTemps(data) {
        if (typeof data.cpuTemp === "number")
            cpuTemp = data.cpuTemp / 1000;

        if (typeof data.gpuTemp === "number")
            gpuTemp = data.gpuTemp / 1000;

        if (typeof data.ramTemp === "number")
            ramTemp = data.ramTemp / 1000;
    }

    function updateDisks(data) {
        const now = Date.now();
        const dt = lastTick > 0 ? (now - lastTick) / 1000 : 0;
        const previous = lastDiskSectors;
        const next = {};
        const result = [];
        const list = Array.isArray(data.disks) ? data.disks : [];

        for (let i = 0; i < list.length; ++i) {
            const disk = list[i];
            const prior = previous[disk.name];

            let readRate = 0;
            let writeRate = 0;

            if (prior && dt > 0) {
                readRate = Math.max(0, (disk.readSectors - prior.read) * 512 / dt);
                writeRate = Math.max(0, (disk.writeSectors - prior.write) * 512 / dt);
            }

            next[disk.name] = {
                "read": disk.readSectors,
                "write": disk.writeSectors
            };

            result.push({
                "name": disk.name,
                "readRate": readRate,
                "writeRate": writeRate,
                "temp": typeof disk.temp === "number" ? disk.temp / 1000 : -1
            });
        }

        lastDiskSectors = next;
        lastTick = now;
        disks = result;
    }

    Process {
        id: collector

        command: ["bash", Quickshell.shellPath("services/system-stats.sh")]

        stdout: SplitParser {
            onRead: data => root.handleLine(data)
        }
    }

    Timer {
        id: pollTimer

        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (!collector.running)
                collector.running = true;
        }
    }

    // Allows window manager keybindings or scripts to control the overlay:
    //   qs ipc call stats toggle
    //   qs ipc call stats toggleExpanded
    IpcHandler {
        target: "stats"

        function toggle(): void {
            root.toggle(root.preferredScreen());
        }

        function show(): void {
            root.show(root.preferredScreen());
        }

        function hide(): void {
            root.hide();
        }

        function expand(): void {
            root.expanded = true;
        }

        function collapse(): void {
            root.expanded = false;
        }

        function toggleExpanded(): void {
            root.toggleExpanded();
        }
    }
}
