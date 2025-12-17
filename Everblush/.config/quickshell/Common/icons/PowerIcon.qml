import QtQuick
import QtQuick
import qs.Common

Canvas {
  id: root
  width: 100
  height: 100
  contextType: "2d"
  anchors.fill: parent

  property bool isHovered: false

  property real introProgress: 0.0 // 0..1 – how much of the icon is drawn
  property real rotation: 0.0 // radians – rotates whole icon
  property real hoverPhase: 0.0 // 0..2π – for hover wobble

  // Repaint whenever animation values change
  onIntroProgressChanged: requestPaint()
  onRotationChanged:      requestPaint()
  onHoverPhaseChanged:    if (isHovered) requestPaint()
  onIsHoveredChanged: {
    if (!isHovered) {
      hoverPhase = 0; // reset bounce when hover ends
      requestPaint();
    }
  }

  onPaint: {
    var ctx = getContext("2d");
    ctx.reset();
    ctx.clearRect(0, 0, width, height);

    var cx = width  / 2;
    var cy = height / 2;
    var baseRadius = 30;

    // Hover wobble
    var wobble = isHovered ? Math.sin(hoverPhase) : 0;
    var radius = baseRadius * (1.0 + wobble * 0.06); // gentle scale
    var bounce = wobble * 4; // line bobbing

    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(rotation);

    ctx.strokeStyle = Theme.red;
    ctx.lineWidth = 10;
    ctx.lineCap = "round";

    // Circle arc
    var startAngle = -Math.PI * 0.25;
    var endAngle   =  Math.PI * 1.25;
    var sweep      = endAngle - startAngle;
    var currentEnd = startAngle + sweep * introProgress;

    ctx.beginPath();
    ctx.arc(0, 0, radius, startAngle, currentEnd, false);
    ctx.stroke();

    // Vertical power line: grows in + bounces on hover
    ctx.beginPath();
    var lineStartY = -radius;
    var lineFullLen = radius - 10;
    var lineEndY = lineStartY + lineFullLen * introProgress + bounce;

    ctx.moveTo(0, lineStartY);
    ctx.lineTo(0, lineEndY);
    ctx.stroke();

    ctx.restore();
  }

  // Intro animation
  ParallelAnimation {
    id: introAnim
    running: false

    NumberAnimation {
      target: root
      property: "introProgress"
      from: 0
      to: 1
      duration: 600
      easing.type: Easing.OutCubic
    }

    NumberAnimation {
      target: root
      property: "rotation"
      from: -Math.PI // spin in from upside-down
      to: 0
      duration: 700
      easing.type: Easing.OutBack
    }
  }

  // Hover animation (looped wobble)
  NumberAnimation {
    id: hoverAnim
    target: root
    property: "hoverPhase"
    from: 0
    to: Math.PI * 2
    duration: 1200
    loops: Animation.Infinite
    running: root.isHovered
    easing.type: Easing.Linear
  }

  Component.onCompleted: {
    requestPaint();
    introAnim.start();
  }
}
