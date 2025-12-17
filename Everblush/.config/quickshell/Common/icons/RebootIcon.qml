import QtQuick
import qs.Common

Canvas {
  id: root
  width: 100
  height: 100
  contextType: "2d"

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
    const ctx = getContext("2d")

    // clear
    ctx.reset()
    ctx.clearRect(0, 0, width, height)

    const cx = width / 2
    const cy = height / 2
    const baseRadius = Math.min(width, height) * 0.35

    // Hover wobble
    var wobble = isHovered ? Math.sin(hoverPhase) : 0;
    var radius = baseRadius * (1.0 + wobble * 0.06); // gentle scale
    var bounce = wobble * 4; // line bobbing

    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(rotation);


    ctx.lineWidth = 10
    ctx.strokeStyle = Theme.blue
    ctx.fillStyle = Theme.blue
    ctx.lineCap = "round";
    ctx.lineJoin = "round";

    // circular arc
    var startAngle = Math.PI * 0.25
    var endAngle   = Math.PI * 1.75
    var sweep      = endAngle - startAngle;
    var currentEnd = startAngle + sweep * introProgress;

    ctx.beginPath()
    ctx.arc(0, 0, radius, startAngle, currentEnd, false)
    ctx.stroke()

    // // arrow head
    // const arrowAngle = startAngle // where arrow is attached
    // const arrowSize = 15
    // const arrowX = cx + radius * Math.cos(arrowAngle) + arrowSize / 2 // shift the arrow right
    // const arrowY = cy + radius * Math.sin(arrowAngle) - arrowSize / 2 // shift the arrow up
    // const spread = 0.65
    //
    // // direction pointing roughly outward from circle
    // const dir = arrowAngle + Math.PI * 0.5
    //
    // ctx.beginPath()
    // ctx.moveTo(arrowX, arrowY)
    // ctx.lineTo(arrowX + arrowSize * Math.cos(dir - spread),
    //            arrowY + arrowSize * Math.sin(dir - spread))
    // ctx.lineTo(arrowX + arrowSize * Math.cos(dir + spread),
    //            arrowY + arrowSize * Math.sin(dir + spread))
    // ctx.closePath()
    // ctx.fill()


    // Rounded corner arrow head

    const arrowAngle = startAngle;
    const arrowLength = 15;
    const spread = 0.65;

    ctx.lineWidth = 4

    const arrowX = radius * Math.cos(arrowAngle) + arrowLength / 2;
    const arrowY = radius * Math.sin(arrowAngle) - arrowLength / 2;

    const dir = arrowAngle + Math.PI * 0.5;

    ctx.strokeStyle = ctx.fillStyle;

    ctx.beginPath();

    // first side
    ctx.moveTo(arrowX, arrowY);
    ctx.lineTo(
        arrowX + arrowLength * Math.cos(dir - spread),
        arrowY + arrowLength * Math.sin(dir - spread)
    );

    // second side
    ctx.moveTo(arrowX, arrowY);
    ctx.lineTo(
        arrowX + arrowLength * Math.cos(dir + spread),
        arrowY + arrowLength * Math.sin(dir + spread)
    );

    // connect to the first's end
    ctx.lineTo(
        arrowX + arrowLength * Math.cos(dir - spread),
        arrowY + arrowLength * Math.sin(dir - spread)
    );

    ctx.stroke();
    ctx.fill()
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
