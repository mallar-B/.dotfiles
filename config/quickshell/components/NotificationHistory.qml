import QtQuick
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root

    required property var theme
    required property var notifications
    required property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Right | Edges.Top
    anchor.gravity: Edges.Right | Edges.Bottom
    anchor.margins.left: 10
    grabFocus: true
    color: "transparent"
    implicitWidth: 400
    implicitHeight: 500

    function iconSource(icon) {
        if (!icon)
            return "";

        const value = String(icon);
        if (value.startsWith("/") || value.startsWith("file:") || value.startsWith("image:"))
            return value;

        return Quickshell.iconPath(value, true);
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius + 2
        color: root.theme.bg0
        border.width: 1
        border.color: root.theme.bg3

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Row {
                width: parent.width
                height: 32

                Text {
                    width: parent.width - 68
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifications"
                    color: root.theme.fg
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textSize + 1
                    font.bold: true
                }

                Rectangle {
                    width: 68
                    height: 32
                    radius: root.theme.radius
                    color: clearMouse.containsMouse ? root.theme.bg2 : root.theme.bg1

                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        color: root.theme.grey1
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.smallTextSize
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.notifications.clearHistory()
                    }
                }
            }

            ListView {
                id: historyList
                width: parent.width
                height: parent.height - 42
                model: root.notifications.history
                clip: true
                spacing: 7

                delegate: Rectangle {
                    required property string appName
                    required property string summary
                    required property string body
                    required property string icon
                    required property string time

                    width: ListView.view.width
                    height: historyContent.implicitHeight + 20
                    radius: root.theme.radius
                    color: root.theme.bg1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Item {
                            width: 30
                            height: 30

                            IconImage {
                                id: historyIcon
                                anchors.centerIn: parent
                                implicitSize: 26
                                source: root.iconSource(icon)
                                visible: source.toString().length > 0
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !historyIcon.visible
                                text: "•"
                                color: root.theme.aqua
                                font.pixelSize: 22
                            }
                        }

                        Column {
                            id: historyContent
                            width: parent.width - 40
                            spacing: 4

                            Row {
                                width: parent.width

                                Text {
                                    width: parent.width - 48
                                    text: appName
                                    color: root.theme.green
                                    elide: Text.ElideRight
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }

                                Text {
                                    width: 48
                                    text: time
                                    color: root.theme.grey0
                                    horizontalAlignment: Text.AlignRight
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }
                            }

                            Text {
                                width: parent.width
                                text: summary
                                color: root.theme.fg
                                wrapMode: Text.Wrap
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.textSize
                                font.bold: true
                            }

                            Text {
                                width: parent.width
                                text: body
                                visible: text.length > 0
                                color: root.theme.grey1
                                textFormat: Text.PlainText
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: historyList.count === 0
                    text: "No notifications"
                    color: root.theme.grey0
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textSize
                }
            }
        }
    }
}
