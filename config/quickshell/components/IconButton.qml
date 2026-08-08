import QtQuick

Rectangle {
    id: root

    required property var theme
    property string label: ""
    property color labelColor: theme.fg
    property bool active: false
    property bool danger: false
    property int labelSize: theme.iconSize

    signal clicked
    signal rightClicked
    signal wheelUp
    signal wheelDown

    implicitWidth: theme.buttonWidth
    implicitHeight: theme.buttonHeight
    radius: theme.radius
    color: active ? theme.bgGreen : (mouseArea.containsMouse ? theme.bg2 : "transparent")
    border.width: active ? 1 : 0
    border.color: danger ? theme.red : theme.green

    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.danger ? root.theme.red : root.labelColor
        font.family: root.theme.fontFamily
        font.pixelSize: root.labelSize
        font.weight: root.active ? Font.DemiBold : Font.Normal
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }

        onWheel: event => {
            if (event.angleDelta.y > 0)
                root.wheelUp();
            else if (event.angleDelta.y < 0)
                root.wheelDown();
        }
    }
}
