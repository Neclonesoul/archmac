import QtQuick

import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool open: false
    property string query: ""
    property int selectedIndex: 0

    readonly property var applications:
        DesktopEntries.applications

    readonly property var filteredApplications: {
        const source =
            applications.values

        const needle =
            query.trim().toLowerCase()

        const ranked = []

        for (const entry of source) {
            if (!entry)
                continue

            const name =
                (entry.name || "").toLowerCase()

            const genericName =
                (entry.genericName || "").toLowerCase()

            const comment =
                (entry.comment || "").toLowerCase()

            const keywords =
                entry.keywords
                    ? entry.keywords.join(" ").toLowerCase()
                    : ""

            if (needle === "") {
                ranked.push({
                    entry: entry,
                    score: 0
                })

                continue
            }

            let score = -1

            if (name === needle)
                score = 1000
            else if (name.startsWith(needle))
                score = 800
            else if (name.includes(needle))
                score = 600
            else if (genericName.includes(needle))
                score = 400
            else if (keywords.includes(needle))
                score = 300
            else if (comment.includes(needle))
                score = 200

            if (score >= 0) {
                ranked.push({
                    entry: entry,
                    score: score
                })
            }
        }

        ranked.sort(
            (a, b) => {
                if (a.score !== b.score)
                    return b.score - a.score

                return a.entry.name.localeCompare(
                    b.entry.name
                )
            }
        )

        return ranked.map(
            item => item.entry
        )
    }

    readonly property int resultCount:
        filteredApplications.length

    function show() {
        query = ""
        selectedIndex = 0
        open = true
    }

    function hide() {
        open = false
        query = ""
        selectedIndex = 0
    }

    function toggle() {
        if (open)
            hide()
        else
            show()
    }

    function moveSelection(delta) {
        if (resultCount <= 0) {
            selectedIndex = 0
            return
        }

        selectedIndex =
            (
                selectedIndex
                + delta
                + resultCount
            ) % resultCount
    }

    function launch(entry) {
        if (!entry)
            return

        hide()

        entry.execute()
    }

    function launchSelected() {
        if (resultCount <= 0)
            return

        launch(
            filteredApplications[
                selectedIndex
            ]
        )
    }

    onQueryChanged: {
        selectedIndex = 0
    }

    /*
     * Hyprland will eventually call:
     *
     * qs -c archmac-galaxy ipc call launcher toggle
     *
     * This keeps launcher ownership inside the existing
     * long-lived Galaxy process.
     */
    property IpcHandler ipc: IpcHandler {
        target: "launcher"

        function toggle(): void {
            service.toggle()
        }

        function show(): void {
            service.show()
        }

        function hide(): void {
            service.hide()
        }
    }
}
