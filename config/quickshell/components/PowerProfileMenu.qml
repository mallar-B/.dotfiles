import QtQuick
import Quickshell
import Quickshell.Services.UPower

PopupWindow {
    id: root

    required property var theme
    required property Item anchorItem
    required property var notifications

    property int pendingProfile: -1
    property string pendingProfileLabel: ""

    anchor.item: anchorItem
    anchor.edges: Edges.Right
    anchor.gravity: Edges.Right
    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
    anchor.margins.left: 10

    grabFocus: true
    color: "transparent"
    implicitWidth: 210
    implicitHeight: profileColumn.implicitHeight + 20

    function selectProfile(profile, label) {
        root.pendingProfile = profile;
        root.pendingProfileLabel = label;

        try {
            PowerProfiles.profile = profile;
            profileVerifyTimer.restart();
        } catch (error) {
            root.pendingProfile = -1;
            root.notifications.showLocal("Power profile unavailable", "Could not switch to " + label + ". Make sure power-profiles-daemon is installed and running.", "dialog-warning");
        }

        visible = false;
    }

    Timer {
        id: profileVerifyTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (root.pendingProfile >= 0 && PowerProfiles.profile !== root.pendingProfile) {
                root.notifications.showLocal("Power profile change failed", "The system did not switch to " + root.pendingProfileLabel + ". Check that power-profiles-daemon is available.", "dialog-warning");
            }

            root.pendingProfile = -1;
            root.pendingProfileLabel = "";
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius + 2
        color: root.theme.bg0
        border.width: 1
        border.color: root.theme.bg3

        Column {
            id: profileColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Repeater {
                model: [
                    {
                        "label": "Power saver",
                        "description": "Lower power use",
                        "icon": "\uf06c",
                        "profile": PowerProfile.PowerSaver,
                        "enabled": true
                    },
                    {
                        "label": "Balanced",
                        "description": "Default balance",
                        "icon": "\uf24e",
                        "profile": PowerProfile.Balanced,
                        "enabled": true
                    },
                    {
                        "label": "Performance",
                        "description": PowerProfiles.hasPerformanceProfile ? "Maximum performance" : "Not available",
                        "icon": "\uf0e7",
                        "profile": PowerProfile.Performance,
                        "enabled": PowerProfiles.hasPerformanceProfile
                    }
                ]

                delegate: Rectangle {
                    id: profileRow

                    required property var modelData

                    readonly property bool selected: PowerProfiles.profile === modelData.profile

                    width: profileColumn.width
                    height: 46
                    radius: root.theme.radius
                    opacity: modelData.enabled ? 1.0 : 0.42
                    color: selected ? root.theme.bgGreen : (profileMouse.containsMouse && modelData.enabled ? root.theme.bg2 : "transparent")
                    border.width: selected ? 1 : 0
                    border.color: root.theme.green

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        horizontalAlignment: Text.AlignHCenter
                        text: profileRow.modelData.icon
                        color: profileRow.selected ? root.theme.green : root.theme.fg
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.iconSize - 2
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 44
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Text {
                            text: profileRow.modelData.label
                            color: profileRow.selected ? root.theme.green : root.theme.fg
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textSize
                            font.weight: profileRow.selected ? Font.DemiBold : Font.Normal
                        }

                        Text {
                            text: profileRow.modelData.description
                            color: root.theme.grey1
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.smallTextSize
                        }
                    }

                    MouseArea {
                        id: profileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: profileRow.modelData.enabled
                        onClicked: root.selectProfile(profileRow.modelData.profile, profileRow.modelData.label)
                    }
                }
            }
        }
    }
}
