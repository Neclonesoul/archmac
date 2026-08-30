import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property bool open: false

    function show() { open = true }
    function hide() { open = false }
    function toggle() { open ? hide() : show() }

    property IpcHandler ipc: IpcHandler {
        target: "dashboard"

        function toggle(): void { service.toggle() }
        function show(): void { service.show() }
        function hide(): void { service.hide() }
    }
}
