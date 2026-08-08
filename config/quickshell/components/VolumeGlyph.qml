import QtQuick

Item {
    id: root

    property int percentage: 0
    property bool muted: false
    property color glyphColor: "white"

    implicitWidth: 24
    implicitHeight: 24

    Canvas {
        id: canvas
        anchors.fill: parent

        property int level: root.percentage
        property bool isMuted: root.muted
        property color paintColor: root.glyphColor

        onLevelChanged: requestPaint()
        onIsMutedChanged: requestPaint()
        onPaintColorChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;
            const color = paintColor.toString();

            ctx.clearRect(0, 0, w, h);
            ctx.fillStyle = color;
            ctx.strokeStyle = color;
            ctx.lineWidth = Math.max(1.7, w * 0.085);
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            // Speaker body.
            ctx.beginPath();
            ctx.moveTo(w * 0.12, h * 0.39);
            ctx.lineTo(w * 0.31, h * 0.39);
            ctx.lineTo(w * 0.52, h * 0.20);
            ctx.lineTo(w * 0.52, h * 0.80);
            ctx.lineTo(w * 0.31, h * 0.61);
            ctx.lineTo(w * 0.12, h * 0.61);
            ctx.closePath();
            ctx.fill();

            if (isMuted || level <= 0) {
                ctx.beginPath();
                ctx.moveTo(w * 0.66, h * 0.37);
                ctx.lineTo(w * 0.88, h * 0.63);
                ctx.moveTo(w * 0.88, h * 0.37);
                ctx.lineTo(w * 0.66, h * 0.63);
                ctx.stroke();
                return;
            }

            // Inner sound wave.
            ctx.beginPath();
            ctx.arc(w * 0.50, h * 0.50, w * 0.18, -0.72, 0.72, false);
            ctx.stroke();

            // Outer sound wave for medium/high volume.
            if (level >= 45) {
                ctx.beginPath();
                ctx.arc(w * 0.50, h * 0.50, w * 0.34, -0.72, 0.72, false);
                ctx.stroke();
            }

            // A small plus indicates amplification above 100%.
            if (level > 100) {
                ctx.lineWidth = Math.max(1.4, w * 0.07);
                ctx.beginPath();
                ctx.moveTo(w * 0.80, h * 0.13);
                ctx.lineTo(w * 0.80, h * 0.31);
                ctx.moveTo(w * 0.71, h * 0.22);
                ctx.lineTo(w * 0.89, h * 0.22);
                ctx.stroke();
            }
        }
    }
}
