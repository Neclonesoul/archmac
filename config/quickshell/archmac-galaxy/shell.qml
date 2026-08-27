//@ pragma AppId archmac-galaxy
//@ pragma ShellId archmac-galaxy

import QtQuick

import Quickshell

import "services"
import "plugins/bar"

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

    SystemClock {
        id: clockService
        precision: SystemClock.Minutes
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
            clock: clockService
        }
    }
}
