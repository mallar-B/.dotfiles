import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "components"
import "components/systray"
import qs.Common

PanelWindow {
	id: root

	Component.onCompleted: {
		if (this.WlrLayershell != null) {
		this.WlrLayershell.layer = WlrLayer.Top;
		this.WlrLayershell.namespace = "bar";
		}
	}
	anchors {
		top: true
		left: true
		right: true
	}
	implicitHeight: (screen.height / 100) * 3 // 3% of screen height
	color: "transparent"
	// margins{
	// 	top: 5
	// 	left: 10
	// 	right: 10
	// }

	// TODO: change this whole to rowlayout
	Rectangle {
		anchors.fill: parent
		radius: 0
		// color: Theme.background_primary
		color: Theme.background_primary

		// Bottom border
		Rectangle {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			height: 1
			color: Theme.dark_gray
		}

		DateTime {
			id:datetime
		}
		Workspaces {}
		RowLayout{
			anchors.right: parent.right
			anchors.left: datetime.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.rightMargin: 10

			height: parent.height

			VolumeControl{
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
			SysTray{
				Layout.alignment: Qt.AlignRight
				barRef: root
			}

		}
	}
}
