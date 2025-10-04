import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import qs.Common

Rectangle{
	anchors.verticalCenter: parent.verticalCenter
	anchors.leftMargin: 10 // Align with hyprland window
	anchors.left: parent.left

	property var workspaces: Hyprland.workspaces.values // Raw datas as list

	function isWorkspaceEmpty(idx){
		for(let i=0; i<workspaces.length; i++){
			if(idx === workspaces[i].id) return false
		}
		return true
	}

	function isWorkspaceFullscreen(idx){
		for(let i=0; i<workspaces.length; i++){
			if(idx === workspaces[i].id && workspaces[i].hasFullscreen){
				return true
			}
		}
		return false
	}

	Row{
		id: wss
		anchors.verticalCenter: parent.verticalCenter
		spacing: 7
		Repeater{
			// model: Hyprland.workspaces
			model: 10
			delegate: Rectangle { // delegate => template
				property int wsId: index + 1
				property bool isActive: (Hyprland && Hyprland.focusedWorkspace)
				? (wsId === Hyprland.focusedWorkspace.id)
				: false
				property var isEmpty: isWorkspaceEmpty(wsId)
				property bool isFullscreen: isWorkspaceFullscreen(wsId)
				radius: height / 2
				height: 10
				width: isActive ? 24 : 10
				color: isFullscreen 
					? Theme.green : isActive 
					? Theme.light_yellow : isEmpty
					? Theme.foreground_secondary : Theme.yellow
				MouseArea { // for each ws buttons
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						Hyprland.dispatch(`workspace ${wsId}`)
						print(workspaces[2].hasFullscreen)
					}
					// ToolTip.visible:
					ToolTip.text: `Workspace ${modelData.id} (${modelData.name})`
				}

				Behavior on width {
					NumberAnimation {
						duration: Anim.durations.expressiveEffects
						easing.type: Easing.Bezier
						easing.bezierCurve: Anim.curves.expressiveEffects
					}
				}

				Behavior on color {
					ColorAnimation {
						duration: Anim.durations.expressiveEffects
						easing.type: Easing.Bezier
						easing.bezierCurve: Anim.curves.expressiveEffects
					}
				}
			}
		}
	}

	MouseArea {
			anchors.fill: wss
			hoverEnabled: true
			acceptedButtons: Qt.NoButton   // Don’t consume clicks from the delegate
			cursorShape: Qt.PointingHandCursor
			propagateComposedEvents: true  // Let clicks through to delegates
			onWheel: (wheel) => {
				if (wheel.angleDelta.y > 0) {
					Hyprland.dispatch("workspace r-1")
				} else if (wheel.angleDelta.y < 0) {
					if(Hyprland.focusedWorkspace.id > 9) return // Max 10 ws
					Hyprland.dispatch("workspace r+1")
				}
			}
	}
}
