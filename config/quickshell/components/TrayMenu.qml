import QtQuick
import Quickshell

PopupWindow {
    id: popup

    required property var theme
    required property var menu
    required property Item anchorItem

    property int menuWidth: 220

    anchor {
        item: popup.anchorItem
        edges: Edges.Right
        gravity: Edges.Right
        adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
    }

    implicitWidth: menuWidth
    implicitHeight: menuContent.implicitHeight + 8

    grabFocus: true

    Rectangle {
        anchors.fill: parent
        color: popup.theme.bg0
        radius: popup.theme.radius

        border.width: 1
        border.color: popup.theme.bg2

        TrayMenuContent {
            id: menuContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 4
            }

            theme: popup.theme
            menu: popup.menu

            onTriggered: popup.visible = false
        }
    }
}
