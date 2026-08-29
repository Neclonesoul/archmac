import QtQuick

import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool open: false
    property string query: ""
    property int selectedIndex: 0

    property bool calculatorActive: false
    property bool calculatorPending: false
    property string calculatorExpression: ""
    property string calculatorResult: ""

    readonly property var applications:
        DesktopEntries.applications

    readonly property var filteredApplications: {
        if (calculatorActive)
            return []

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

    function looksLikeMath(text) {
        const value = text.trim()

        if (value.length < 2)
            return false

        /*
         * Require at least one digit and either:
         * - a mathematical operator, or
         * - a common function / constant.
         *
         * This avoids stealing ordinary app searches.
         */
        const hasDigit =
            /[0-9]/.test(value)

        const hasOperator =
            /[+\-*\/^()%]/.test(value)

        const hasFunction =
            /\b(sin|cos|tan|sqrt|log|ln|pi|abs|exp)\b/i
                .test(value)

        return (
            (hasDigit && hasOperator)
            || hasFunction
        )
    }

    function evaluateCalculator() {
        const expression =
            query.trim()

        calculatorActive =
            looksLikeMath(expression)

        calculatorExpression =
            calculatorActive
                ? expression
                : ""

        calculatorResult = ""
        calculatorPending = false

        if (!calculatorActive)
            return

        calculatorPending = true

        calculatorProcess.command = [
            "qalc",
            "-t",
            expression
        ]

        calculatorProcess.running = true
    }

    function copyCalculatorResult() {
        const value =
            calculatorResult.trim()

        if (
            !calculatorActive
            || calculatorPending
            || value === ""
        ) {
            return
        }

        clipboardProcess.command = [
            "wl-copy",
            value
        ]

        clipboardProcess.running = true

        hide()
    }

    function show() {
        query = ""
        selectedIndex = 0
        calculatorActive = false
        calculatorPending = false
        calculatorExpression = ""
        calculatorResult = ""
        open = true
    }

    function hide() {
        open = false
        query = ""
        selectedIndex = 0
        calculatorActive = false
        calculatorPending = false
        calculatorExpression = ""
        calculatorResult = ""
    }

    function toggle() {
        if (open)
            hide()
        else
            show()
    }

    function moveSelection(delta) {
        if (calculatorActive)
            return

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
        if (calculatorActive) {
            copyCalculatorResult()
            return
        }

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
        calculatorDebounce.restart()
    }

    property Timer calculatorDebounce: Timer {
        interval: 120
        repeat: false

        onTriggered:
            service.evaluateCalculator()
    }

    property Process calculatorProcess: Process {
        id: calculatorProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (!service.calculatorActive)
                    return

                service.calculatorResult =
                    text.trim()

                service.calculatorPending = false
            }
        }
    }

    property Process clipboardProcess: Process {
        id: clipboardProcess
    }

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
