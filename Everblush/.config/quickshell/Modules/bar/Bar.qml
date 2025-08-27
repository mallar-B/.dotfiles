import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Wayland
import "components"
import qs.Common

PanelWindow{
	Component.onCompleted: {
		if (this.WlrLayershell != null) {
		this.WlrLayershell.layer = WlrLayer.Top;
		this.WlrLayershell.namespace = "bar";
		}
	}
	anchors{
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

	Rectangle{
		anchors.fill: parent
		radius: 0
		color: Theme.background_primary

		DateTime {}
		Workspaces {}
	}
}
