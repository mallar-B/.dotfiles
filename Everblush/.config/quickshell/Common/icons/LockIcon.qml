import QtQuick
import qs.Common

Item {
  id: root

  property color strokeColor: Theme.green
  property real  strokeWidth: 2           // used for keyhole sizing
  property real  lineWidth: 9             // main stroke width
  property real  introProgress: 0.0
  property real  rotation: 0.0

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

      ctx.translate(width / 2, height / 2);
      ctx.rotate(root.rotation);
      ctx.translate(-width / 2, -height / 2);

      const w = width;
      const h = height;

      // ---- Geometry ----
      const size   = Math.min(w, h);
      const pad    = size * 0.12;
      const bodyW  = size * 0.75;
      const bodyH  = size * 0.5;
      const cx     = w * 0.5;
      const bodyX  = cx - bodyW * 0.5;
      const bodyY  = h - pad - bodyH;
      const radius = bodyW * 0.18;

      const shackleOuterR = bodyW * 0.42;
      const shackleCy     = bodyY; // bottom of shackle at top of body

      const keyholeY = bodyY + bodyH * 0.45;
      const keyholeR = strokeWidth * 1.4;
      const stemLen  = keyholeR * 2.0;

      // ---- Stroke style ----
      ctx.lineWidth   = lineWidth;
      ctx.strokeStyle = strokeColor;
      ctx.lineJoin    = "round";
      ctx.lineCap     = "round";

      // ----- Helpers -----
      function clamp01(x) { return Math.max(0, Math.min(1, x)); }

      function linePart(x0, y0, x1, y1, rem) {
        const L = Math.hypot(x1 - x0, y1 - y0);
        if (L <= 0) return rem;
        const t = Math.min(1, rem / L);
        ctx.lineTo(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t);
        return rem - L;
      }

      function arcPart(cx, cy, rad, a0, a1, anticlockwise, rem) {
        const da = a1 - a0;
        const arcLen = Math.abs(da) * rad;
        if (arcLen <= 0) return rem;
        const t = Math.min(1, rem / arcLen);
        const a = a0 + da * t;
        ctx.arc(cx, cy, rad, a0, a, anticlockwise);
        return rem - arcLen;
      }

      // ---- Length bookkeeping ----
      // Body rounded-rect perimeter = 2*(w-2r + h-2r) + 2*pi*r
      const bodyHoriz = Math.max(0, bodyW - 2 * radius);
      const bodyVert  = Math.max(0, bodyH - 2 * radius);
      const bodyLen   = 2 * (bodyHoriz + bodyVert) + (2 * Math.PI * radius);

      // Shackle is a half-circle (-pi .. 0)
      const shackleLen = Math.PI * shackleOuterR;

      // Keyhole: circle + stem
      const keyCircleLen = 2 * Math.PI * keyholeR;
      const keyStemLen   = stemLen;

      const totalLen = bodyLen + shackleLen + keyCircleLen + keyStemLen;
      let visible = clamp01(root.introProgress) * totalLen;

      // ---- Progressive strokes ----
      function strokeBodyPart(len) {
        // Start at top edge, after top-left corner arc (so path is smooth)
        const xL = bodyX;
        const xR = bodyX + bodyW;
        const yT = bodyY;
        const yB = bodyY + bodyH;
        const r  = radius;

        ctx.beginPath();
        ctx.moveTo(xL + r, yT);

        let rem = Math.max(0, len);

        // Top edge -> top-right corner
        rem = linePart(xL + r, yT, xR - r, yT, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Top-right arc
        rem = arcPart(xR - r, yT + r, r, -Math.PI / 2, 0, false, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Right edge
        rem = linePart(xR, yT + r, xR, yB - r, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Bottom-right arc
        rem = arcPart(xR - r, yB - r, r, 0, Math.PI / 2, false, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Bottom edge
        rem = linePart(xR - r, yB, xL + r, yB, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Bottom-left arc
        rem = arcPart(xL + r, yB - r, r, Math.PI / 2, Math.PI, false, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Left edge
        rem = linePart(xL, yB - r, xL, yT + r, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // Top-left arc back to start
        arcPart(xL + r, yT + r, r, Math.PI, 3 * Math.PI / 2, false, rem);

        ctx.stroke();
      }

      function strokeShacklePart(len) {
        const startAngle = -Math.PI;
        const endAngle   = 0;

        ctx.beginPath();
        // same visual as your original: arc centered at (cx, shackleCy)
        // start point is at angle -pi (leftmost point)
        ctx.moveTo(cx - shackleOuterR, shackleCy);
        arcPart(cx, shackleCy, shackleOuterR, startAngle, endAngle, false, len);
        ctx.stroke();
      }

      function strokeKeyCirclePart(len) {
        ctx.beginPath();
        ctx.moveTo(cx + keyholeR, keyholeY);
        arcPart(cx, keyholeY, keyholeR, 0, 2 * Math.PI, false, len);
        ctx.stroke();
      }

      function strokeKeyStemPart(len) {
        ctx.beginPath();
        ctx.moveTo(cx, keyholeY + keyholeR);
        ctx.lineTo(cx, keyholeY + keyholeR + Math.min(len, keyStemLen));
        ctx.stroke();
      }

      // ---- Render in sequence based on visible length ----
      if (visible <= bodyLen) {
        strokeBodyPart(visible);
        return;
      }
      strokeBodyPart(bodyLen);
      visible -= bodyLen;

      if (visible <= shackleLen) {
        strokeShacklePart(visible);
        return;
      }
      strokeShacklePart(shackleLen);
      visible -= shackleLen;

      if (visible <= keyCircleLen) {
        strokeKeyCirclePart(visible);
        return;
      }
      strokeKeyCirclePart(keyCircleLen);
      visible -= keyCircleLen;

      strokeKeyStemPart(visible);
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
  }

  ParallelAnimation {
    id: introAnim
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
      from: -Math.PI * 1.5/3
      to: 0
      duration: 700
      easing.type: Easing.OutBack
    }
  }

  Component.onCompleted: introAnim.start()

  onStrokeColorChanged: canvas.requestPaint()
  onStrokeWidthChanged: canvas.requestPaint()
  onLineWidthChanged: canvas.requestPaint()
  onIntroProgressChanged: canvas.requestPaint()
  onRotationChanged: canvas.requestPaint()
}

