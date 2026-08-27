import QtQuick

import Quickshell
import Quickshell.Io

QtObject {
    id: service

    readonly property string fancy: "fancy"
    readonly property string balanced: "balanced"
    readonly property string performance: "performance"
    readonly property string battery: "battery"

    property string current: balanced
    property bool applying: false

    /*
     * Mode state is owned by the archmac-mode command.
     *
     * QML is presentation/control.
     * The command is the stable system boundary.
     */

    property Process statusReader: Process {
        command: [
            "/home/tyson/.local/bin/archmac-mode",
            "status"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim()

                if (value === service.fancy
                        || value === service.balanced
                        || value === service.performance
                        || value === service.battery) {
                    service.current = value
                }
            }
        }
    }

    property Timer refreshTimer: Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (!service.statusReader.running)
                service.statusReader.running = true
        }
    }

    function apply(mode) {
        if (applying)
            return

        if (mode !== fancy
                && mode !== balanced
                && mode !== performance
                && mode !== battery)
            return

        applying = true
        current = mode

        Quickshell.execDetached([
            "/home/tyson/.local/bin/archmac-mode",
            mode
        ])

        settleTimer.restart()
    }

    function next() {
        switch (current) {
        case fancy:
            apply(balanced)
            break

        case balanced:
            apply(performance)
            break

        case performance:
            apply(battery)
            break

        default:
            apply(fancy)
            break
        }
    }

    property Timer settleTimer: Timer {
        interval: 700
        repeat: false

        onTriggered: {
            service.applying = false

            if (!service.statusReader.running)
                service.statusReader.running = true
        }
    }

    readonly property real motionScale: {
        switch (current) {
        case performance:
            return 0.60

        case battery:
            return 0.45

        case balanced:
            return 0.80

        default:
            return 1.0
        }
    }

    readonly property string description: {
        switch (current) {
        case fancy:
            return "Full visual experience"

        case balanced:
            return "Everyday efficiency"

        case performance:
            return "Maximum responsiveness"

        case battery:
            return "Maximum endurance"

        default:
            return ""
        }
    }
}
