import QtQuick
import qs.Common

Item {
    id: root

    property color strokeColor: Theme.green
    property real  strokeWidth: 9
    property bool  mirrored: false

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

            const scale = Math.min(w, h) / 23;

            // Helper function to map grid coordinates to actual pixels
            const px = (val) => val * scale;

            // --- Configuration ---
            ctx.lineWidth = root.strokeWidth;
            ctx.strokeStyle = root.strokeColor;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";

            ctx.save();

            // Center the drawing in the available space
            // (Handle mirroring if you ever need a "Login" version)
            if (root.mirrored) {
                ctx.translate(w, 0);
                ctx.scale(-1, 1);
            }

            // Door
            const doorLeft = px(4);
            const doorRight = px(15);
            const doorTop = px(3);
            const doorBottom = px(21);
            const radius = px(2.5);

            // The gap starts at y=8 and resumes at y=16.5
            const gapTopY    = px(8);
            const gapBottomY = px(16.5);

            ctx.beginPath();
            ctx.moveTo(doorRight, gapTopY);
            ctx.arcTo(doorRight, doorTop, doorLeft, doorTop, radius);
            ctx.arcTo(doorLeft, doorTop, doorLeft, doorBottom, radius);
            ctx.arcTo(doorLeft, doorBottom, doorRight, doorBottom, radius);
            ctx.arcTo(doorRight, doorBottom, doorRight, gapBottomY, radius);
            ctx.lineTo(doorRight, gapBottomY);
            ctx.stroke();

            // Arrow
            const arrowStartX = px(11);
            const arrowEndX = px(21);
            const arrowY = px(12); // Vertically centered
            const headTipX = px(18.5);
            const headOffset = px(2.5); // Distance from center Y (12 +/- 2.5)

            ctx.beginPath();
            ctx.moveTo(arrowStartX, arrowY);
            ctx.lineTo(arrowEndX, arrowY);
            ctx.moveTo(arrowEndX, arrowY);
            ctx.lineTo(headTipX, arrowY - headOffset);
            ctx.moveTo(arrowEndX, arrowY);
            ctx.lineTo(headTipX, arrowY + headOffset);
            ctx.stroke();
            ctx.restore();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onVisibleChanged: if (visible) requestPaint()
    }

    onStrokeColorChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()
    onMirroredChanged: canvas.requestPaint()
}
