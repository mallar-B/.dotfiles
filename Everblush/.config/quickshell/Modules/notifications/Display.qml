import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications
import qs.Common

Item {
  id: root
  required property Notification notif

  implicitWidth: 400
  implicitHeight: 122

  // Vertical container for notifications
  Column {
    id: layout
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 0

    // Notification container
    Rectangle {
      // color: Theme.background_secondary
      gradient: Gradient {
        GradientStop { position: 0.7; color: Theme.background_primary }
        GradientStop { position: 1.0; color: Theme.background_secondary }
      }

      anchors.left: parent.left
      anchors.right: parent.right
      implicitHeight: textColumn.implicitHeight
      radius: 13
      height: root.height
      width: root.width
      border.color: Theme.gray

      Row {
        id: contentRow
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Icon container
        Rectangle {
          id: iconContainer
          visible: !!notif.image
          width: 54
          height: 54
          anchors.margins: 10

          Image {
            anchors.fill: parent
            source: notif.image
            fillMode: Image.PreserveAspectCrop
            smooth: true
          }
        }
        // Text content column
        Column {
          id: textColumn
          spacing: 10
          width: notif.image ? parent.width - iconContainer.width : parent.width

          // Notification title
          Label {
            width: parent.width
            text: root.notif?.summary
            font.family: "Monaspace Krypton Frozen"
            font.pointSize: 18
            font.bold: true
            wrapMode: Text.Wrap
            color: Theme.purple
            maximumLineCount: 1
            elide: Text.ElideRight
          }

          // Notification body
          Text {
            width: parent.width
            text: root.notif?.body
            font.family: "Monaspace Radon Frozen"
            font.pointSize: 12
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Theme.foreground_primary
            maximumLineCount: 3
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
