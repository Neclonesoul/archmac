import QtQuick
import Quickshell.Io

QtObject {
    id: service

    /*
     * ARCHMAC Galaxy system telemetry authority.
     *
     * One bounded sampler owns machine telemetry.
     * UI surfaces never independently poll the machine.
     *
     * CPU     /proc/stat + cpufreq
     * RAM     /proc/meminfo
     * TEMP    Linux thermal interface
     * STORAGE statvfs via df
     *
     * History is intentionally bounded.
     */

    property int cpuPercent: -1
    property int memoryPercent: -1
    property int temperatureC: -1

    property real cpuClockGHz: -1
    property real cpuMinGHz: -1
    property real cpuMaxGHz: -1
    property string cpuGovernor: "--"

    property real memoryUsedGiB: -1
    property real memoryTotalGiB: -1
    property real memoryAvailableGiB: -1
    property real memoryCacheGiB: -1

    property real swapUsedGiB: -1
    property real swapTotalGiB: -1
    property int swapPercent: -1

    property var corePercents: []
    property var previousCoreTotals: []
    property var previousCoreIdles: []

    property int gpuClockMHz: -1
    property int gpuActualMHz: -1
    property int gpuMinMHz: -1
    property int gpuMaxMHz: -1

    property string batteryStatus: "--"
    property int batteryHealthPercent: -1
    property int batteryCycles: -1
    property real batteryVoltageV: -1
    property real batteryPowerW: -1

    property int storagePercent: -1
    property real storageUsedGiB: -1
    property real storageTotalGiB: -1
    property real storageAvailableGiB: -1

    property var cpuHistory: []
    property var temperatureHistory: []
    property var memoryHistory: []

    property int historyLimit: 60

    property double previousTotal: -1
    property double previousIdle: -1

    function gibFromKiB(value) {
        return value / 1048576
    }

    function boundedAppend(values, value) {
        const next = values.slice()

        next.push(value)

        while (next.length > historyLimit)
            next.shift()

        return next
    }

    function recordHistory() {
        if (cpuPercent >= 0)
            cpuHistory =
                boundedAppend(cpuHistory, cpuPercent)

        if (temperatureC >= 0)
            temperatureHistory =
                boundedAppend(
                    temperatureHistory,
                    temperatureC
                )

        if (memoryPercent >= 0)
            memoryHistory =
                boundedAppend(
                    memoryHistory,
                    memoryPercent
                )
    }

    property Process sampler: Process {
        command: [
            "sh",
            "-c",
            "grep '^cpu' /proc/stat; " +

            "awk '" +
            "/^MemTotal:/ {mt=$2} " +
            "/^MemAvailable:/ {ma=$2} " +
            "/^Cached:/ {mc=$2} " +
            "/^SwapTotal:/ {st=$2} " +
            "/^SwapFree:/ {sf=$2} " +
            "END {print \"MEM\",mt,ma,mc,st,sf}" +
            "' /proc/meminfo; " +

            "if [ -r /sys/class/thermal/thermal_zone1/temp ]; then " +
                "printf 'TEMP '; " +
                "cat /sys/class/thermal/thermal_zone1/temp; " +
            "else " +
                "for z in /sys/class/thermal/thermal_zone*/temp; do " +
                    "[ -r \"$z\" ] && { " +
                        "printf 'TEMP '; cat \"$z\"; break; " +
                    "}; " +
                "done; " +
            "fi; " +

            "set -- /sys/devices/system/cpu/cpufreq/policy*/scaling_cur_freq; " +
            "sum=0; count=0; " +
            "for f in \"$@\"; do " +
                "[ -r \"$f\" ] || continue; " +
                "v=$(cat \"$f\"); " +
                "sum=$((sum + v)); " +
                "count=$((count + 1)); " +
            "done; " +
            "if [ \"$count\" -gt 0 ]; then " +
                "avg=$((sum / count)); " +
                "min=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq 2>/dev/null || printf 0); " +
                "max=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null || printf 0); " +
                "gov=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor 2>/dev/null || printf unknown); " +
                "printf 'FREQ %s %s %s %s\\n' \"$avg\" \"$min\" \"$max\" \"$gov\"; " +
            "fi; " +

            "df -Pk / | awk 'NR==2 {print \"DISK\",$2,$3,$4,$5}'; " +

            "gpu=$(find -L /sys/class/drm -maxdepth 3 -name gt_cur_freq_mhz -type f 2>/dev/null | head -n 1); " +
            "if [ -n \"$gpu\" ]; then " +
                "gdir=${gpu%/*}; " +
                "gcur=$(cat \"$gdir/gt_cur_freq_mhz\" 2>/dev/null || printf 0); " +
                "gact=$(cat \"$gdir/gt_act_freq_mhz\" 2>/dev/null || printf 0); " +
                "gmin=$(cat \"$gdir/gt_min_freq_mhz\" 2>/dev/null || printf 0); " +
                "gmax=$(cat \"$gdir/gt_max_freq_mhz\" 2>/dev/null || printf 0); " +
                "printf 'GPU %s %s %s %s\\n' \"$gcur\" \"$gact\" \"$gmin\" \"$gmax\"; " +
            "fi; " +

            "bat=/sys/class/power_supply/BAT0; " +
            "if [ -d \"$bat\" ]; then " +
                "bs=$(cat \"$bat/status\" 2>/dev/null || printf unknown); " +
                "bf=$(cat \"$bat/charge_full\" 2>/dev/null || printf 0); " +
                "bd=$(cat \"$bat/charge_full_design\" 2>/dev/null || printf 0); " +
                "bc=$(cat \"$bat/cycle_count\" 2>/dev/null || printf 0); " +
                "bv=$(cat \"$bat/voltage_now\" 2>/dev/null || printf 0); " +
                "if [ -r \"$bat/power_now\" ]; then " +
                    "bp=$(cat \"$bat/power_now\"); " +
                    "printf 'BAT %s %s %s %s %s POWER\\n' \"$bs\" \"$bf\" \"$bd\" \"$bc\" \"$bv\" \"$bp\"; " +
                "else " +
                    "bi=$(cat \"$bat/current_now\" 2>/dev/null || printf 0); " +
                    "printf 'BAT %s %s %s %s %s %s CURRENT\\n' \"$bs\" \"$bf\" \"$bd\" \"$bc\" \"$bv\" \"$bi\"; " +
                "fi; " +
            "fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines =
                    this.text.trim().split("\n")

                for (
                    let i = 0;
                    i < lines.length;
                    ++i
                ) {
                    const fields =
                        lines[i]
                            .trim()
                            .split(/\s+/)

                    if (fields.length === 0)
                        continue

                    if (
                        /^cpu[0-9]+$/.test(fields[0])
                    ) {
                        const index =
                            Number(
                                fields[0].substring(3)
                            )

                        let total = 0

                        for (
                            let n = 1;
                            n < fields.length;
                            ++n
                        ) {
                            total += Number(fields[n])
                        }

                        const idle =
                            Number(fields[4] || 0)
                            + Number(fields[5] || 0)

                        const totals =
                            service.previousCoreTotals.slice()

                        const idles =
                            service.previousCoreIdles.slice()

                        const values =
                            service.corePercents.slice()

                        if (
                            totals[index] !== undefined
                            && idles[index] !== undefined
                        ) {
                            const totalDelta =
                                total - totals[index]

                            const idleDelta =
                                idle - idles[index]

                            if (totalDelta > 0) {
                                values[index] =
                                    Math.round(
                                        100
                                        * (
                                            1
                                            - idleDelta
                                              / totalDelta
                                        )
                                    )
                            }
                        }

                        totals[index] = total
                        idles[index] = idle

                        service.previousCoreTotals = totals
                        service.previousCoreIdles = idles
                        service.corePercents = values
                    }

                    else if (fields[0] === "cpu") {
                        let total = 0

                        for (
                            let n = 1;
                            n < fields.length;
                            ++n
                        ) {
                            total += Number(fields[n])
                        }

                        const idle =
                            Number(fields[4] || 0)
                            + Number(fields[5] || 0)

                        if (
                            service.previousTotal >= 0
                        ) {
                            const totalDelta =
                                total
                                - service.previousTotal

                            const idleDelta =
                                idle
                                - service.previousIdle

                            if (totalDelta > 0) {
                                service.cpuPercent =
                                    Math.round(
                                        100 *
                                        (
                                            1
                                            - idleDelta
                                              / totalDelta
                                        )
                                    )
                            }
                        }

                        service.previousTotal = total
                        service.previousIdle = idle
                    }

                    else if (
                        fields[0] === "MEM"
                        && fields.length >= 6
                    ) {
                        const total =
                            Number(fields[1])

                        const available =
                            Number(fields[2])

                        const cached =
                            Number(fields[3])

                        const swapTotal =
                            Number(fields[4])

                        const swapFree =
                            Number(fields[5])

                        if (total > 0) {
                            const used =
                                total - available

                            service.memoryPercent =
                                Math.round(
                                    100
                                    * used
                                    / total
                                )

                            service.memoryTotalGiB =
                                service.gibFromKiB(total)

                            service.memoryAvailableGiB =
                                service.gibFromKiB(
                                    available
                                )

                            service.memoryUsedGiB =
                                service.gibFromKiB(used)

                            service.memoryCacheGiB =
                                service.gibFromKiB(
                                    cached
                                )
                        }

                        service.swapTotalGiB =
                            service.gibFromKiB(
                                swapTotal
                            )

                        service.swapUsedGiB =
                            service.gibFromKiB(
                                swapTotal - swapFree
                            )

                        service.swapPercent =
                            swapTotal > 0
                                ? Math.round(
                                      100
                                      * (
                                          swapTotal
                                          - swapFree
                                      )
                                      / swapTotal
                                  )
                                : 0
                    }

                    else if (
                        fields[0] === "TEMP"
                        && fields.length >= 2
                    ) {
                        let value =
                            Number(fields[1])

                        if (value > 1000)
                            value /= 1000

                        if (!isNaN(value)) {
                            service.temperatureC =
                                Math.round(value)
                        }
                    }

                    else if (
                        fields[0] === "FREQ"
                        && fields.length >= 5
                    ) {
                        service.cpuClockGHz =
                            Number(fields[1])
                            / 1000000

                        service.cpuMinGHz =
                            Number(fields[2])
                            / 1000000

                        service.cpuMaxGHz =
                            Number(fields[3])
                            / 1000000

                        service.cpuGovernor =
                            fields[4]
                    }

                    else if (
                        fields[0] === "GPU"
                        && fields.length >= 5
                    ) {
                        service.gpuClockMHz =
                            Number(fields[1])

                        service.gpuActualMHz =
                            Number(fields[2])

                        service.gpuMinMHz =
                            Number(fields[3])

                        service.gpuMaxMHz =
                            Number(fields[4])
                    }

                    else if (
                        fields[0] === "BAT"
                        && fields.length >= 8
                    ) {
                        service.batteryStatus =
                            fields[1]

                        const full =
                            Number(fields[2])

                        const design =
                            Number(fields[3])

                        service.batteryCycles =
                            Number(fields[4])

                        const voltageUv =
                            Number(fields[5])

                        const raw =
                            Number(fields[6])

                        service.batteryVoltageV =
                            voltageUv / 1000000

                        service.batteryHealthPercent =
                            design > 0
                                ? Math.round(
                                      100
                                      * full
                                      / design
                                  )
                                : -1

                        if (fields[7] === "POWER") {
                            service.batteryPowerW =
                                raw / 1000000
                        } else {
                            service.batteryPowerW =
                                voltageUv
                                * raw
                                / 1000000000000
                        }
                    }

                    else if (
                        fields[0] === "DISK"
                        && fields.length >= 5
                    ) {
                        const total =
                            Number(fields[1])

                        const used =
                            Number(fields[2])

                        const available =
                            Number(fields[3])

                        service.storageTotalGiB =
                            service.gibFromKiB(total)

                        service.storageUsedGiB =
                            service.gibFromKiB(used)

                        service.storageAvailableGiB =
                            service.gibFromKiB(
                                available
                            )

                        service.storagePercent =
                            Number(
                                fields[4]
                                    .replace("%", "")
                            )
                    }
                }

                service.recordHistory()
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
