pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: root

    required property var theme
    required property var context

    color: theme.bgDim

    function runPowerAction(command) {
        if (command && command.length > 0)
            Quickshell.execDetached(command);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Slightly layered background using only the existing Everforest palette.
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.72, 760)
        height: Math.min(parent.height * 0.64, 620)
        radius: root.theme.radius + 10
        color: root.theme.bg0
        border.width: 1
        border.color: root.theme.bg3
    }

    Column {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 520)
        spacing: 14

        IconImage {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitSize: 44
            source: Quickshell.iconPath("system-lock-screen-symbolic", true)
            visible: source.toString().length > 0
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: root.theme.fg
            font.family: root.theme.fontFamily
            font.pixelSize: 68
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")
            color: root.theme.grey1
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.textSize + 2
        }

        Item {
            width: 1
            height: 12
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.context.userName
            color: root.theme.green
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.textSize + 4
            font.weight: Font.DemiBold
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Rectangle {
                width: Math.min(390, root.width - 120)
                height: 48
                radius: root.theme.radius + 2
                color: root.theme.bg1
                border.width: passwordInput.activeFocus ? 1 : 0
                border.color: root.context.statusError ? root.theme.red : root.theme.green

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 13
                    enabled: !root.context.unlockInProgress
                    focus: true
                    clip: true
                    color: root.theme.fg
                    selectionColor: root.theme.bgGreen
                    selectedTextColor: root.theme.fg
                    echoMode: root.context.responseVisible ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "•"
                    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textSize + 2

                    onTextChanged: {
                        if (root.context.currentText !== text)
                            root.context.currentText = text;
                    }

                    onAccepted: root.context.tryUnlock()

                    Component.onCompleted: Qt.callLater(() => passwordInput.forceActiveFocus())
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 13
                    verticalAlignment: Text.AlignVCenter
                    visible: passwordInput.text.length === 0
                    text: root.context.responseVisible ? "Response" : "Password"
                    color: root.theme.grey0
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textSize + 2
                }

                Connections {
                    target: root.context

                    function onCurrentTextChanged() {
                        if (passwordInput.text !== root.context.currentText)
                            passwordInput.text = root.context.currentText;
                    }

                    function onClearInputs() {
                        passwordInput.clear();
                        Qt.callLater(() => passwordInput.forceActiveFocus());
                    }
                }
            }

            Rectangle {
                width: 48
                height: 48
                radius: root.theme.radius + 2
                color: unlockMouse.containsMouse ? root.theme.bgGreen : root.theme.bg1
                border.width: 1
                border.color: root.context.currentText.length > 0 ? root.theme.green : root.theme.bg3
                opacity: root.context.currentText.length > 0 && !root.context.unlockInProgress ? 1.0 : 0.55

                IconImage {
                    id: unlockIcon
                    anchors.centerIn: parent
                    implicitSize: 22
                    source: Quickshell.iconPath("go-next-symbolic", true)
                    visible: source.toString().length > 0
                }

                Text {
                    anchors.centerIn: parent
                    visible: !unlockIcon.visible
                    text: "→"
                    color: root.theme.fg
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.iconSize
                }

                MouseArea {
                    id: unlockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.context.currentText.length > 0 && !root.context.unlockInProgress
                    onClicked: root.context.tryUnlock()
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.context.unlockInProgress ? "Authenticating…" : (root.context.statusText.length > 0 && root.context.statusText ? root.context.statusText : "")
            color: root.context.statusError ? root.theme.red : root.theme.grey1
            wrapMode: Text.Wrap
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.smallTextSize + 1
        }

        Item {
            width: 1
            height: 6
        }

        // Session power actions, styled to match the unlock control above.
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            Repeater {
                model: [
                    { "icon": "system-suspend-symbolic", "fallback": "\uf186", "command": ["systemctl", "suspend"], "danger": false },
                    { "icon": "system-reboot-symbolic", "fallback": "\uf021", "command": ["systemctl", "reboot"], "danger": false },
                    { "icon": "system-shutdown-symbolic", "fallback": "\u23fb", "command": ["systemctl", "poweroff"], "danger": true }
                ]

                delegate: Rectangle {
                    id: powerAction
                    required property var modelData
                    width: 48
                    height: 48
                    radius: root.theme.radius + 2
                    color: powerMouse.containsMouse ? (modelData.danger ? root.theme.bgRed : root.theme.bg2) : root.theme.bg1
                    border.width: 1
                    border.color: powerMouse.containsMouse ? (modelData.danger ? root.theme.red : root.theme.green) : root.theme.bg3

                    IconImage {
                        id: powerIcon
                        anchors.centerIn: parent
                        implicitSize: 22
                        source: Quickshell.iconPath(powerAction.modelData.icon, true)
                        visible: source.toString().length > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !powerIcon.visible
                        text: powerAction.modelData.fallback
                        color: powerAction.modelData.danger
                            ? (powerMouse.containsMouse ? root.theme.red : root.theme.grey1)
                            : (powerMouse.containsMouse ? root.theme.green : root.theme.fg)
                        font.family: root.theme.fontFamily
                        font.pixelSize: 20
                    }

                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.runPowerAction(powerAction.modelData.command)
                    }
                }
            }
        }
    }
}
