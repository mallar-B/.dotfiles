import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.Common

Scope {
	id: root
	property int volume: Math.round(Pipewire.defaultAudioSink.audio.volume * 100) // Making it 0-100 from 0-1
	property bool isMuted: Pipewire.defaultAudioSink.audio.muted

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			root.shouldShowOsd = true;
			hideTimer.restart();
		}
	}

	property string volumeLevel: root.isMuted ? "muted"
		: root.volume > 80 ? "overamplified"
		: root.volume > 50 ? "high"
		: root.volume > 30 ? "medium"
		: root.volume > 0 ? "low" : "muted"

	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 1500
		onTriggered: root.shouldShowOsd = false
	}

	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			anchors.bottom: true
			margins.bottom: screen.height / 7
			exclusiveZone: 0

			implicitWidth: 300
			implicitHeight: 50
			color: "transparent"

			// Main container
			Rectangle {
				anchors.fill: parent
				radius: 30
				color: Theme.background_secondary
				border.color: Theme.dark_gray

				// Icon and Slider container
				RowLayout {
					anchors {
						fill: parent
						leftMargin: 15
						rightMargin: 15
					}
					spacing: 10

					IconImage {
						implicitSize: 23
						// source: Quickshell.iconPath("audio-volume-high-symbolic")
						source: Quickshell.iconPath(`audio-volume-${root.volumeLevel}-symbolic`)
					}

				// Slider background
				Rectangle {
						id: slider
						property bool isHovering: false
						property bool isDragging: false

						Layout.fillWidth: true
						implicitHeight: isHovering || isDragging ? 10 : 5
						radius: 10
						color: Theme.dark_gray

						// Slider
						Rectangle {
							id: volumeLevel
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}

							color: slider.isHovering || slider.isDragging ? Theme.light_gray : Theme.gray
							width: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
							radius: parent.radius

							// Slider knob
							Rectangle {
								id: knob
								anchors.verticalCenter: parent.verticalCenter
								height: slider.isHovering || slider.isDragging ? 18 : 12
								width: height
								x: parent.width - width / 2
								color: slider.isHovering || slider.isDragging ? Theme.foreground_primary : Theme.foreground_secondary
								radius: parent.radius
							}
						}

						MouseArea {
							id: sliderArea
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor

							onHoveredChanged: () =>{
								slider.isHovering = containsMouse;
								if (containsMouse) hideTimer.stop();
								else hideTimer.restart();
							}

							onPressed: (mouse) =>{
								slider.isDragging = true;
								hideTimer.stop();
								let relativeX = Math.max(0, Math.min(mouse.x, slider.width));
								Pipewire.defaultAudioSink.audio.volume = relativeX / slider.width;
							}

							onPositionChanged: (mouse) =>{
								if (slider.isDragging) {
									let relativeX = Math.max(0, Math.min(mouse.x, slider.width));
									Pipewire.defaultAudioSink.audio.volume = relativeX / slider.width;
								}
							}

							onWheel: (wheel) => {
								const step = 0.05;
								let audio = Pipewire.defaultAudioSink.audio;
								if (!audio) return;

								let delta = wheel.angleDelta.y > 0 ? step : -step;
								audio.volume = Math.max(0, Math.min(1, audio.volume + delta));
								root.shouldShowOsd = true;
								hideTimer.restart();
							}

							onReleased: () =>{
								slider.isDragging = false;
								hideTimer.restart();
							}
						}
					}

					Text {
						color: Theme.foreground_primary
						text: root.isMuted ? "0%" : root.volume + "%"
            font.family: "Monaspace Krypton Frozen"
						font.pixelSize: 16
					}
				}
			}
		}
	}
}
