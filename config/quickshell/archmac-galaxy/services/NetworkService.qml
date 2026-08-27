import QtQuick
import Quickshell.Networking

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
