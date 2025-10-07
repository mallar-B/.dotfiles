import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Common

PanelWindow{
	id: backdropWindow
	property int openAnimDuration
	property int closeAnimDuration
	property var closeWindowFunc

	visible: false
	color: "transparent"
	anchors{
		top: true
		right: true
		bottom: true
		left: true
	}

	function show(){
		backdropWindow.visible = true
		showBackdrop.start()
	}
	function hide(){
		hideBackdrop.start()
	}

	Component.onCompleted: {
		if (this.WlrLayershell != null) {
		this.WlrLayershell.layer = WlrLayer.Top;
		this.WlrLayershell.namespace = "backdrop";
		this.WlrLayershell.keyboardFocus= "None";
		}
	}

	// Main backdrop
	Rectangle{
		id: backdropWrapper
		anchors.fill: parent
		color: Qt.rgba(0, 0, 0, 0.4)
	}

	MouseArea{
		anchors.fill: parent
		onClicked: {
			// Clicking outside window closes both
			closeWindowFunc()
		}
	}

	PropertyAnimation{
		id: showBackdrop
		target: backdropWrapper
		property: "opacity"
		from: 0
		to: 1
		duration: openAnimDuration || Anim.durations.normal
	}
	PropertyAnimation{
		id: hideBackdrop
		target: backdropWrapper
		property: "opacity"
		from: 1
		to: 0
		duration: closeAnimDuration || Anim.durations.normal
		onStopped: backdropWindow.visible = false
	}
}
