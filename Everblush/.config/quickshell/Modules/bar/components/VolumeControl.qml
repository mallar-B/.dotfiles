import QtQuick
import Quickshell.Services.Pipewire

Item{
	MouseArea{
		anchors.fill: parent
		onWheel: (e) =>{
			Pipewire.defaultAudioSink.audio.volume += (e.angleDelta.y / 120) * 0.02
		}
	}
}
