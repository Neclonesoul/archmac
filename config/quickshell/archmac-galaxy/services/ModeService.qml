import QtQuick

import Quickshell
import Quickshell.Io

QtObject {
    id: service

    readonly property string fancy: "fancy"
    readonly property string balanced: "balanced"
    readonly property string performance: "performance"
    readonly property string battery: "battery"

    readonly property string statePath:
        "/home/tyson/.local/state/archmac/mode"

    readonly property string eventPath:
        "/home/tyson/.local/state/archmac/mode-event"

    property string current: "balanced"

    signal modeActivated(
        string mode,
        string description
    )

    function validMode(mode) {
        return mode === fancy
            || mode === balanced
            || mode === performance
            || mode === battery
    }

    function descriptionFor(mode) {
        if (mode === fancy)
            return "Full visual experience"

        if (mode === balanced)
            return "Everyday efficiency"

        if (mode === performance)
            return "Maximum responsiveness"

        if (mode === battery)
            return "Maximum endurance"

        return ""
    }

    /*
     * Persistent state establishes truth.
     * It does NOT generate an OSD by itself.
     */
    function acceptState(value) {
        const mode = value.trim()

        if (!validMode(mode))
            return

        current = mode
    }

    /*
     * Explicit event means a user actually changed mode.
     * This is what triggers the transient Galaxy OSD.
     */
    property FileView eventFile: FileView {
        path: service.eventPath
        watchChanges: true

        function processEvent() {
            const fields =
                text().trim().split(" ")

            if (fields.length < 1)
                return

            const mode = fields[0]

            if (!service.validMode(mode))
                return

            service.current = mode

            service.modeActivated(
                mode,
                service.descriptionFor(mode)
            )
        }

        onFileChanged:
            reload()

        onTextChanged:
            processEvent()
    }

    property FileView stateFile: FileView {
        path: service.statePath
        watchChanges: true

        onLoaded:
            service.acceptState(
                text()
            )

        onFileChanged:
            reload()

        onTextChanged:
            service.acceptState(
                text()
            )
    }

    function apply(mode) {
        if (!validMode(mode))
            return

        current = mode

        /*
         * Galaxy-originated changes respond immediately.
         */
        modeActivated(
            mode,
            descriptionFor(mode)
        )

        Quickshell.execDetached([
            "/home/tyson/.local/bin/archmac-mode",
            mode
        ])
    }

    function next() {
        if (current === fancy) {
            apply(balanced)
            return
        }

        if (current === balanced) {
            apply(performance)
            return
        }

        if (current === performance) {
            apply(battery)
            return
        }

        apply(fancy)
    }

    readonly property string description:
        descriptionFor(current)
}
