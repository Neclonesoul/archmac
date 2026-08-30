import QtQuick

Item {
    id: root

    required property var theme

    property var values: []
    property real minimum: 0
    property real maximum: 100

    implicitHeight: 42

    onValuesChanged:
        canvas.requestPaint()

    onMinimumChanged:
        canvas.requestPaint()

    onMaximumChanged:
        canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        onWidthChanged:
            requestPaint()

        onHeightChanged:
            requestPaint()

        onPaint: {
            const ctx = getContext("2d")

            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            if (!root.values || root.values.length < 2)
                return

            const span =
                Math.max(
                    1,
                    root.maximum - root.minimum
                )

            const usableHeight =
                Math.max(1, height - 4)

            const step =
                width
                / Math.max(
                    1,
                    root.values.length - 1
                )

            ctx.beginPath()

            for (
                let i = 0;
                i < root.values.length;
                ++i
            ) {
                const value =
                    Math.max(
                        root.minimum,
                        Math.min(
                            root.maximum,
                            Number(root.values[i])
                        )
                    )

                const x = i * step
                const y =
                    height
                    - 2
                    - (
                        (value - root.minimum)
                        / span
                        * usableHeight
                    )

                if (i === 0)
                    ctx.moveTo(x, y)
                else
                    ctx.lineTo(x, y)
            }

            ctx.lineWidth = 1.5
            ctx.strokeStyle = root.theme.accent
            ctx.stroke()
        }
    }
}
