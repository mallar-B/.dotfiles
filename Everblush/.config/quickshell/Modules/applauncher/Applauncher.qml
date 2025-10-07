import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Common

PanelWindow {
	id: applauncherWindow
	visible: false
	implicitHeight: 450
	implicitWidth: 670
	color: "transparent"

	property bool isClosing: false
	property bool isOpening: false
	function toggleApplauncher(){
		if(applauncherWindow.visible){
			isClosing = true
			stopAnimation.start()
		} else if(!applauncherWindow.visible){
			isOpening = true
			applauncherWindow.visible = true
			backdropWindow.show()
		}
	}

	Backdrop{
		id: backdropWindow
		openAnimDuration: Anim.durations.normal
		closeAnimDuration: Anim.durations.expressiveEffects
		closeWindowFunc: toggleApplauncher
	}

	Timer{
		id: stopAnimation
		interval: Anim.durations.normal // same as mainContainer's width
		running: false
		repeat: false
		onTriggered:{
			backdropWindow.hide()
			applauncherWindow.visible = false
			isClosing = false
			isOpening = false
		}
	}

	function launchApp(app) {
		if (!app) return
		// Desktop apps
		if(!app.runInTerminal){
			Quickshell.execDetached({ command: app.command, workingDirectory: app.workingDirectory })
		}
		// Terminal apps
		else{
			if(app.command.length){
				Quickshell.execDetached(["bash","-c","$TERM" + " " + app.command[0]])
			} else{
				Quickshell.execDetached(["bash","-c","$TERM" + " " + app.execString]) // Fallback
			}
		}
		// After launching close the window and rest query
		toggleApplauncher()
		searchbox.text = ""
		resultsList.currentIndex = 0 // remove selection
	}

	Component.onCompleted: {
		if (this.WlrLayershell != null) {
		this.WlrLayershell.layer = WlrLayer.Overlay;
		this.WlrLayershell.namespace = "applauncher";
		this.WlrLayershell.keyboardFocus= "OnDemand"
		}
	}

	// To make it work with hyprland.
	// e.g. bind = $mainMod, Space, global, quickshell:toggleApplauncher
	GlobalShortcut{
		name: "toggleApplauncher"
		description: "toggles applauncher"
		onPressed: toggleApplauncher()
	}

	// Main container
	Rectangle {
		id: mainContainer
		anchors.top: parent.top
		width: applauncherWindow.visible && !isClosing ? parent.width : 0
		height: searchbox.text === "" ? childrenRect.height + 15 : childrenRect.height + 40
		radius: isClosing ? 5  : isOpening ? (searchbox.text === "" ? 30 : 20) : 5
		color: searchbox.text === "" ? Theme.background_primary : Theme.background_primary
		border.width: applauncherWindow.visible ? 1 : 0
		border.color: searchbox.text === "" ? Theme.gray : Theme.dark_gray
		clip: true

		ColumnLayout {
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.margins: searchbox.text === "" ? 10 : 20

			// Search input container
			Rectangle {
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.preferredHeight: 40
				radius: 7
				color: searchbox.text === "" ? Theme.background_primary : Theme.background_secondary
				border.color: searchbox.activeFocus? Theme.blue : Theme.dark_gray
				border.width: searchbox.text === ""
				? 0 : searchbox.activeFocus ? 1 : 2

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 15
					anchors.rightMargin: 15

					// Search icon
					Text {
						text: ""
						font.pixelSize: searchbox.text === "" ? 22 : 18
						font.bold: true
						color: Theme.foreground_secondary

						Behavior on font.pixelSize{
							NumberAnimation {
								duration: Anim.durations.normal
								easing.type: Easing.Bezier
								easing.bezierCurve: Anim.curves.expressiveEffects
							}
						}
					}

					// Search input field
					TextField {
						id: searchbox
						activeFocusOnTab: true
						Layout.fillWidth: true
						Layout.fillHeight: true
						font.pixelSize: 17
						font.family: "FiraCode Nerd Font"
						color: Theme.foreground_primary
						placeholderText: "Froglight Search" // I like minecraft
						placeholderTextColor: Theme.gray
						// Remove default background
						background: Rectangle {
								color: "transparent"
						}
						// Text selection color in input box
						selectionColor: Theme.accent
						selectedTextColor: Theme.teal

						onAccepted: {
							if (searchbox.text === "") return // don't launch the first app because its not showing in UI
							if (resultsList.currentIndex >= 0 && resultsList.currentIndex < searcher.resultsModel.count) {
								launchApp(searcher.resultsModel.get(resultsList.currentIndex).app)
							}
						}
						onTextEdited: {
							searcher.searchApps(text)
						}

						Keys.onPressed: (event) => {
							if(!applauncherWindow.visible) return
							// Keybinds
							if (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier) {
								if (resultsList.currentIndex < searcher.resultsModel.count - 1) {
									resultsList.currentIndex++
								}
								event.accepted = true // So it does not propagate to parents
							} else if (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier) {
								if (resultsList.currentIndex > 0) {
									resultsList.currentIndex--
								}
								event.accepted = true
							} else if (event.key === Qt.Key_Down) {
								if (resultsList.currentIndex < searcher.resultsModel.count - 1) {
									resultsList.currentIndex++
								}
								event.accepted = true
							} else if (event.key === Qt.Key_Up) {
								if (resultsList.currentIndex > 0) {
									resultsList.currentIndex--
								}
								event.accepted = true
							} else if (event.key === Qt.Key_Escape) {
								toggleApplauncher() // close window with animations
								searchbox.text = "" // reset query
								resultsList.currentIndex = 0 // remove selection
								event.accepted = true
							}
						}

						Behavior on font.pixelSize{
							NumberAnimation {
								duration: Anim.durations.normal
								easing.type: Easing.Bezier
								easing.bezierCurve: Anim.curves.expressiveEffects
							}
						}
					}

					// Clear button
					MouseArea {
						id: cancelButton
						Layout.preferredWidth: 20
						Layout.preferredHeight: 20
						visible: searchbox.text.length > 0
						cursorShape: Qt.PointingHandCursor
						hoverEnabled: true

						onClicked: {
							searchbox.text = ""
						}

						Rectangle {
							anchors.fill: parent
							width: 16
							height: 16
							// radius: 8
							// color: parent.containsMouse ? "#CCCCCC" : "#AAAAAA"
							color: "transparent"

							Text {
								anchors.centerIn: parent
								text: ""
								color: parent.parent.containsMouse ? Theme.light_red : Theme.red
								font.pixelSize: 18
							}
						}
					}
				}

				Behavior on color{
					ColorAnimation {
						duration: Anim.durations.expressiveFastSpatial
						easing.type: Easing.Bezier
						easing.bezierCurve: Anim.curves.expressiveEffects
					}
				}

				Behavior on border.color{
					ColorAnimation {
						duration: Anim.durations.expressiveFastSpatial
						easing.type: Easing.Bezier
						easing.bezierCurve: Anim.curves.expressiveEffects
					}
				}
			}

			// Results list
			AppSearcher{
				id:searcher
				searchText: searchbox.text
			}
			Rectangle {
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.preferredHeight: {
					if (searchbox.text === "") return 0
					const itemHeight = 60
					const spacing = 10
					const maxVisibleItems = 5
					const resultCount = searcher.resultsModel.count
					const visibleItems = Math.min(resultCount, maxVisibleItems)
					return visibleItems > 0 ? (visibleItems * itemHeight) + ((visibleItems - 1) * spacing) : 100
				}
				Layout.maximumHeight: 400
				radius: 8
				color: "transparent"
				clip: true

				ListView {
					id: resultsList
					anchors.fill: parent
					model: searcher.resultsModel
					spacing: 10
					currentIndex: 0
					highlightMoveDuration: 150

					delegate: Rectangle {
						width: resultsList.width
						height: 60
						color: resultsList.currentIndex === index
						? Theme.light_blue : listButton.containsMouse
						? Theme.muted_blue : Theme.muted_gray
						radius: 7

						MouseArea {
							id:listButton
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onClicked: resultsList.currentIndex = index
							onDoubleClicked: launchApp(model.app)
						}

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: 12
							anchors.rightMargin: 12
							spacing: 12

							// App icon placeholder
							Rectangle {
								Layout.preferredWidth: 50
								Layout.preferredHeight: 50
								color: "transparent"

								IconImage {
									anchors.fill: parent
									source: Quickshell.iconPath(model.icon, true)
									mipmap: true
								}
							}

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 5

								// Selected App name
								Text {
									// Layout.fillWidth: true
									text: model.name.charAt(0).toUpperCase() + model.name.slice(1)
									// font.family: "Telegrama"
									font.family: "Monoflow"
									font.pixelSize: 18
									font.weight: resultsList.currentIndex === index ? Font.Bold : Font.Medium
									color: resultsList.currentIndex === index ? Theme.background_primary : Theme.foreground_primary
									elide: Text.ElideRight
								}
								// Selected App desc.
								Text {
									Layout.fillWidth: true
									text: model.description
										? model.description : model.genericName
										? model.genericName : "no description available"
									font.family: "FiraCode Nerd Font"
									font.pixelSize: 13
									color: resultsList.currentIndex === index ? Theme.dark_gray : Theme.light_gray
									elide: Text.ElideRight
								}
							}
						}
					}

					// Custom scrollbar
					ScrollBar.vertical: ScrollBar {
						visible: !(searcher.resultsModel.count === 0 && searchbox.text.length > 0)
						policy: "AsNeeded"

						contentItem: Rectangle {
							implicitWidth: 6
							radius: 3
							color: Theme.dark_gray
							opacity: parent.active ? 1 : 0.9
						}
					}
				}

				// Empty state
				Text {
					anchors.centerIn: parent
					visible: searcher.resultsModel.count === 0 && searchbox.text.length > 0
					text: "No applications found"
					font.pixelSize: 16
					color: Theme.light_gray
				}
			}

			Behavior on anchors.margins{
				NumberAnimation {
					duration: Anim.durations.normal
					easing.type: Easing.Bezier
					easing.bezierCurve: Anim.curves.expressiveEffects
				}
			}
		}

		Behavior on height{
			NumberAnimation {
				duration: Anim.durations.normal
				easing.type: Easing.Bezier
				easing.bezierCurve: Anim.curves.expressiveEffects
			}
		}

		Behavior on width{
			NumberAnimation {
				duration: Anim.durations.normal
				easing.type: Easing.Bezier
				easing.bezierCurve: Anim.curves.expressiveEffects
			}
		}

		Behavior on color{
			ColorAnimation {
				duration: Anim.durations.normal
				easing.type: Easing.Bezier
				easing.bezierCurve: Anim.curves.expressiveEffects
			}
		}

		Behavior on radius{
			NumberAnimation{
				duration: Anim.durations.normal
				easing.type: Easing.Bezier
				easing.bezierCurve: Anim.curves.expressiveEffects
			}
		}

	}

	onVisibleChanged: {
		if (visible) {
			searchbox.forceActiveFocus() // Trigger imput focus on panelwindow visible
		}
	}

	// Dynamic mouse area to simulate
	// like clicking on bckdrop
	MouseArea{
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: applauncherWindow.height - mainContainer.height
		onClicked: toggleApplauncher()
	}
}
