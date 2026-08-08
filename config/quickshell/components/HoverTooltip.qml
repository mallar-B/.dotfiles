import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var theme
    required property Item anchorItem
    property string text: ""

    anchor.item: anchorItem
    anchor.edges: Edges.Right | Edges.Top
    anchor.gravity: Edges.Right | Edges.Bottom
    anchor.margins.left: 10
    color: "transparent"
    implicitWidth: tooltipText.implicitWidth + 22
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: root.theme.bg1
        border.width: 1
        border.color: root.theme.bg3

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: root.text
            color: root.theme.fg
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.smallTextSize
        }
    }
}
