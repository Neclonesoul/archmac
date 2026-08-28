import QtQuick

import Quickshell
import Quickshell.Io

QtObject {
    id: service

    readonly property string brightnessPath:
        "/sys/class/backlight/intel_backlight/brightness"

    readonly property string maxBrightnessPath:
        "/sys/class/backlight/intel_backlight/max_brightness"

    property int rawValue: -1
    property int rawMaximum: -1

    readonly property int percentage:
        rawValue >= 0 && rawMaximum > 0
            ? Math.round(
                (rawValue / rawMaximum) * 100
            )
            : -1

    function readInteger(view) {
        const value =
            parseInt(view.text().trim())

        return isNaN(value)
            ? -1
            : value
    }

    property FileView maximumFile: FileView {
        path: service.maxBrightnessPath

        onLoaded: {
            service.rawMaximum =
                service.readInteger(this)
        }
    }

    property FileView brightnessFile: FileView {
        path: service.brightnessPath
        watchChanges: true

        onLoaded: {
            service.rawValue =
                service.readInteger(this)
        }

        onFileChanged: {
            reload()
        }

        onTextChanged: {
            service.rawValue =
                service.readInteger(this)
        }
    }

    function setPercentage(value) {
        const bounded =
            Math.max(
                5,
                Math.min(
                    100,
                    Math.round(value)
                )
            )

        Quickshell.execDetached([
            "brightnessctl",
            "set",
            bounded + "%"
        ])
    }

    function changePercentage(delta) {
        if (percentage < 0)
            return

        setPercentage(
            percentage + delta
        )
    }
}
