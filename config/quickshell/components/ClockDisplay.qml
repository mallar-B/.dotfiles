import QtQuick
import Quickshell

Item {
    id: root

    required property var theme

    implicitWidth: theme.buttonWidth
    implicitHeight: timeColumn.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        id: timeColumn
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH")
            color: root.theme.fg
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.textSize + 1
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "mm")
            color: root.theme.green
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.textSize + 1
            font.bold: true
        }
    }

    MouseArea {
        id: timeMouse
        anchors.fill: parent
        hoverEnabled: true
    }

    HoverTooltip {
        theme: root.theme
        anchorItem: root
        visible: timeMouse.containsMouse
        text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")
    }
}
