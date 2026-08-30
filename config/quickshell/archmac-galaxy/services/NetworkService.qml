import QtQuick
import Quickshell.Networking
import Quickshell.Io

QtObject {
    id: service

    /*
     * ARCHMAC NetworkService
     *
     * NetworkManager / Quickshell.Networking is authoritative.
     *
     * No nmcli polling.
     * No per-widget state duplication.
     *
     * Scanner ownership is reference-counted because WifiDevice is
     * shared state. This prevents one panel instance from leaving
     * scanning active after it closes or disappears.
     */

    property int scannerUsers: 0

    /*
     * Live network throughput.
     *
     * NetworkManager remains authoritative for connectivity.
     * Linux sysfs byte counters are authoritative for traffic.
     *
     * One central one-second sampler feeds every Galaxy surface.
     */
    property real downloadBps: 0
    property real uploadBps: 0

    property real previousRxBytes: -1
    property real previousTxBytes: -1
    property double previousSampleMs: 0
    property string sampledInterface: ""

    readonly property string activeInterface:
        wiredConnected && wiredDevice
            ? wiredDevice.name
            : wifiConnected && wifiDevice
                ? wifiDevice.name
                : ""

    readonly property string downloadCompact:
        formatRateCompact(downloadBps)

    readonly property string uploadCompact:
        formatRateCompact(uploadBps)

    readonly property string downloadLabel:
        formatRate(downloadBps)

    readonly property string uploadLabel:
        formatRate(uploadBps)

    function formatRateCompact(bytesPerSecond) {
        const value = Math.max(0, bytesPerSecond)

        if (value >= 1024 * 1024 * 1024)
            return (value / (1024 * 1024 * 1024)).toFixed(1) + "G"

        if (value >= 1024 * 1024)
            return (value / (1024 * 1024)).toFixed(1) + "M"

        return Math.round(value / 1024) + "K"
    }

    function formatRate(bytesPerSecond) {
        const value = Math.max(0, bytesPerSecond)

        if (value >= 1024 * 1024 * 1024)
            return (value / (1024 * 1024 * 1024)).toFixed(1) + " GB/s"

        if (value >= 1024 * 1024)
            return (value / (1024 * 1024)).toFixed(1) + " MB/s"

        if (value >= 1024)
            return Math.round(value / 1024) + " KB/s"

        return Math.round(value) + " B/s"
    }

    function resetThroughput() {
        downloadBps = 0
        uploadBps = 0

        previousRxBytes = -1
        previousTxBytes = -1
        previousSampleMs = 0

        sampledInterface = activeInterface
    }

    function sampleThroughput() {
        if (activeInterface === "") {
            resetThroughput()
            return
        }

        if (throughputProcess.running)
            return

        throughputProcess.command = [
            "bash",
            "-lc",
            "iface=\"$1\"; "
                + "rx=$(cat \"/sys/class/net/$iface/statistics/rx_bytes\" 2>/dev/null || printf 0); "
                + "tx=$(cat \"/sys/class/net/$iface/statistics/tx_bytes\" 2>/dev/null || printf 0); "
                + "printf '%s %s %s\\n' \"$iface\" \"$rx\" \"$tx\"",
            "_",
            activeInterface
        ]

        throughputProcess.running = true
    }

    onActiveInterfaceChanged: {
        resetThroughput()
        sampleThroughput()
    }

    property Timer throughputTimer: Timer {
        interval: 1000
        repeat: true
        running: service.activeInterface !== ""

        onTriggered:
            service.sampleThroughput()
    }

    property Process throughputProcess: Process {
        id: throughputProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const fields =
                    text.trim().split(/\s+/)

                if (fields.length < 3)
                    return

                const iface = fields[0]
                const rx = Number(fields[1])
                const tx = Number(fields[2])
                const now = Date.now()

                if (
                    !Number.isFinite(rx)
                    || !Number.isFinite(tx)
                ) {
                    return
                }

                if (
                    service.sampledInterface !== iface
                    || service.previousRxBytes < 0
                    || service.previousTxBytes < 0
                    || service.previousSampleMs <= 0
                ) {
                    service.sampledInterface = iface
                    service.previousRxBytes = rx
                    service.previousTxBytes = tx
                    service.previousSampleMs = now
                    return
                }

                const seconds =
                    Math.max(
                        0.001,
                        (now - service.previousSampleMs)
                            / 1000
                    )

                service.downloadBps =
                    Math.max(
                        0,
                        (rx - service.previousRxBytes)
                            / seconds
                    )

                service.uploadBps =
                    Math.max(
                        0,
                        (tx - service.previousTxBytes)
                            / seconds
                    )

                service.previousRxBytes = rx
                service.previousTxBytes = tx
                service.previousSampleMs = now
            }
        }
    }

    readonly property bool wifiHardwareEnabled:
        Networking.wifiHardwareEnabled

    property bool wifiEnabled:
        Networking.wifiEnabled

    function findWifiDevice() {
        const devices = Networking.devices.values

        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i]
        }

        return null
    }

    function findWiredDevice() {
        const devices = Networking.devices.values

        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wired)
                return devices[i]
        }

        return null
    }

    readonly property var wifiDevice:
        findWifiDevice()

    readonly property var wiredDevice:
        findWiredDevice()

    function findConnectedWifi() {
        if (!wifiDevice)
            return null

        const values = wifiDevice.networks.values

        for (let i = 0; i < values.length; ++i) {
            if (values[i].connected)
                return values[i]
        }

        return null
    }

    readonly property var connectedWifi:
        findConnectedWifi()

    readonly property bool wifiConnected:
        connectedWifi !== null

    readonly property bool wiredConnected:
        wiredDevice !== null
        && wiredDevice.connected

    readonly property string ssid:
        wifiConnected
            ? connectedWifi.name
            : ""

    readonly property int signalPercent:
        wifiConnected
            ? Math.round(
                  connectedWifi.signalStrength * 100
              )
            : 0

    readonly property string connectionType:
        wiredConnected
            ? "ethernet"
            : wifiConnected
                ? "wifi"
                : "offline"

    readonly property string shortLabel: {
        if (!wifiHardwareEnabled)
            return "WIFI HW OFF"

        if (!wifiEnabled)
            return "WIFI OFF"

        if (wiredConnected)
            return "LAN"

        if (!wifiConnected)
            return "OFFLINE"

        return "WIFI " + signalPercent + "%"
    }

    readonly property string detailLabel:
        wifiConnected
            ? ssid
            : wiredConnected
                ? "Ethernet"
                : "Not connected"

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled
    }

    function toggleWifi() {
        Networking.wifiEnabled =
            !Networking.wifiEnabled
    }

    /*
     * Scanner lifecycle.
     *
     * Multiple surfaces may eventually consume the same WifiDevice
     * on a multi-monitor machine. Each acquires/releases ownership.
     */

    function updateScanner() {
        if (!wifiDevice)
            return

        wifiDevice.scannerEnabled =
            scannerUsers > 0
            && wifiEnabled
    }

    function acquireScanner() {
        scannerUsers++
        updateScanner()
    }

    function releaseScanner() {
        scannerUsers =
            Math.max(0, scannerUsers - 1)

        updateScanner()
    }

    function disconnectWifi() {
        if (connectedWifi)
            connectedWifi.disconnect()
    }

    function connectNetwork(network) {
        if (!network)
            return

        network.connect()
    }

    function connectWithPsk(network, password) {
        if (!network || !password)
            return

        network.connectWithPsk(password)
    }

    function forgetNetwork(network) {
        if (network)
            network.forget()
    }

    property Connections networkingConnections: Connections {
        target: Networking

        function onWifiEnabledChanged() {
            service.updateScanner()
        }
    }

    onWifiDeviceChanged:
        updateScanner()
}
