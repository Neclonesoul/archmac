import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool open: false
    property string pendingAction: ""

    function show() {
        pendingAction = ""
        open = true
    }

    function hide() {
        open = false
        pendingAction = ""
    }

    function toggle() {
        if (open)
            hide()
        else
            show()
    }

    function request(action) {
        if (action === "lock") {
            hide()
            command.command = ["loginctl", "lock-session"]
            command.running = true
            return
        }

        pendingAction = action
    }

    function cancel() {
        pendingAction = ""
    }

    function confirm() {
        const action = pendingAction
        hide()

        if (action === "sleep")
            command.command = ["systemctl", "suspend"]
        else if (action === "logout")
            command.command = ["hyprctl", "dispatch", "exit"]
        else if (action === "reboot")
            command.command = ["systemctl", "reboot"]
        else if (action === "shutdown")
            command.command = ["systemctl", "poweroff"]
        else
            return

        command.running = true
    }

    property Process command: Process {}

    property IpcHandler ipc: IpcHandler {
        target: "session"

        function toggle(): void { service.toggle() }
        function show(): void { service.show() }
        function hide(): void { service.hide() }
    }
}
