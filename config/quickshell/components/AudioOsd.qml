pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    id: root

    required property var theme
    required property var audio

    model: Quickshell.screens

    PanelWindow {
        id: osd

        property var modelData

        screen: modelData
        visible: root.audio.osdVisible && root.audio.osdScreen === modelData
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 360
        implicitHeight: 88

        anchors {
            bottom: true
        }

        margins {
            bottom: 48
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "everforest-audio-osd"

        Rectangle {
            anchors.fill: parent
            radius: root.theme.radius + 3
            color: root.theme.bg0
            border.width: 1
            border.color: root.theme.bg3

            Row {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                Item {
                    width: 42
                    height: 42
                    anchors.verticalCenter: parent.verticalCenter

                    VolumeGlyph {
                        anchors.fill: parent
                        visible: root.audio.osdKind !== "input"
                        percentage: root.audio.osdPercentage
                        muted: root.audio.osdMuted
                        glyphColor: root.audio.osdMuted ? root.theme.red : root.theme.blue
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.audio.osdKind === "input"
                        text: root.audio.osdMuted ? "MIC×" : "MIC"
                        color: root.audio.osdMuted ? root.theme.red : root.theme.aqua
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Column {
                    width: parent.width - 56
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            width: parent.width - percentText.width - 8
                            text: root.audio.osdTitle
                            color: root.theme.fg
                            elide: Text.ElideRight
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textSize
                            font.bold: true
                        }

                        Text {
                            id: percentText
                            visible: root.audio.osdKind === "volume"
                            text: root.audio.osdPercentage + "%"
                            color: root.audio.osdPercentage > 100 ? root.theme.orange : root.theme.green
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textSize
                            font.bold: true
                        }
                    }

                    Text {
                        width: parent.width
                        text: root.audio.osdDevice
                        color: root.theme.grey1
                        elide: Text.ElideRight
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.smallTextSize
                    }

                    Rectangle {
                        width: parent.width
                        height: 5
                        radius: 3
                        color: root.theme.bg2
                        visible: root.audio.osdKind === "volume"

                        Rectangle {
                            width: parent.width * Math.min(1, root.audio.osdPercentage / 150)
                            height: parent.height
                            radius: parent.radius
                            color: root.audio.osdMuted ? root.theme.red : (root.audio.osdPercentage > 100 ? root.theme.orange : root.theme.green)
                        }
                    }
                }
            }
        }
    }
}
