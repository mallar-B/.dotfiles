import QtQuick
import qs.Common
Item{
  id: root

  property color strokeColor: Theme.yellow
  property real  strokeWidth: 10
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

      const w      = width;
      const h      = height;
      const cx     = w * 0.5;
      const cy     = h * 0.5;
      const radius = Math.min(w, h) * 0.44;

      ctx.lineJoin    = "round";
      ctx.lineCap     = "round";
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth   = strokeWidth;

      function clamp01(x) { return Math.max(0, Math.min(1, x)); }

      function arcPart(cx, cy, r, a0, a1, anticlockwise, rem) {
        const da = a1 - a0;
        const arcLen = Math.abs(da) * r;
        if (arcLen <= 0) return rem;

        const t = Math.min(1, rem / arcLen);
        const a = a0 + da * t;
        ctx.arc(cx, cy, r, a0, a, anticlockwise);
        return rem - arcLen;
      }

      // ---- Arc configurations ----
      const arc1Start = Math.PI / 2.5;
      const arc1End   = Math.PI * 5 / 3;

      const arc2Start = Math.PI * 4.5 / 6;
      const arc2End   = Math.PI * 7.5 / 6;

      const arc1Len = Math.abs(arc1End - arc1Start) * radius;
      const arc2Len = Math.abs(arc2End - arc2Start) * radius * 1.2;

      const totalLen = arc1Len + arc2Len;
      let visible = clamp01(introProgress) * totalLen;

      // ---- First arc ----
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(-Math.PI / 4);

      if (visible > 0) {
        ctx.beginPath();
        ctx.moveTo(
          Math.cos(arc1Start) * radius,
          Math.sin(arc1Start) * radius
        );
        visible = arcPart(0, 0, radius, arc1Start, arc1End, false, visible);
        ctx.stroke();
      }
      ctx.restore();

      if (visible <= 0) return;

      // ---- Second arc ----
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(-Math.PI / 4);
      ctx.rotate(Math.PI / 50);
      ctx.translate(cx + 5, 0);

      ctx.beginPath();
      ctx.moveTo(
        Math.cos(arc2Start) * radius * 1.2,
        Math.sin(arc2Start) * radius * 1.2
      );
      arcPart(0, 0, radius * 1.2, arc2Start, arc2End, false, visible);
      ctx.stroke();

      ctx.restore();
    }
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
      from: -Math.PI
      to: 0
      duration: 700
      easing.type: Easing.OutBack
    }
  }

  Component.onCompleted: introAnim.start()

  onIntroProgressChanged: canvas.requestPaint()
  onStrokeColorChanged: canvas.requestPaint()
  onStrokeWidthChanged: canvas.requestPaint()
  onWidthChanged: canvas.requestPaint()
  onHeightChanged: canvas.requestPaint()
}

// directly from svg
// Canvas {
//     id: icon
//
//     // Match your reference API
//     property color fillColor: Theme.yellow
//     property color strokeColor: Theme.yellow
//     property real strokeWidth: 3
//
//     onPaint: {
//         const ctx = getContext("2d");
//         if (!ctx) return;
//
//         ctx.reset();
//         ctx.clearRect(0, 0, width, height);
//
//         const w = width;
//         const h = height;
//         const size = Math.min(w, h);
//         const cx = w * 0.5;
//         const cy = h * 0.5;
//
//         // SVG viewBox is 0..202.748 in both axes
//         const vb = 202.748;
//         const s  = size / vb;
//         const ox = cx - (vb * s) * 0.5;
//         const oy = cy - (vb * s) * 0.5;
//
//         ctx.lineJoin    = "round";
//         ctx.lineCap     = "round";
//         ctx.strokeStyle = strokeColor;
//         ctx.fillStyle   = fillColor;
//
//         // Keep strokeWidth in device pixels even though we scale the coordinate system
//         ctx.lineWidth = (strokeWidth > 0) ? (strokeWidth / s) : 0;
//
//         ctx.save();
//         ctx.setTransform(s, 0, 0, s, ox, oy);
//
//         // --- SVG path replay (exact numbers) ---
//         ctx.beginPath();
//
//         let x = 0, y = 0;
//
//         // Absolute cubic Bézier
//         function C(x1, y1, x2, y2, x3, y3) {
//             ctx.bezierCurveTo(x1, y1, x2, y2, x3, y3);
//             x = x3; y = y3;
//         }
//
//         // Relative cubic Bézier (same semantics as SVG 'c')
//         function c(dx1, dy1, dx2, dy2, dx, dy) {
//             ctx.bezierCurveTo(x + dx1, y + dy1, x + dx2, y + dy2, x + dx, y + dy);
//             x += dx; y += dy;
//         }
//
//         // Subpath #1
//         x = 199.876; y = 119.867; ctx.moveTo(x, y);
//         c(-2.405, -1.886, -5.715, -2.124, -8.366, -0.6);
//         c(-12.57, 7.225, -25.856, 10.889, -39.489, 10.889);
//         c(-43.804, 0, -79.44, -35.638, -79.44, -79.443);
//         c(0, -13.693, 3.669, -26.961, 10.906, -39.434);
//         c(1.537, -2.648, 1.309, -5.965, -0.576, -8.379);
//         c(-1.884, -2.414, -5.047, -3.441, -7.989, -2.591);
//         c(-21.161, 6.1, -40.207, 19.042, -53.629, 36.441);
//         C(7.363, 54.809, 0, 76.437, 0, 99.297);
//         c(0, 57.035, 46.4, 103.438, 103.434, 103.438);
//         c(22.86, 0, 44.493, -7.36, 62.561, -21.286);
//         c(17.411, -13.419, 30.359, -32.454, 36.459, -53.6);
//         C(203.302, 124.911, 202.282, 121.754, 199.876, 119.867);
//         ctx.closePath();
//
//         // Subpath #2
//         x = 103.434; y = 187.734; ctx.moveTo(x, y);
//         C(54.671, 187.734, 15, 148.061, 15, 99.297);
//         c(0, -32.898, 18.825, -62.836, 47.436, -77.882);
//         c(-3.228, 9.485, -4.855, 19.284, -4.855, 29.298);
//         c(0, 52.076, 42.366, 94.443, 94.44, 94.443);
//         c(10, 0, 19.816, -1.634, 29.347, -4.873);
//         C(166.324, 168.9, 136.36, 187.734, 103.434, 187.734);
//         ctx.closePath();
//
//         ctx.fill();
//         ctx.stroke();
//
//         ctx.restore();
//     }
//
//     // Repaint when inputs change
//     onFillColorChanged: requestPaint()
//     onStrokeColorChanged: requestPaint()
//     onStrokeWidthChanged: requestPaint()
//     onWidthChanged: requestPaint()
//     onHeightChanged: requestPaint()
// }
