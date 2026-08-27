import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: service

    /*
     * BlueZ / Quickshell.Bluetooth is authoritative.
     *
     * Discovery is owned centrally so a UI surface cannot
     * accidentally leave the adapter scanning indefinitely.
     */

    property int discoveryUsers: 0

    readonly property var adapter:
        Bluetooth.defaultAdapter

    readonly property bool available:
        adapter !== null

    readonly property bool enabled:
        available && adapter.enabled

    readonly property bool discovering:
        available && adapter.discovering

    readonly property var devices:
        available
            ? adapter.devices
            : null

    function connectedCount() {
        if (!available)
            return 0

        const values = adapter.devices.values
        let count = 0

        for (let i = 0; i < values.length; ++i) {
            if (values[i].connected)
                count++
        }

        return count
    }

    readonly property int connectedDevices:
        connectedCount()

    readonly property string shortLabel: {
        if (!available)
            return "BT --"

        if (!enabled)
            return "BT OFF"

        if (connectedDevices > 0)
            return "BT " + connectedDevices

        return "BT ON"
    }

    function setEnabled(value) {
        if (!available)
            return

        adapter.enabled = value

        if (!value)
            discoveryUsers = 0

        updateDiscovery()
    }

    function toggleEnabled() {
        setEnabled(!enabled)
    }

    function updateDiscovery() {
        if (!available)
            return

        adapter.discovering =
            enabled && discoveryUsers > 0
    }

    function acquireDiscovery() {
        discoveryUsers++
        updateDiscovery()
    }

    function releaseDiscovery() {
        discoveryUsers =
            Math.max(0, discoveryUsers - 1)

        updateDiscovery()
    }

    function connectDevice(device) {
        if (!device)
            return

        device.connect()
    }

    function disconnectDevice(device) {
        if (!device)
            return

        device.disconnect()
    }

    function pairDevice(device) {
        if (!device)
            return

        device.pair()
    }

    function cancelPair(device) {
        if (!device)
            return

        device.cancelPair()
    }

    function trustDevice(device, trusted) {
        if (!device)
            return

        device.trusted = trusted
    }

    function forgetDevice(device) {
        if (!device)
            return

        device.forget()
    }

    onAdapterChanged:
        updateDiscovery()
}
