import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.Common

PanelWindow {
	id: powermenu
	property var barRef

	anchors {
		right: true
		top: true
	}

	exclusionMode: "Ignore"

	property int diameter: 500

	implicitWidth: diameter / 2
	implicitHeight: diameter
	margins.top: barRef.height + 10

	color: "transparent"

	focusable: true

	// Powermenu actions
	property var actions: [
		{ label: "Lock", command: "hyprlock", icon: "system-lock-screen" },
		{ label: "Logout", command: "hyprctl dispatch exit", icon: "system-log-out" },
		{ label: "Sleep", command: "systemctl suspend", icon: "system-suspend" },
		{ label: "Reboot", command: "systemctl reboot", icon: "system-reboot" },
		{ label: "Poweroff", command: "systemctl poweroff", icon: "system-shutdown-symbolic" }
	]

	// Full circle background, only the left half is visible inside the window
	Rectangle {
		id: circle
		width: powermenu.diameter
		height: powermenu.diameter
		radius: width / 2

		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left

		color: Theme.background_primary
		border.color: Theme.dark_gray
	}

	// arc layout of buttons along the circle
	Repeater {
		model: powermenu.actions.length * 2

		delegate: Item {
			id: slot

			width: 80
			height: 80

			// Angle span along the visible (left) half of the circle
			// 0° = right, 90° = up, 180° = left, 270° = down
			// property real startAngle: 110
			// property real endAngle:   250
			property real startAngle: 105
			property real endAngle:   250

			property real t: powermenu.actions.length > 1
				? index / (powermenu.actions.length - 1)
				: 0.5

			property real angleDeg: startAngle + (endAngle - startAngle) * t
			property real angleRad: angleDeg * Math.PI / 180

			// Keep buttons slightly inside the edge of the circle
			property real r: powermenu.diameter * 0.38

			readonly property real cx: circle.x + circle.width  / 2
			readonly property real cy: circle.y + circle.height / 2

			// Convert polar -> Cartesian (Qt y-axis goes down)
			x: cx + r * Math.cos(angleRad) - width  / 2
			y: cy - r * Math.sin(angleRad) - height / 2

			// Button bubble
			Rectangle {
				id: bubble
				anchors.centerIn: parent
				width: parent.width
				height: parent.height
				radius: width / 2

				color: mouseArea.pressed
					? Theme.gray
					: (mouseArea.containsMouse ? Theme.dark_gray : Theme.background_secondary)

				border.color: Theme.gray

				Column {
					anchors.centerIn: parent
					spacing: 2

					IconImage {
						width: 28
						height: 28
						source: powermenu.actions[index % 5].icon
						mipmap: true
					}

					Text {
						text: powermenu.actions[index%5].label
						color: "white"
						font.pixelSize: 11
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						elide: Text.ElideRight
					}
				}

				MouseArea {
					id: mouseArea
					anchors.fill: parent
					hoverEnabled: true

					onClicked: {
						Quickshell.execDetached({command: ["sh", "-c", powermenu.actions[index].command]})
					}
				}
			}
		}
	}
}
