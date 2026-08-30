import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QtObject {
    id: service

    property var windows: []
    property int serial: 0
    property bool refreshing: false

    readonly property int count: windows.length

    function windowsForWorkspace(workspaceId) {
        const result = []

        for (let i = 0; i < windows.length; ++i) {
            if (windows[i].workspaceId === workspaceId)
                result.push(windows[i])
        }

        return result
    }

    function focusWindow(address) {
        if (address)
            Hyprland.dispatch("focuswindow address:" + address)
    }

    function closeWindow(address) {
        if (address)
            Hyprland.dispatch("closewindow address:" + address)
    }

    function moveWindow(address, workspaceId) {
        if (!address || workspaceId < 1 || workspaceId > 10)
            return

        Hyprland.dispatch(
            "movetoworkspacesilent "
            + workspaceId
            + ",address:"
            + address
        )

        scheduleRefresh()
    }

    function scheduleRefresh() {
        refreshDebounce.restart()
    }

    function refresh() {
        if (refreshing)
            return

        refreshing = true
        clientProcess.running = true
    }

    property Timer refreshDebounce: Timer {
        interval: 45
        repeat: false

        onTriggered:
            service.refresh()
    }

    property Process clientProcess: Process {
        command: [
            "hyprctl",
            "-j",
            "clients"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let parsed

                try {
                    parsed = JSON.parse(text)
                } catch (error) {
                    console.warn(
                        "WindowService: invalid hyprctl JSON:",
                        error
                    )

                    service.refreshing = false
                    return
                }

                const snapshot = []

                for (let i = 0; i < parsed.length; ++i) {
                    const client = parsed[i]

                    if (!client.mapped || client.hidden)
                        continue

                    const workspaceId =
                        client.workspace
                            ? client.workspace.id
                            : -1

                    if (workspaceId <= 0)
                        continue

                    snapshot.push({
                        address: client.address || "",
                        stableId: client.stableId || "",
                        workspaceId: workspaceId,

                        className:
                            client.class
                                || client.initialClass
                                || "",

                        title:
                            client.title
                                || client.initialTitle
                                || client.class
                                || "Window",

                        pid: client.pid || 0,
                        monitor: client.monitor || 0,

                        x: client.at ? client.at[0] : 0,
                        y: client.at ? client.at[1] : 0,

                        width:
                            client.size
                                ? client.size[0]
                                : 1,

                        height:
                            client.size
                                ? client.size[1]
                                : 1,

                        floating: !!client.floating,
                        fullscreen: client.fullscreen !== 0,
                        xwayland: !!client.xwayland,

                        focused:
                            client.focusHistoryID === 0
                    })
                }

                snapshot.sort((a, b) => {
                    if (a.workspaceId !== b.workspaceId)
                        return a.workspaceId - b.workspaceId

                    return a.address.localeCompare(b.address)
                })

                service.windows = snapshot
                service.serial++
                service.refreshing = false
            }
        }
    }

    property Connections hyprlandConnections: Connections {
        target: Hyprland

        function onRawEvent(event) {
            switch (event.name) {
            case "openwindow":
            case "closewindow":
            case "movewindow":
            case "movewindowv2":
            case "activewindow":
            case "activewindowv2":
            case "changefloatingmode":
            case "fullscreen":
            case "workspace":
            case "createworkspace":
            case "destroyworkspace":
                service.scheduleRefresh()
                break
            }
        }
    }

    Component.onCompleted:
        scheduleRefresh()
}
