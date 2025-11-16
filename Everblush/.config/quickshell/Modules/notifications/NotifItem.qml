import QtQuick

Item {
  id: root

  signal dismissed

  required property var notif

  property var lifetime: 5000

  enum AnimState {
    Returning,
    Inert,
    Flinging,
    Dismissing
  }
  property var state: NotifItem.Returning
  property var isDragging: false

  property var initialX: 400
  property var initialY: 0
  property var initialR: 0
  property var targetX: 0
  property var targetY: 0
  property var targetR: 0
  property var velocityX: 0
  property var velocityY: 0
  property var velocityR: 0

  property bool dismissedAlready: false

  function triggerDismissed() {
    if (dismissedAlready)
      return;
    dismissedAlready = true;
    dismissed();
  }

  FrameAnimation {
    function dampingVelocity(currentVelocity, delta) {
      const spring = 1.0;
      const damping = 0.1;
      const springForce = spring * delta;
      const dampingForce = -damping * currentVelocity;
      return currentVelocity + (springForce + dampingForce);
    }

    running: root.state != NotifItem.Inert
    onTriggered: {
      if (root.state == NotifItem.Returning) {
        const deltaX = root.targetX - display.x;
        const deltaY = root.targetY - display.y;
        const deltaR = root.targetR - display.rotation;

        root.velocityX = dampingVelocity(root.velocityX, deltaX);
        root.velocityY = dampingVelocity(root.velocityY, deltaY);
        root.velocityR = dampingVelocity(root.velocityR, deltaR);

        if (Math.abs(root.velocityX) < 0.1 && Math.abs(root.velocityY) < 0.1) {
          root.state = NotifItem.Inert;
          root.velocityX = 0;
          root.velocityY = 0;
          root.velocityR = 0;
          display.x = root.targetX;
          display.y = root.targetY;
          display.rotation = root.targetR;
        }

        if (root.isDragging) {
          if (Math.abs(root.velocityX) > 1000 || Math.abs(root.velocityY) > 1000) {
            root.state = NotifItem.Flinging;
          }
        }
        } else if (root.state == NotifItem.Flinging) {
          root.velocityY += 3000 * frameTime;
          if (display.x > 10){
            display.rotation = root.velocityY * frameTime;
          }
          else{
            display.rotation = -root.velocityY * frameTime;
          }

          if (display.x > display.width || display.y > screen.height) {
            root.triggerDismissed()
          }
        } else if (root.state == NotifItem.Dismissing) {
          root.velocityX += frameTime * 20000;

          if (display.x > display.width) {
            root.triggerDismissed()
          }
        }

      display.x += root.velocityX * frameTime;
      display.y += root.velocityY * frameTime;
      display.rotation += root.velocityR * frameTime;
    }
  }

  implicitWidth: display.width
  implicitHeight: display.height

  Display {
    id: display
    notif: root.notif
    x: root.initialX
    y: root.initialY
    rotation: root.initialR
    transformOrigin: Item.Right
  }

  MouseArea {
    id: clickable

    anchors.fill: display
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    enabled: root.state != NotifItem.Flinging

    property var prevMouseX: 0
    property var prevMouseY: 0

    onPressed: e => {
      if (enabled && e.buttons & Qt.LeftButton) {
        prevMouseX = e.x;
        prevMouseY = e.y;
        root.isDragging = true;
        root.state = NotifItem.Returning;
      }
    }
    onReleased: e => {
      if (!(e.buttons & Qt.LeftButton)) {
        root.isDragging = false;
      }
    }
    onPositionChanged: e => {
      if (enabled && root.isDragging) {
        root.velocityX = (e.x - prevMouseX) * 200;
        root.velocityY = (e.y - prevMouseY) * 200;
        prevMouseX = e.x;
        prevMouseY = e.y;
      }
    }

    onClicked: e => {
      if (enabled && e.button & Qt.RightButton) {
        root.state = NotifItem.Dismissing;
      }
    }
  }

  Timer {
    id: timer
    interval: root.lifetime
    repeat: false
    running: !clickable.containsMouse && root.state == NotifItem.Inert
    onTriggered: () => {
      root.state = NotifItem.Dismissing;
    }
  }
}
