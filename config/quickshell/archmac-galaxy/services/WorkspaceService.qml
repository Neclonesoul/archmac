import QtQuick
import Quickshell.Hyprland

QtObject {
    id: service

    /*
     * ARCHMAC authoritative workspace presentation state.
     *
     * UI code does not retain HyprlandWorkspace objects.
     * We expose primitive values and perform compositor actions here.
     */

    property int currentId:
        Hyprland.focusedWorkspace
            ? Hyprland.focusedWorkspace.id
            : 1

    property int previousId: currentId

    // -1 = left, +1 = right, 0 = unknown/no movement
    property int direction: 0

    property int transitionSerial: 0

    readonly property int firstWorkspace: 1
    readonly property int lastWorkspace: 10

    function workspaceExists(id) {
        const values = Hyprland.workspaces.values

        for (let i = 0; i < values.length; ++i) {
            if (values[i].id === id)
                return true
        }

        return false
    }

    function activate(id) {
        if (id < firstWorkspace || id > lastWorkspace)
            return

        Hyprland.dispatch("workspace " + id)
    }

    function moveToWorkspace(id) {
        if (id < firstWorkspace || id > lastWorkspace)
            return

        Hyprland.dispatch("movetoworkspace " + id)
    }

    function syncFocusedWorkspace() {
        const ws = Hyprland.focusedWorkspace

        if (!ws || ws.id <= 0)
            return

        const next = ws.id

        if (next === currentId)
            return

        previousId = currentId

        if (next > currentId)
            direction = 1
        else if (next < currentId)
            direction = -1
        else
            direction = 0

        currentId = next
        transitionSerial++
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces()
        syncFocusedWorkspace()
    }

    property Connections hyprlandConnections: Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            service.syncFocusedWorkspace()
        }

        function onRawEvent(event) {
            /*
             * Workspace creation/destruction/movement can mutate the
             * compositor's object model. Request fresh state, then allow
             * focusedWorkspaceChanged to update our primitive state.
             */
            if (event.name === "createworkspace"
                    || event.name === "destroyworkspace"
                    || event.name === "moveworkspace"
                    || event.name === "workspace") {
                Hyprland.refreshWorkspaces()
                service.syncFocusedWorkspace()
            }
        }
    }
}
