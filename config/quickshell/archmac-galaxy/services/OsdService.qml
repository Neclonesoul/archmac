import QtQuick

QtObject {
    id: service

    property bool visible: false
    property bool armed: false

    property string kind: "volume"
    property string title: ""
    property string detail: ""

    property real value: 0
    property bool showProgress: true

    /*
     * Do not show OSDs while Galaxy is discovering its initial
     * hardware state during startup/reload.
     */
    property Timer armTimer: Timer {
        interval: 3000
        repeat: false
        running: true

        onTriggered:
            service.armed = true
    }

    property Timer hideTimer: Timer {
        interval: 1350
        repeat: false

        onTriggered:
            service.visible = false
    }

    function reveal() {
        if (!armed)
            return

        visible = true
        hideTimer.restart()
    }

    function showVolume(percent, muted) {
        kind = muted
            ? "mute"
            : "volume"

        title = muted
            ? "MUTED"
            : "VOLUME"

        detail = muted
            ? ""
            : Math.round(percent) + "%"

        value =
            Math.max(
                0,
                Math.min(
                    1,
                    percent / 100
                )
            )

        showProgress = !muted

        reveal()
    }

    function showBrightness(percent) {
        if (percent < 0)
            return

        kind = "brightness"
        title = "BRIGHTNESS"

        detail =
            Math.round(percent)
            + "%"

        value =
            Math.max(
                0,
                Math.min(
                    1,
                    percent / 100
                )
            )

        showProgress = true

        reveal()
    }

    function showMode(
        mode,
        description
    ) {
        kind = "mode"

        title =
            mode.toUpperCase()

        detail =
            description

        value = 0
        showProgress = false

        reveal()
    }
}
