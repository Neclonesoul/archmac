import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: service

    readonly property var battery: UPower.displayDevice

    readonly property bool available:
        battery !== null
        && battery.ready
        && battery.isLaptopBattery

    readonly property int percentage:
        available
            ? Math.round(battery.percentage)
            : -1

    readonly property bool charging:
        available
        && battery.state === UPowerDeviceState.Charging

    readonly property bool fullyCharged:
        available
        && battery.state === UPowerDeviceState.FullyCharged

    readonly property real changeRate:
        available ? battery.changeRate : 0

    readonly property int timeToEmpty:
        available ? battery.timeToEmpty : 0

    readonly property int timeToFull:
        available ? battery.timeToFull : 0

    readonly property real health:
        available && battery.healthSupported
            ? battery.healthPercentage
            : -1

    readonly property string shortLabel: {
        if (!available)
            return "BAT --"

        if (charging)
            return "BAT " + percentage + "% +"

        return "BAT " + percentage + "%"
    }
}
