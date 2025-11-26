import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.Common

WrapperRectangle {
	id: sysTrayRect

	property var barRef
	property var tooltipWindow: PopupMenu{ popupAnchor: sysTrayRect.barRef }
	property double hPadding: 12
	property double vPadding: 3

	anchors.verticalCenter: parent.verticalCenter
	anchors.rightMargin: 10
	anchors.right: parent.right
	implicitWidth: row.implicitWidth + (hPadding * 2)
	implicitHeight: row.implicitHeight + (vPadding * 2)

	color: Theme.dark_gray
	radius: 15

	RowLayout {
		id:row

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: sysTrayRect.hPadding
		anchors.rightMargin: sysTrayRect.hPadding
		spacing: 10

		Repeater {
			model: SystemTray.items

			delegate: Rectangle {
				id: systrayIcon

				height: childrenRect.height
				width: childrenRect.width
				color: "transparent"
				visible: modelData.status ?? false

				Image {
					source: modelData.icon
					height: 20
					width: 20
				}

				MouseArea {
					id: hoverArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor

					onEntered: {
						// console.log(tooltipWindow.anchor.rect.x,tooltipWindow.anchor.rect.y)
						if (!sysTrayRect.tooltipWindow || !sysTrayRect.barRef) return

						sysTrayRect.tooltipWindow.title = modelData.tooltipTitle || modelData.title || ""
						sysTrayRect.tooltipWindow.description = modelData.tooltipDescription || ""

						// Position: center under the icon, in barRef's coordinates
						var p = systrayIcon.mapToItem(
							sysTrayRect.barRef.contentItem,
							systrayIcon.width / 2,
							systrayIcon.height
						)

						// Use callLater so popup.width/height are updated after text changes
						Qt.callLater(function() {
							// X: center horizontally under icon
							sysTrayRect.tooltipWindow.anchor.rect.x = Math.round(p.x - sysTrayRect.tooltipWindow.width / 2)

							// Y: just under the bar (barRef anchors top, so height is its bottom)
							sysTrayRect.tooltipWindow.anchor.rect.y = sysTrayRect.barRef.height

							sysTrayRect.tooltipWindow.visible = true
						})
					}

					onExited: {
						if (sysTrayRect.tooltipWindow) sysTrayRect.tooltipWindow.visible = false
					}

					onClicked: function(mouse) {
						if (mouse.button === Qt.LeftButton && modelData.activate) {
							modelData.activate()
						} else if (mouse.button === Qt.RightButton) {
							// TODO: Add menu support
								if (sysTrayRect.tooltipWindow)
									sysTrayRect.tooltipWindow.visible = true
						}
					}
				}
			}
		}
	}
}
