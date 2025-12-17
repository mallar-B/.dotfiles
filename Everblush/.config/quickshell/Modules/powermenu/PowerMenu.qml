import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Common

PanelWindow {
  id: root
  property var barRef

  anchors {
    right: true
    top: true
  }

  exclusionMode: "Ignore"
  visible: false

  property int diameter: 500

  implicitWidth: diameter / 2
  implicitHeight: diameter
  margins.top: barRef.height + 10

  color: "transparent"

  focusable: true

  // Powermenu actions
  property var actions: [
    { label: "Shutdown", command: "systemctl poweroff", icon: "system-shutdown-symbolic", color: Theme.red },
    { label: "Sleep", command: "systemctl suspend", icon: "system-suspend", color: Theme.yellow },
    { label: "Reboot", command: "systemctl reboot", icon: "system-reboot", color: Theme.blue },
    { label: "Lock", command: "hyprlock", icon: "system-lock-screen", color: Theme.green },
    { label: "Logout", command: "hyprctl dispatch exit", icon: "system-log-out", color: Theme.purple },
  ]

  // rotation of the whole arc
  property int angleOffset: 0
  property int animatedAngleOffset: 0 // to avoid wrong offset because of animation

  // target angle for center
  // property real targetAngle: 90

  // which REPEATER index is currently closest to targetAngle
  property int currentIndex: -1

  function updateCurrent() {
    // Left-middle point of the circle
    var leftX = circle.x;          // left edge of circle
    var leftY = circle.y + circle.height / 2;     // vertical center of circle

    var minDistSq = Number.MAX_VALUE;
    var best = -1;

    for (var i = 0; i < arcRepeater.count; ++i) {
      var item = arcRepeater.itemAt(i);
      if (!item) continue;

      // left of the icon
      var cx = item.x
      var cy = item.y + item.height / 2;

      var dx = cx - leftX;
      var dy = cy - leftY;
      var distSq = dx * dx + dy * dy;

      if (distSq < minDistSq) {
          minDistSq = distSq;
          best = i;
      }
    }

    currentIndex = best % (root.actions.length * 2);
    // console.log("called")
  }

  function toggleWindow() {
    if (root.visible){
      stopAnimation.start();
      backdropWindow.hide();
      return;
    }
    else if (!root.visible){
      backdropWindow.show();
      startAnimation.start();
      root.visible = true;
    }
  }

  onAngleOffsetChanged: animatedAngleOffset = angleOffset
  Component.onCompleted: {
    updateCurrent();
    this.WlrLayershell.namespace = "powermenu";
  }
  onAnimatedAngleOffsetChanged: updateCurrent()

  Backdrop{
    id: backdropWindow
    openAnimDuration: Anim.durations.small
    closeAnimDuration: Anim.durations.expressiveEffects
    closeWindowFunc: root.toggleWindow
  }

  // container
  Item{
    id: container
    y: parent.height / 2

    // Full circle background, only the left half is visible inside the window
    Rectangle {
      id: circle
      width: root.diameter
      height: root.diameter
      radius: width / 2

      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left

      color: Theme.background_primary
      border.color: Theme.dark_gray
      MouseArea {
        anchors.fill: parent
        onWheel: (e) =>{
          root.angleOffset += (e.angleDelta.y / 120 * 36) - ((e.angleDelta.y / 120 * 36) % 36)
        }
        propagateComposedEvents: true
      }
      Rectangle{
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -(circle.width / 7)

        Label{
          id: currentLabel
          property var currentIcon: root.actions[root.currentIndex % root.actions.length]

          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          text: currentIcon.label
          // color: currentIcon.color
          color: Theme.foreground_secondary
          font.pointSize: 18
          font.family: "Monaspace Radon Frozen"

          // Glow
          layer.enabled: true
          layer.effect: MultiEffect {
          shadowEnabled: true
          shadowColor: currentLabel.currentIcon.color
          shadowBlur: 1.0
          shadowScale: 1.1
          shadowHorizontalOffset: 0
          shadowVerticalOffset: 0
          }
        }

        MouseArea{
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: () =>{
            root.toggleWindow();
            Quickshell.execDetached({
              command: ["sh", "-c", root.actions[index % arcRepeater.listLength].command]
            });
          }
        }
      }
    }

    // arc layout of buttons along the circle
    Repeater {
      id: arcRepeater
      property int listLength: root.actions.length
      property int rings: 2 // how many times we wrap the items around

      model: listLength * rings // duplicates to give the spinning illusion

      delegate: Item {
        id: slot

        width: 80
        height: 80

        // 0 deg = right, 90 deg = up, 180 deg = left, 270 deg = down
        property real startAngle: 0
        property real endAngle:   360

        // distribute the model items evenly
        property real t: arcRepeater.model > 0
          ? index / arcRepeater.model
          : 0.0

        // property real angleDeg: (startAngle + (endAngle - startAngle) * t + root.animatedAngleOffset) % 360
        property real angleDeg: startAngle + (endAngle - startAngle) * t + root.animatedAngleOffset
        property real angleRad: angleDeg * Math.PI / 180

        // Keep buttons  inside the edge of the circle
        property real r: root.diameter * 0.38

        readonly property real cx: circle.x + circle.width  / 2
        readonly property real cy: circle.y + circle.height / 2

        // Convert polar -> Cartesian (Qt y-axis goes down)
        // x: cx + r * Math.cos(angleRad) - width  / 2
        // y: cy - r * Math.sin(angleRad) - height / 2
        x: Math.round(cx + r * Math.cos(angleRad) - width  / 2)
        y: Math.round(cy - r * Math.sin(angleRad) - height / 2)

        Rectangle {
          id: bubble

          anchors.fill: parent
          radius: width / 2

          // Propertyies to decide relative distance from currindex
          property int relDist: {
            if(Math.abs(index - root.currentIndex) >= root.actions.length){
              return root.actions.length
                - (Math.abs(index - root.currentIndex)
                % root.actions.length)
            }
            return Math.abs(index - root.currentIndex)
          }

          // color: mouseArea.pressed
          //   ? Theme.gray
          //   : (mouseArea.containsMouse ? Theme.dark_gray : Theme.background_secondary)
          color: Theme.background_primary
          // border.color: Theme.gray
          scale: relDist === 0 ? 1.1
          : relDist === 1 ? 0.6
          : relDist === 2 ? 0.5 : 0.3

          Component {
            id: fallbackComponent;
            IconImage {
              anchors.fill: parent;
              source: Quickshell.iconPath("dialog-error-symbolic")
            }
          }

          readonly property string iconName: root.actions[index % arcRepeater.listLength].label
          Loader{
            active: root.visible
            id: iconLoader
            anchors.fill: parent
            source:
                bubble.iconName == "Lock"     ? "../../Common/icons/LockIcon.qml"
              : bubble.iconName == "Logout"   ? "../../Common/icons/LogoutIcon.qml"
              : bubble.iconName == "Sleep"    ? "../../Common/icons/SleepIcon.qml"
              : bubble.iconName == "Reboot"   ? "../../Common/icons/RebootIcon.qml"
              : bubble.iconName == "Shutdown" ? "../../Common/icons/PowerIcon.qml"
              : fallbackComponent
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: () =>{
              root.toggleWindow();
              Quickshell.execDetached({
                command: ["sh", "-c", root.actions[index % arcRepeater.listLength].command]
              });
            }
            onEntered: () => { root.currentIndex = index }
            onExited: () => { root.updateCurrent() }
          }
          Behavior on scale{
            NumberAnimation {
              duration: Anim.durations.small
              easing.type: Easing.Bezier
              easing.bezierCurve: Anim.curves.expressiveEffects
            }
          }
        }
      }
    }

    NumberAnimation {
      id: startAnimation
      target: container
      property: "x"
      from: root.diameter
      to: 0
      duration: Anim.durations.small
      easing.type: Easing.Bezier
      easing.bezierCurve: Anim.curves.expressiveEffects
    }
    NumberAnimation {
      id: stopAnimation
      target: container
      property: "x"
      from: 0
      to: root.diameter
      duration: Anim.durations.large
      easing.type: Easing.Bezier
      easing.bezierCurve: Anim.curves.expressiveEffects
      onStopped: root.visible = false;
    }
  }

  Behavior on animatedAngleOffset {
    NumberAnimation {
      duration: Anim.durations.small
      easing.type: Easing.InOutSine
    }
  }

  ParallelAnimation{

  }
}
