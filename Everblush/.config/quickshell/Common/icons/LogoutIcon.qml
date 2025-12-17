import QtQuick
import qs.Common

Item {
  id: root

  property color strokeColor: Theme.purple
  property real  strokeWidth: 9
  property bool  mirrored: false
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

      // Wobble
      ctx.translate(width / 2, height / 2);
      ctx.rotate(root.rotation);
      ctx.translate(-width / 2, -height / 2);

      const w = width;
      const h = height;

      const scale = Math.min(w, h) / 23;
      const px = (val) => val * scale;

      // --- Configuration ---
      ctx.lineWidth = root.strokeWidth;
      ctx.strokeStyle = root.strokeColor;
      ctx.lineJoin = "round";
      ctx.lineCap = "round";

      ctx.save();

      // Mirror if needed
      if (root.mirrored) {
        ctx.translate(w, 0);
        ctx.scale(-1, 1);
      }

      const doorLeft   = px(4);
      const doorRight  = px(15);
      const doorTop    = px(3);
      const doorBottom = px(21);
      const r          = px(2.5);

      const gapTopY    = px(8);
      const gapBottomY = px(16.5);

      const arrowStartX = px(11);
      const arrowEndX   = px(21);
      const arrowY      = px(12);
      const headTipX    = px(18.5);
      const headOffset  = px(2.5);

      // ----- Helpers -----
      function clamp01(x) { return Math.max(0, Math.min(1, x)); }

      // Door path length
      const topHoriz    = (doorRight - r) - (doorLeft + r);
      const leftVert    = (doorBottom - r) - (doorTop + r);
      const rightTopSeg = gapTopY - (doorTop + r);
      const rightBotSeg = (doorBottom - r) - gapBottomY;
      const doorLen     = rightTopSeg + topHoriz + leftVert + topHoriz + rightBotSeg + (2 * Math.PI * r);

      // Arrow lengths
      const shaftLen = (arrowEndX - arrowStartX);
      const headLen  = Math.hypot(arrowEndX - headTipX, headOffset);
      const arrowLen = shaftLen + headLen + headLen;

      const totalLen = doorLen + arrowLen;

      // Convert progress -> visible length across the whole icon
      let visible = clamp01(root.introProgress) * totalLen;

      // Progressive door strok
      function strokeDoorPart(len) {

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

        ctx.beginPath();
        // start point
        ctx.moveTo(doorRight, gapTopY);

        let rem = Math.max(0, len);

        // 1) up right side
        rem = linePart(doorRight, gapTopY, doorRight, doorTop + r, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 2) top-right arc
        rem = arcPart(doorRight - r, doorTop + r, r, 0, -Math.PI / 2, true, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 3) top line
        rem = linePart(doorRight - r, doorTop, doorLeft + r, doorTop, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 4) top-left arc
        rem = arcPart(doorLeft + r, doorTop + r, r, -Math.PI / 2, -Math.PI, true, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 5) left line
        rem = linePart(doorLeft, doorTop + r, doorLeft, doorBottom - r, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 6) bottom-left arc
        rem = arcPart(doorLeft + r, doorBottom - r, r, -Math.PI, -3 * Math.PI / 2, true, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 7) bottom line
        rem = linePart(doorLeft + r, doorBottom, doorRight - r, doorBottom, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 8) bottom-right arc
        rem = arcPart(doorRight - r, doorBottom - r, r, -3 * Math.PI / 2, -2 * Math.PI, true, rem);
        if (rem <= 0) { ctx.stroke(); return; }

        // 9) up right side to gapBottom
        rem = linePart(doorRight, doorBottom - r, doorRight, gapBottomY, rem);

        ctx.stroke();
      }

      function strokeArrowPart(len) {
        ctx.beginPath();

        // 1) Shaft
        const shaftDraw = Math.min(len, shaftLen);
        const x2 = arrowStartX + shaftDraw;
        ctx.moveTo(arrowStartX, arrowY);
        ctx.lineTo(x2, arrowY);

        len -= shaftDraw;
        if (len <= 0) { ctx.stroke(); return; }

        // 2) Head upper
        const upDraw = Math.min(len, headLen);
        {
          const dx = (headTipX - arrowEndX);
          const dy = (-headOffset);
          const t = upDraw / headLen;
          ctx.moveTo(arrowEndX, arrowY);
          ctx.lineTo(arrowEndX + dx * t, arrowY + dy * t);
        }

        len -= upDraw;
        if (len <= 0) { ctx.stroke(); return; }

        // 3) Head lower
        const dnDraw = Math.min(len, headLen);
        {
          const dx = (headTipX - arrowEndX);
          const dy = (headOffset);
          const t = dnDraw / headLen;
          ctx.moveTo(arrowEndX, arrowY);
          ctx.lineTo(arrowEndX + dx * t, arrowY + dy * t);
        }

        ctx.stroke();
      }

      // Render based on visible length
      if (visible <= doorLen) {
        strokeDoorPart(visible);
      } else {
        strokeDoorPart(doorLen);
        strokeArrowPart(visible - doorLen);
      }

      ctx.restore();
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
  }

  ParallelAnimation{
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
      from: -Math.PI * 2/3
      to: 0
      duration: 700
      easing.type: Easing.OutBack
    }
  }

  Component.onCompleted: introAnim.start()

  onIntroProgressChanged: canvas.requestPaint();
  onStrokeColorChanged: canvas.requestPaint();
  onStrokeWidthChanged: canvas.requestPaint();
  onMirroredChanged: canvas.requestPaint();
  onRotationChanged: canvas.requestPaint();
}
