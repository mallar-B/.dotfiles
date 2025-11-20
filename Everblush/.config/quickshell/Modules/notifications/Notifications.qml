import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Common

PanelWindow {
  id: root

  required property var barRef // For top margin
  property list<Notification> notifs

  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  Component.onCompleted: {
    if (this.WlrLayershell != null) {
      this.WlrLayershell.layer = WlrLayer.Overlay;
      this.WlrLayershell.namespace = "notifications";
    }
  }

  anchors {
    left: true
    top: true
    bottom: true
    right: true
  }

  NotificationServer {
    id: notifServer
    actionsSupported: true
    persistenceSupported: true

    onNotification: notif => {
      notif.tracked = true;
    }
  }

  visible: stack.children.length != 0
  mask: Region {
    item: stack
  }

  ListView {
    id: stack

    model: notifServer.trackedNotifications // Use default given

    anchors.right: parent.right
    y: root.barRef.height
    implicitWidth: 400
    implicitHeight: children.reduce((h, c) => h + c.height, 0)
    interactive: false
    // spacing: 20

    displaced: Transition {
        NumberAnimation {
            property: "y"
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    move: Transition {
        NumberAnimation {
            property: "y"
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "y"
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    delegate: NotifItem {
      required property Notification modelData

      notif: modelData

      onDismissed: () => {

        if (notif) {
          notif.dismiss();
          print("dismissed")
        }

        // Remove this entry from root.notifs by identity
        const idx = root.notifs.indexOf(notif);
        if (idx > -1) {
          root.notifs.splice(idx, 1);
          root.notifs = [...root.notifs]; // trigger bindings
          print("after dm", root.notifs)
        }
      }
    }
  }
}
