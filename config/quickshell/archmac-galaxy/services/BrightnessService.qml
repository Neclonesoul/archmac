import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property int percentage: -1

    property Process reader: Process {
        command: [
            "brightnessctl",
            "-m"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",")

                if (fields.length < 4)
                    return

                const value = parseInt(
                    fields[3].replace("%", "")
                )

                if (!isNaN(value))
                    service.percentage = value
            }
        }
    }

    /*
     * Brightness may also be changed by existing Hyprland
     * hardware-key bindings, so refresh at a deliberately slow
     * cadence instead of placing polling in individual widgets.
     */
    property Timer refreshTimer: Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (!service.reader.running)
                service.reader.running = true
        }
    }

    function setPercentage(value) {
        const bounded =
            Math.max(5, Math.min(100, Math.round(value)))

        percentage = bounded

        Quickshell.execDetached([
            "brightnessctl",
            "set",
            bounded + "%"
        ])
    }

    function changePercentage(delta) {
        if (percentage < 0)
            return

        setPercentage(percentage + delta)
    }
}
