import Quickshell
import QtQuick

PanelWindow{
	visible: false
	anchors{
		top: true
		right: true
		bottom: true
		left: true
	}
	Component.onCompleted: {
		if (this.WlrLayershell != null) {
		this.WlrLayershell.layer = WlrLayer.Bottom;
		this.WlrLayershell.namespace = "backdrop";
		}
	}
	MouseArea{
		anchors.fill: parent
		onClicked: backdropLayer.visible = false
	}
}
