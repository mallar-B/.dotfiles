import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Variants {
    id: root

    required property var theme
    required property var notifications
    model: Quickshell.screens

    PanelWindow {
        id: toastWindow

        property var modelData
        screen: modelData
        visible: root.notifications.toastVisible && root.notifications.toastScreen === modelData
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 400
        implicitHeight: toastContent.implicitHeight

        anchors {
            top: true
            right: true
        }

        margins {
            top: 18
            right: 18
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "everforest-notification"

        function iconSource(icon) {
            if (!icon)
                return "";

            const value = String(icon);
            if (value.startsWith("/") || value.startsWith("file:") || value.startsWith("image:"))
                return value;

            return Quickshell.iconPath(value, true);
        }

        Rectangle {
            id: toastContent
            width: parent.width
            implicitHeight: toastLayout.implicitHeight + 26
            radius: root.theme.radius + 2
            color: root.theme.bg0
            border.width: 1
            border.color: root.theme.bg3

            Row {
                id: toastLayout
                anchors.fill: parent
                anchors.margins: 13
                spacing: 12

                Item {
                    width: 36
                    height: 36

                    IconImage {
                        id: toastIcon
                        anchors.centerIn: parent
                        implicitSize: 32
                        source: toastWindow.iconSource(root.notifications.toastIcon)
                        visible: source.toString().length > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !toastIcon.visible
                        text: "🔔"
                        color: root.theme.yellow
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.iconSize
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 4

                    Text {
                        width: parent.width
                        text: root.notifications.toastAppName
                        visible: text.length > 0
                        color: root.theme.green
                        elide: Text.ElideRight
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.smallTextSize
                    }

                    Text {
                        width: parent.width
                        text: root.notifications.toastSummary
                        color: root.theme.fg
                        wrapMode: Text.Wrap
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize + 1
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        text: root.notifications.toastBody
                        visible: text.length > 0
                        color: root.theme.grey1
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize - 1
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.notifications.closeToast(false)
            }
        }
    }
}
