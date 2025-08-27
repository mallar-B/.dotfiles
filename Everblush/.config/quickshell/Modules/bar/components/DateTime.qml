import QtQuick
import Quickshell.Io
import Quickshell.Widgets
import qs.Common

WrapperRectangle{ // Rectangle is starting from the center so not properly aligning
	// anchors.centerIn: parent
	anchors.horizontalCenter: parent.horizontalCenter
	topMargin: 5
	color: "#00000000"
	Text{
		id: clock
		color: Theme.foreground_primary
		// font.family: "Fira Code Nerd Font Mono"
		font.family: "GohuFont 11 Nerd Font"
		// font.family: "Digital-7"
		
		font.bold: true
		font.pointSize: 14

		Process {
		id: dateProc
		command: ["date", "+%b %d ▪ %H:%M"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: clock.text = this.text.trim()
		}
		}

		Timer{
			interval:1000
			running:true
			repeat:true
			onTriggered: dateProc.running = true
		}

	}
}
