import QtQuick
import Quickshell
import Quickshell.Widgets

Column {
    id: root

    required property var theme
    required property var menu

    property int itemHeight: 30

    signal triggered

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Repeater {
        model: opener.children

        delegate: Item {
            id: menuItem

            required property var modelData
            property var entry: modelData

            width: root.width
            height: entry.isSeparator ? 7 : root.itemHeight

            Rectangle {
                visible: menuItem.entry.isSeparator

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 5
                    rightMargin: 5
                }

                height: 1
                color: root.theme.bg2
            }

            Rectangle {
                anchors.fill: parent

                visible: !menuItem.entry.isSeparator
                radius: root.theme.radius

                color: itemMouse.containsMouse && menuItem.entry.enabled ? root.theme.bg2 : "transparent"

                opacity: menuItem.entry.enabled ? 1 : 0.45

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 8
                        rightMargin: 8
                    }

                    spacing: 7

                    Item {
                        width: 16
                        height: parent.height

                        Text {
                            anchors.centerIn: parent

                            visible: menuItem.entry.buttonType !== QsMenuButtonType.None

                            text: menuItem.entry.checkState === Qt.Checked ? "✓" : ""

                            color: root.theme.grey1
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textSize
                        }
                    }

                    IconImage {
                        anchors.verticalCenter: parent.verticalCenter

                        width: 16
                        height: 16

                        visible: menuItem.entry.icon && menuItem.entry.icon.length > 0

                        source: menuItem.entry.icon
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        width: parent.width - x - submenuArrow.width - 6

                        text: menuItem.entry.text
                        color: root.theme.grey1

                        elide: Text.ElideRight

                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize
                    }

                    Text {
                        id: submenuArrow

                        anchors.verticalCenter: parent.verticalCenter

                        width: 12

                        visible: menuItem.entry.hasChildren
                        text: "›"

                        color: root.theme.grey1

                        horizontalAlignment: Text.AlignRight

                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize + 2
                    }
                }

                MouseArea {
                    id: itemMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    enabled: menuItem.entry.enabled && !menuItem.entry.isSeparator

                    onClicked: {
                        if (menuItem.entry.hasChildren) {
                            submenuPopup.visible = !submenuPopup.visible;
                        } else {
                            menuItem.entry.triggered();
                            root.triggered();
                        }
                    }
                }
            }

            PopupWindow {
                id: submenuPopup

                visible: false

                anchor {
                    item: menuItem
                    edges: Edges.Right
                    gravity: Edges.Right

                    adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
                }

                implicitWidth: 220
                implicitHeight: submenuLoader.item ? submenuLoader.item.implicitHeight + 8 : 8

                Rectangle {
                    anchors.fill: parent

                    color: root.theme.bg0
                    radius: root.theme.radius

                    border.width: 1
                    border.color: root.theme.bg2

                    BoundComponent {
                        id: submenuLoader

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 4
                        }

                        source: Qt.resolvedUrl("TrayMenuContent.qml")

                        property var theme: root.theme
                        property var menu: menuItem.entry

                        function onTriggered() {
                            submenuPopup.visible = false;
                            root.triggered();
                        }
                    }
                }
            }
        }
    }
}
