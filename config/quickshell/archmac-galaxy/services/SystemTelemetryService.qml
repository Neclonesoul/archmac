import QtQuick
import Quickshell.Io

QtObject {
    id: service

    /*
     * One bounded sampler owns slow-changing machine telemetry.
     *
     * No widget independently polls the machine.
     *
     * CPU    /proc/stat
     * RAM    /proc/meminfo
     * TEMP   Linux thermal interface
     */

    property int cpuPercent: -1
    property int memoryPercent: -1
    property int temperatureC: -1

    property double previousTotal: -1
    property double previousIdle: -1

    property Process sampler: Process {
        command: [
            "sh",
            "-c",
            "head -1 /proc/stat; " +
            "awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print \"MEM\",t,a}' /proc/meminfo; " +
            "if [ -r /sys/class/thermal/thermal_zone1/temp ]; then " +
                "printf 'TEMP '; cat /sys/class/thermal/thermal_zone1/temp; " +
            "else " +
                "for z in /sys/class/thermal/thermal_zone*/temp; do " +
                    "[ -r \"$z\" ] && { printf 'TEMP '; cat \"$z\"; break; }; " +
                "done; " +
            "fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")

                for (let i = 0; i < lines.length; ++i) {
                    const fields =
                        lines[i].trim().split(/\s+/)

                    if (fields.length === 0)
                        continue

                    if (fields[0] === "cpu") {
                        let total = 0

                        for (let n = 1; n < fields.length; ++n)
                            total += Number(fields[n])

                        const idle =
                            Number(fields[4] || 0)
                            + Number(fields[5] || 0)

                        if (service.previousTotal >= 0) {
                            const totalDelta =
                                total - service.previousTotal

                            const idleDelta =
                                idle - service.previousIdle

                            if (totalDelta > 0) {
                                service.cpuPercent =
                                    Math.round(
                                        100 *
                                        (1 - idleDelta / totalDelta)
                                    )
                            }
                        }

                        service.previousTotal = total
                        service.previousIdle = idle
                    }

                    else if (fields[0] === "MEM"
                             && fields.length >= 3) {
                        const total = Number(fields[1])
                        const available = Number(fields[2])

                        if (total > 0) {
                            service.memoryPercent =
                                Math.round(
                                    100 *
                                    (1 - available / total)
                                )
                        }
                    }

                    else if (fields[0] === "TEMP"
                             && fields.length >= 2) {
                        let value = Number(fields[1])

                        if (value > 1000)
                            value /= 1000

                        if (!isNaN(value))
                            service.temperatureC =
                                Math.round(value)
                    }
                }
            }
        }
    }

    property Timer sampleTimer: Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (!service.sampler.running)
                service.sampler.running = true
        }
    }

    readonly property string compactLabel: {
        const cpu =
            cpuPercent >= 0
                ? "CPU " + cpuPercent + "%"
                : "CPU --"

        const ram =
            memoryPercent >= 0
                ? "RAM " + memoryPercent + "%"
                : "RAM --"

        const temp =
            temperatureC >= 0
                ? temperatureC + "°C"
                : "--°C"

        return cpu + "  " + ram + "  " + temp
    }
}
