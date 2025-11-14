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
    actionsSupported: true

    onNotification: notif => {
      notif.tracked = true;
      root.notifs = [...root.notifs, notif];
    }
  }

  visible: stack.children.length != 0
  mask: Region {
    item: stack
  }

  ListView {
    id: stack

    model: ScriptModel {
      values: [...root.notifs]
    }
    anchors.right: parent.right
    y: root.barRef.height
    implicitWidth: 400
    implicitHeight: children.reduce((h, c) => h + c.height, 0)
    interactive: false
    spacing: 20

    displaced: Transition {
      NumberAnimation {
        property: "y"
        duration: Anim.durations.expressiveEffects
        easing.type: Easing.Bezier
      }
    }

    move: Transition {
      NumberAnimation {
        property: "y"
        duration: Anim.durations.expressiveEffects
        easing.type: Easing.Bezier
      }
    }

    remove: Transition {
      NumberAnimation {
        property: "y"
        duration: Anim.durations.expressiveEffects
        easing.type: Easing.Bezier
      }
    }

    delegate: NotifItem {
      required property Notification modelData
      notif: modelData

      onDismissed: () => {
        modelData.dismiss();
        const index = root.notifs.indexOf(notif);
        if (index > -1)
          root.notifs.splice(index, 1);
      }
    }
  }
}
