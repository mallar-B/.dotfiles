import QtQuick
import QtQuick.Layouts

Item {
    id: wrapper
    anchors.fill: parent

    Behavior on visible{
        NumberAnimation {
            duration: 10000
            easing.type: Easing.InOutQuad
        }
    }
}

