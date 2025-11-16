import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Common

PanelWindow {
  id: root

  required property var barRef // For top margin
  property var notifs: []

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

      // Wrap the Notification in a JS object
      const entry = {
        notif: notif, // the raw Notification object
        id: Date.now() + Math.random() // unique id for stable identity, if needed
      };

      root.notifs = [...root.notifs, entry];
      console.log("notifs:", root.notifs);
    }
  }

  visible: stack.children.length != 0
  mask: Region {
    item: stack
  }

ListView {
  id: stack

  model: ScriptModel {
    values: root.notifs   // 👈 no spreading, no filter yet
  }

  anchors.right: parent.right
  y: root.barRef.height
  implicitWidth: 400
  implicitHeight: children.reduce((h, c) => h + c.height, 0)
  interactive: false
  spacing: 20

  delegate: NotifItem {
    // The element in `root.notifs` is our JS wrapper object
    required property var modelData

    // Pass the underlying Notification to NotifItem
    notif: modelData.notif

    onDismissed: () => {
      // Safely try to dismiss the underlying Notification, if it's still valid
      if (modelData.notif) {
        modelData.notif.dismiss();
      }

      // Remove this entry from root.notifs by identity
      const idx = root.notifs.indexOf(modelData);
      if (idx > -1) {
        root.notifs.splice(idx, 1);
        root.notifs = [...root.notifs]; // trigger bindings
      }
    }
  }
}}
