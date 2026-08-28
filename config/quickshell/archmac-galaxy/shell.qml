//@ pragma AppId archmac-galaxy
//@ pragma ShellId archmac-galaxy

import QtQuick

import Quickshell

import "services"
import "plugins/bar"
import "osd"
import "notifications"
import "launcher"

ShellRoot {
    id: root

    ThemeService {
        id: themeService
    }

    ModeService {
        id: modeService
    }

    HardwareService {
        id: hardwareService
    }

    WorkspaceService {
        id: workspaceService
    }

    PowerService {
        id: powerService
    }

    AudioService {
        id: audioService
    }

    SystemTelemetryService {
        id: telemetryService
    }

    BrightnessService {
        id: brightnessService
    }

    MediaService {
        id: mediaService
    }

    NetworkService {
        id: networkService
    }

    BluetoothService {
        id: bluetoothService
    }

    OsdService {
        id: osdService
    }

    NotificationService {
        id: notificationService
    }

    LauncherService {
        id: launcherService
    }

    SystemClock {
        id: clockService
        precision: SystemClock.Minutes
    }

    Connections {
        target: audioService

        function onVolumeChanged() {
            if (!audioService.available)
                return

            osdService.showVolume(
                audioService.volume,
                audioService.muted
            )
        }

        function onMutedChanged() {
            if (!audioService.available)
                return

            osdService.showVolume(
                audioService.volume,
                audioService.muted
            )
        }
    }

    Connections {
        target: brightnessService

        function onPercentageChanged() {
            osdService.showBrightness(
                brightnessService.percentage
            )
        }
    }

    Connections {
        target: modeService

        function onModeActivated(
            mode,
            description
        ) {
            osdService.showMode(
                mode,
                description
            )
        }
    }

    Variants {
        model: Quickshell.screens

        GalaxyLauncher {
            required property var modelData

            shellScreen: modelData
            theme: themeService
            launcher: launcherService
        }
    }

    Variants {
        model: Quickshell.screens

        NotificationToast {
            required property var modelData

            shellScreen: modelData
            theme: themeService
            notifications: notificationService
        }
    }

    Variants {
        model: Quickshell.screens

        NotificationCentre {
            required property var modelData

            shellScreen: modelData
            theme: themeService
            notifications: notificationService
        }
    }

    Variants {
        model: Quickshell.screens

        SystemOsd {
            required property var modelData

            shellScreen: modelData
            theme: themeService
            osd: osdService
        }
    }

    Variants {
        model: Quickshell.screens

        GalaxyBar {
            required property var modelData

            shellScreen: modelData

            theme: themeService
            mode: modeService
            hardware: hardwareService
            workspaces: workspaceService
            power: powerService
            audio: audioService
            telemetry: telemetryService
            brightness: brightnessService
            media: mediaService
            network: networkService
            bluetooth: bluetoothService
            notifications: notificationService
            clock: clockService
        }
    }
}
