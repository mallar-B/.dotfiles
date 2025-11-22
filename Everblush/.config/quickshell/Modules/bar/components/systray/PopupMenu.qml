import QtQuick
import Quickshell
import qs.Common

PopupWindow {
	id: popup

	property var popupAnchor

	property string title: ""
	property string description: ""

	property color backgroundColor: Theme.background_secondary
	property color borderColor: Theme.light_gray
	property color titleColor: "white"
	property color descriptionColor: Theme.foreground_secondary
	property int maxTextWidth: 100
	color: "transparent"

	anchor.window: popupAnchor

	implicitWidth: background.implicitWidth
	implicitHeight: background.implicitHeight

	Rectangle {
		id: background
		anchors.fill: parent
		color: popup.backgroundColor
		radius: 10
		border.color: popup.borderColor

		implicitWidth: Math.max(
			titleText.visible ? titleText.implicitWidth : 0,
			descText.visible ? descText.implicitWidth : 0
		) + 16
		implicitHeight: (titleText.visible ? titleText.implicitHeight : 0)
		+ (descText.visible ? descText.implicitHeight
		+ (titleText.visible ? 6 : 0) : 0)
		+ 10

		Column {
			anchors.fill: parent
			anchors.margins: 6
			spacing: 2

			Text {
				id: titleText
				text: popup.title
				color: popup.titleColor
				font.bold: true
				visible: text.length > 0
				elide: Text.ElideRight
				wrapMode: Text.NoWrap
			}

			Text {
				id: descText
				text: popup.description
				color: popup.descriptionColor
				visible: text.length > 0
				wrapMode: Text.Wrap
				width: popup.maxTextWidth
			}
		}
	}
}
