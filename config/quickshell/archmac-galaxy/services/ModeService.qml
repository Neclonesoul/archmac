import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    readonly property string fancy: "fancy"
    readonly property string balanced: "balanced"
    readonly property string performance: "performance"
    readonly property string battery: "battery"

    property string current: "balanced"

    property Process statusReader: Process {
        command: [
            "/home/tyson/.local/bin/archmac-mode",
            "status"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim()

                if (value === "fancy"
                        || value === "balanced"
                        || value === "performance"
                        || value === "battery") {
                    service.current = value
                }
            }
        }
    }

    property Timer refreshTimer: Timer {
        interval: 1500
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (!service.statusReader.running)
                service.statusReader.running = true
        }
    }

    function apply(mode) {
        if (mode !== fancy
                && mode !== balanced
                && mode !== performance
                && mode !== battery)
            return

        /*
         * Update presentation immediately.
         * The persistent state will confirm on the next refresh.
         */
        current = mode

        Quickshell.execDetached([
            "/home/tyson/.local/bin/archmac-mode",
            mode
        ])
    }

    function next() {
        if (current === fancy) {
            apply(balanced)
            return
        }

        if (current === balanced) {
            apply(performance)
            return
        }

        if (current === performance) {
            apply(battery)
            return
        }

        apply(fancy)
    }

    readonly property string description: {
        if (current === fancy)
            return "Full visual experience"

        if (current === balanced)
            return "Everyday efficiency"

        if (current === performance)
            return "Maximum responsiveness"

        if (current === battery)
            return "Maximum endurance"

        return ""
    }
}
