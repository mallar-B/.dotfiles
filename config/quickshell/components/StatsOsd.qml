pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    id: root

    required property var theme
    required property var stats

    model: Quickshell.screens

    property var coreRows: [
        {
            "kind": "cpu",
            "label": "CPU"
        },
        {
            "kind": "gpu",
            "label": "GPU"
        },
        {
            "kind": "vram",
            "label": "VRAM",
            "showTemp": false
        },
        {
            "kind": "ram",
            "label": "RAM"
        }
    ]

    function usageFor(kind) {
        if (kind === "cpu")
            return root.stats.cpuUsage;

        if (kind === "gpu")
            return root.stats.gpuUsage;

        return root.stats.ramUsage;
    }

    function tempFor(kind) {
        if (kind === "cpu")
            return root.stats.cpuTemp;

        if (kind === "gpu")
            return root.stats.gpuTemp;

        return root.stats.ramTemp;
    }

    function vramRatio() {
        if (root.stats.gpuVramUsed < 0 || root.stats.gpuVramTotal <= 0)
            return 0;

        return Math.min(100, root.stats.gpuVramUsed / root.stats.gpuVramTotal * 100);
    }

    function barFractionFor(kind) {
        if (kind === "vram")
            return vramRatio() / 100;

        return Math.max(0, Math.min(1, usageFor(kind) / 100));
    }

    function usageColor(kind) {
        const usage = kind === "vram" ? vramRatio() : usageFor(kind);

        if (usage < 0 || (kind === "vram" && root.stats.gpuVramUsed < 0))
            return root.theme.grey0;

        if (usage >= 90)
            return root.theme.red;

        if (usage >= 70)
            return root.theme.orange;

        if (usage >= 40)
            return root.theme.yellow;

        return root.theme.green;
    }

    function formatTemp(value) {
        return value >= 0 ? Math.round(value) + "°C" : "--";
    }

    function formatUsage(value) {
        return value >= 0 ? Math.round(value) + "%" : "--";
    }

    function formatBytes(bytes) {
        if (!isFinite(bytes) || bytes < 1)
            return "0 B";

        const units = ["B", "KiB", "MiB", "GiB", "TiB"];
        let index = 0;
        let value = bytes;

        while (value >= 1024 && index < units.length - 1) {
            value /= 1024;
            index++;
        }

        return (value >= 100 ? Math.round(value) : value.toFixed(1)) + " " + units[index];
    }

    function usageTextFor(kind) {
        if (kind !== "vram")
            return formatUsage(usageFor(kind));

        if (root.stats.gpuVramUsed < 0)
            return "--";

        let text = formatBytes(root.stats.gpuVramUsed);

        if (root.stats.gpuVramTotal > 0)
            text += " / " + formatBytes(root.stats.gpuVramTotal);

        return text;
    }

    function formatRate(bytesPerSecond) {
        if (!isFinite(bytesPerSecond) || bytesPerSecond < 1)
            return "0 B/s";

        const units = ["B/s", "KiB/s", "MiB/s", "GiB/s"];
        let index = 0;
        let value = bytesPerSecond;

        while (value >= 1024 && index < units.length - 1) {
            value /= 1024;
            index++;
        }

        return (value >= 100 ? Math.round(value) : value.toFixed(1)) + " " + units[index];
    }

    PanelWindow {
        id: panel

        property var modelData

        // Distance from the top and right screen edges. Updated while dragging.
        property real dragMarginX: 18
        property real dragMarginY: 18

        screen: modelData
        visible: root.stats.visible && root.stats.targetScreen === modelData
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 268
        implicitHeight: contentLayout.implicitHeight + 24

        anchors {
            top: true
            right: true
        }

        margins {
            top: panel.dragMarginY
            right: panel.dragMarginX
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "everforest-stats-osd"

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: root.theme.radius + 3
            color: root.theme.bg0
            border.width: 1
            border.color: root.theme.bg3

            Column {
                id: contentLayout

                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // ----------------------------------------------------
                // Header / drag handle
                // ----------------------------------------------------
                Item {
                    id: header

                    width: parent.width
                    height: 18

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "⣿"
                            color: root.theme.grey0
                            font.family: root.theme.fontFamily
                            font.pixelSize: 13
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "SYSTEM"
                            color: root.theme.fg
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textSize
                            font.bold: true
                            font.letterSpacing: 1
                        }
                    }

                    Text {
                        id: closeButton

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "✕"
                        color: closeArea.containsMouse ? root.theme.red : root.theme.grey1
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13

                        MouseArea {
                            id: closeArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stats.hide()
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: closeButton.width + 10
                        cursorShape: Qt.OpenHandCursor

                        property real pressX: 0
                        property real pressY: 0
                        property real startMarginX: 0
                        property real startMarginY: 0

                        onPressed: mouse => {
                            pressX = mouse.x;
                            pressY = mouse.y;
                            startMarginX = panel.dragMarginX;
                            startMarginY = panel.dragMarginY;
                        }

                        onPositionChanged: mouse => {
                            if (!pressed)
                                return;

                            const maxX = Math.max(0, panel.screen.width - panel.implicitWidth);
                            const maxY = Math.max(0, panel.screen.height - panel.implicitHeight);

                            const nextX = startMarginX - (mouse.x - pressX);
                            const nextY = startMarginY + (mouse.y - pressY);

                            panel.dragMarginX = Math.max(0, Math.min(maxX, nextX));
                            panel.dragMarginY = Math.max(0, Math.min(maxY, nextY));
                        }
                    }
                }

                // ----------------------------------------------------
                // Core stats (CPU / GPU / RAM)
                // ----------------------------------------------------
                Repeater {
                    model: root.coreRows

                    delegate: Column {
                        required property var modelData

                        width: contentLayout.width
                        spacing: 3

                        Item {
                            width: parent.width
                            height: 16

                            Text {
                                id: rowLabel

                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: root.theme.fg
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize + 1
                                font.bold: true
                            }

                            Text {
                                id: rowUsage

                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.usageTextFor(modelData.kind)
                                color: root.usageColor(modelData.kind)
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize + 1
                                font.bold: true
                            }

                            Text {
                                anchors.right: rowUsage.left
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                visible: modelData.showTemp !== false
                                text: root.formatTemp(root.tempFor(modelData.kind))
                                color: root.theme.grey1
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 5
                            radius: 3
                            color: root.theme.bg2

                            Rectangle {
                                width: parent.width * root.barFractionFor(modelData.kind)
                                height: parent.height
                                radius: parent.radius
                                color: root.usageColor(modelData.kind)

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 180
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }
                    }
                }

                // ----------------------------------------------------
                // Expand arrow
                // ----------------------------------------------------
                Item {
                    width: parent.width
                    height: 14

                    Text {
                        anchors.centerIn: parent
                        text: root.stats.expanded ? "▴" : "▾"
                        color: arrowArea.containsMouse ? root.theme.fg : root.theme.grey1
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: arrowArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.stats.toggleExpanded()
                    }
                }

                // ----------------------------------------------------
                // Expanded details
                // ----------------------------------------------------
                Column {
                    width: parent.width
                    spacing: 7
                    visible: root.stats.expanded
                    opacity: root.stats.expanded ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 140
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.theme.bg3
                    }

                    Item {
                        width: parent.width
                        height: 16
                        visible: root.stats.isAmd

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "CPU Boost"
                            color: root.theme.fg
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.smallTextSize + 1
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.stats.boostKnown ? (root.stats.boost ? "ON" : "OFF") : "--"
                            color: !root.stats.boostKnown ? root.theme.grey0 : (root.stats.boost ? root.theme.green : root.theme.grey1)
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.smallTextSize + 1
                            font.bold: true
                        }
                    }

                    Text {
                        width: parent.width
                        text: "STORAGE"
                        color: root.theme.grey0
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.smallTextSize
                        font.bold: true
                        font.letterSpacing: 1
                        visible: root.stats.disks.length > 0
                    }

                    Repeater {
                        model: root.stats.disks

                        delegate: Column {
                            required property var modelData

                            width: contentLayout.width
                            spacing: 1

                            Item {
                                width: parent.width
                                height: 15

                                Text {
                                    id: diskName

                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    color: root.theme.fg
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.formatTemp(modelData.temp)
                                    color: root.theme.grey1
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }
                            }

                            Row {
                                spacing: 12

                                Text {
                                    text: "R " + root.formatRate(modelData.readRate)
                                    color: root.theme.blue
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }

                                Text {
                                    text: "W " + root.formatRate(modelData.writeRate)
                                    color: root.theme.orange
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
