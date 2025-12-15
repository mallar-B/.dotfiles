import QtQuick
import qs.Common

Item {
  id: root

  property color strokeColor: Theme.green
  property real  strokeWidth: 2
  property bool  locked: true

  Canvas {
    id: canvas
    anchors.fill: parent

    renderTarget: Canvas.Image
    renderStrategy: Canvas.Immediate

    onPaint: {
      const ctx = getContext("2d");
      if (!ctx) return;

      ctx.reset();
      ctx.clearRect(0, 0, width, height);

      const w = width;
      const h = height;

      // Base size for proportions
      const size   = Math.min(w, h);
      const pad    = size * 0.12;
      const bodyW  = size * 0.75;
      const bodyH  = size * 0.5;
      const cx     = w * 0.5;
      const bodyX  = cx - bodyW * 0.5;
      const bodyY  = h - pad - bodyH;
      const radius = bodyW * 0.18;

      ctx.lineWidth   = 9;
      ctx.strokeStyle = strokeColor;
      ctx.lineJoin    = "round";
      ctx.lineCap     = "round";

      // --- Lock body (rounded rectangle) ---
      ctx.beginPath();
      ctx.roundedRect(bodyX, bodyY, bodyW, bodyH, radius, radius);
      ctx.stroke();

      // --- Shackle ---
      const shackleOuterR = bodyW * 0.42;
      const shackleInnerR = shackleOuterR - strokeWidth * 1.2;
      const shackleCy     = bodyY;       // bottom of shackle at top of body

      ctx.save();
      // If unlocked, tilt the shackle slightly
      if (!root.locked) {
        const unlockAngle = -Math.PI / 8;      // small tilt
        const pivotX = cx + shackleOuterR * 0.65;
        const pivotY = shackleCy;
        ctx.translate(pivotX, pivotY);
        ctx.rotate(unlockAngle);
        ctx.translate(-pivotX, -pivotY);
      }

      // Draw outer arc
      ctx.beginPath();
      ctx.arc(cx, shackleCy, shackleOuterR, Math.PI, 0, false);
      ctx.stroke();

      // Draw inner arc to give "thickness" (optional, subtle)
      // ctx.beginPath();
      // ctx.arc(cx, shackleCy, shackleInnerR, Math.PI, 0, false);
      // ctx.stroke();

      ctx.restore();

      // --- Keyhole ---
      const keyholeY      = bodyY + bodyH * 0.45;
      const keyholeR      = strokeWidth * 1.4;
      const stemLen       = keyholeR * 2.0;

      // round part
      ctx.fillStyle = strokeColor;
      ctx.beginPath();
      ctx.arc(cx, keyholeY, keyholeR, 0, Math.PI * 2, false);
      ctx.fill();

      // stem part
      ctx.beginPath();
      ctx.moveTo(cx, keyholeY + keyholeR);
      ctx.lineTo(cx, keyholeY + keyholeR + stemLen);
      ctx.stroke();
    }

    // Repaint on size or visibility changes
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
  }

  // Repaint on property changes
  onStrokeColorChanged: canvas.requestPaint()
  onStrokeWidthChanged: canvas.requestPaint()
  onLockedChanged: canvas.requestPaint()
}
