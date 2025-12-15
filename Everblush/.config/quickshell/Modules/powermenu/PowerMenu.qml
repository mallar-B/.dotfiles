import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common

PanelWindow {
  id: root
  property var barRef

  anchors {
    right: true
    top: true
  }

  exclusionMode: "Ignore"

  property int diameter: 500

  implicitWidth: diameter / 2
  implicitHeight: diameter
  margins.top: barRef.height + 10

  color: "transparent"

  focusable: true

  // Powermenu actions
  property var actions: [
    { label: "Lock", command: "hyprlock", icon: "system-lock-screen" },
    { label: "Logout", command: "hyprctl dispatch exit", icon: "system-log-out" },
    { label: "Sleep", command: "systemctl suspend", icon: "system-suspend" },
    { label: "Reboot", command: "systemctl reboot", icon: "system-reboot" },
    { label: "Poweroff", command: "systemctl poweroff", icon: "system-shutdown-symbolic" }
  ]
  property var components: [
    "PowerIcon"
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
  onAngleOffsetChanged: animatedAngleOffset = angleOffset
  Component.onCompleted: updateCurrent()
  onAnimatedAngleOffsetChanged: updateCurrent()

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
        // console.log(root.animatedAngleOffset,root.angleOffset)
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

        property var coorFromLeft: bubble.mapToItem(circle, 0, bubble.height/2);
        property int distFromLeft: Math.round(coorFromLeft.x);

        // color: mouseArea.pressed
        //   ? Theme.gray
        //   : (mouseArea.containsMouse ? Theme.dark_gray : Theme.background_secondary)
        color: Theme.background_primary
        // border.color: Theme.gray
        // scale: Math.abs(index - root.currentIndex) === 0 ? 1.05
        // : Math.abs(index - root.currentIndex) === 1 ? 0.8
        // : Math.abs(index - root.currentIndex) === 2 ? 0.7 : 0.3

        Component { 
          id: fallbackComponent;
          IconImage {
            anchors.fill: parent;
            source: Quickshell.iconPath("dialog-error-symbolic") 
          }
        }

        readonly property string iconName: root.actions[index % arcRepeater.listLength].label
        Loader{
          id: iconLoader
          anchors.fill: parent
          source: bubble.iconName == "Lock" ? "LockIcon.qml"
          // source: bubble.iconName == "Lock" ? null
          // : bubble.iconName == "Logout" ? "LogoutIcon.qml"
          : bubble.iconName == "Sleep" ? "SleepIcon.qml"
          : bubble.iconName == "Reboot" ? "RebootIcon.qml"
          : bubble.iconName == "Poweroff" ? "PowerIcon.qml"
          : fallbackComponent

        }

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true

          onClicked: () =>{
            Quickshell.execDetached({
              command: ["sh", "-c", root.actions[index % arcRepeater.listLength].command]
            })
          }
          // onEntered: () => { iconLoader.item.isHovered = true; print(bubble.distFromLeft) }
          onEntered: () => {print(root.currentIndex, index) }
          onExited: () => { iconLoader.item.isHovered = false }
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
  Behavior on animatedAngleOffset {
    NumberAnimation {
      duration: Anim.durations.small
      easing.type: Easing.InOutSine
    }
  }
}
