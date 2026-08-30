import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"

PanelWindow {
    id: root

    required property var shellScreen
    required property var theme
    required property var dashboard
    required property var mode
    required property var workspaces
    required property var windows
    required property var power
    required property var audio
    required property var telemetry
    required property var media
    required property var network
    required property var bluetooth

    screen: shellScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    focusable: dashboard.open
    visible: dashboard.open
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus:
        dashboard.open
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

    function percent(value) {
        return Math.round(Number(value) || 0) + "%"
    }

    Rectangle {
        anchors.fill: parent
        color: "#E8080C10"

        MouseArea {
            anchors.fill: parent
            onClicked: dashboard.hide()
        }
    }

    Rectangle {
        width: Math.min(1040, parent.width - 50)
        height: Math.min(660, parent.height - 70)
        anchors.centerIn: parent

        radius: theme.radiusPanel
        color: theme.panelSurface
        border.width: 1
        border.color: theme.panelBorder

        opacity: dashboard.open ? 1 : 0
        scale: dashboard.open ? 1 : 0.97

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 145
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 13

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                Column {
                    spacing: 2

                    Text {
                        text: "ARCHMAC GALAXY"
                        color: theme.textPrimary
                        font.family: "0xProto"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "COMMAND CENTRE"
                        color: theme.textMuted
                        font.family: "0xProto"
                        font.pixelSize: 8
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 120
                    height: 30
                    radius: 9
                    color: "#18FFFFFF"
                    border.width: 1
                    border.color: theme.cardBorder

                    Text {
                        anchors.centerIn: parent
                        text: mode.currentMode
                        color: theme.textSecondary
                        font.family: "0xProto"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 104
                spacing: 9

                Repeater {
                    model: [
                        {
                            icon: "memory",
                            label: "CPU",
                            value: root.percent(telemetry.cpuPercent),
                            detail: telemetry.cpuClockGHz.toFixed(2) + " GHz"
                        },
                        {
                            icon: "thermostat",
                            label: "TEMP",
                            value: Math.round(telemetry.temperatureC) + "°",
                            detail: telemetry.cpuGovernor
                        },
                        {
                            icon: "developer_board",
                            label: "MEMORY",
                            value: root.percent(telemetry.memoryPercent),
                            detail: telemetry.memoryUsedGiB.toFixed(1)
                                + " / "
                                + telemetry.memoryTotalGiB.toFixed(1)
                                + " GiB"
                        },
                        {
                            icon: "hard_drive",
                            label: "STORAGE",
                            value: root.percent(telemetry.storagePercent),
                            detail: telemetry.storageAvailableGiB.toFixed(0)
                                + " GiB free"
                        },
                        {
                            icon: "battery_5_bar",
                            label: "BATTERY",
                            value: root.percent(power.percentage),
                            detail: telemetry.batteryHealthPercent.toFixed(0)
                                + "% health"
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 13
                        color: "#13FFFFFF"
                        border.width: 1
                        border.color: theme.cardBorder

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            ArchIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.icon
                                size: 20
                                color: theme.textSecondary
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.value
                                color: theme.textPrimary
                                font.family: "0xProto"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label + " · " + modelData.detail
                                color: theme.textMuted
                                font.family: "0xProto"
                                font.pixelSize: 7
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 14
                        color: "#12FFFFFF"
                        border.width: 1
                        border.color: theme.cardBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "WORKSPACES"
                                    color: theme.textSecondary
                                    font.family: "0xProto"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text:
                                        windows.count
                                        + (windows.count === 1
                                            ? " WINDOW"
                                            : " WINDOWS")

                                    color: theme.textMuted
                                    font.family: "0xProto"
                                    font.pixelSize: 8
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                columns: 5
                                rowSpacing: 7
                                columnSpacing: 7

                                Repeater {
                                    model: 10

                                    delegate: Rectangle {
                                        required property int index

                                        readonly property int workspaceId:
                                            index + 1

                                        readonly property int count: {
                                            let serial = windows.serial
                                            return windows
                                                .windowsForWorkspace(workspaceId)
                                                .length
                                        }

                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        radius: 10

                                        color:
                                            workspaces.currentId === workspaceId
                                                ? "#30FFFFFF"
                                                : count > 0
                                                    ? "#18FFFFFF"
                                                    : "#0AFFFFFF"

                                        border.width:
                                            workspaces.currentId === workspaceId
                                                ? 1 : 0

                                        border.color: theme.panelBorder

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 3

                                            Text {
                                                anchors.horizontalCenter:
                                                    parent.horizontalCenter

                                                text: workspaceId
                                                color: theme.textPrimary
                                                font.family: "0xProto"
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                anchors.horizontalCenter:
                                                    parent.horizontalCenter

                                                text:
                                                    count === 0
                                                        ? "EMPTY"
                                                        : count + " OPEN"

                                                color: theme.textMuted
                                                font.family: "0xProto"
                                                font.pixelSize: 7
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                dashboard.hide()
                                                workspaces.activate(workspaceId)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 112

                        radius: 14
                        color: "#12FFFFFF"
                        border.width: 1
                        border.color: theme.cardBorder

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            ArchIcon {
                                text: "graphic_eq"
                                size: 30
                                color: theme.textSecondary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    Layout.fillWidth: true
                                    text: media.title || "Nothing playing"
                                    color: theme.textPrimary
                                    elide: Text.ElideRight
                                    font.family: "0xProto"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: media.artist || "MEDIA"
                                    color: theme.textMuted
                                    elide: Text.ElideRight
                                    font.family: "0xProto"
                                    font.pixelSize: 8
                                }
                            }

                            Rectangle {
                                width: 42
                                height: 42
                                radius: 12
                                color: "#20FFFFFF"

                                ArchIcon {
                                    anchors.centerIn: parent
                                    text:
                                        media.playing
                                            ? "pause"
                                            : "play_arrow"
                                    size: 22
                                    color: theme.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: media.toggle()
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140

                        radius: 14
                        color: "#12FFFFFF"
                        border.width: 1
                        border.color: theme.cardBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 9

                            Text {
                                text: "CONNECTIVITY"
                                color: theme.textSecondary
                                font.family: "0xProto"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                ArchIcon {
                                    text: "wifi"
                                    size: 19
                                    color: theme.textSecondary
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text:
                                            network.connected
                                                ? network.ssid
                                                : "Disconnected"

                                        color: theme.textPrimary
                                        font.family: "0xProto"
                                        font.pixelSize: 9
                                    }

                                    Text {
                                        text: "WI-FI"
                                        color: theme.textMuted
                                        font.family: "0xProto"
                                        font.pixelSize: 7
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                ArchIcon {
                                    text: "bluetooth"
                                    size: 19
                                    color: theme.textSecondary
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text:
                                        bluetooth.enabled
                                            ? "Bluetooth on"
                                            : "Bluetooth off"

                                    color: theme.textPrimary
                                    font.family: "0xProto"
                                    font.pixelSize: 9
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 14
                        color: "#12FFFFFF"
                        border.width: 1
                        border.color: theme.cardBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Text {
                                text: "SYSTEM"
                                color: theme.textSecondary
                                font.family: "0xProto"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }

                            Repeater {
                                model: [
                                    {
                                        icon: "speed",
                                        title: "CPU RANGE",
                                        value:
                                            telemetry.cpuMinGHz.toFixed(1)
                                            + "–"
                                            + telemetry.cpuMaxGHz.toFixed(1)
                                            + " GHz"
                                    },
                                    {
                                        icon: "memory_alt",
                                        title: "GPU",
                                        value:
                                            Math.round(telemetry.gpuClockMHz)
                                            + " MHz"
                                    },
                                    {
                                        icon: "swap_horiz",
                                        title: "SWAP",
                                        value:
                                            telemetry.swapUsedGiB.toFixed(1)
                                            + " / "
                                            + telemetry.swapTotalGiB.toFixed(1)
                                            + " GiB"
                                    },
                                    {
                                        icon: "volume_up",
                                        title: "AUDIO",
                                        value:
                                            Math.round(audio.volume * 100)
                                            + "%"
                                    }
                                ]

                                delegate: RowLayout {
                                    required property var modelData

                                    Layout.fillWidth: true

                                    ArchIcon {
                                        text: modelData.icon
                                        size: 17
                                        color: theme.textMuted
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.title
                                        color: theme.textMuted
                                        font.family: "0xProto"
                                        font.pixelSize: 8
                                    }

                                    Text {
                                        text: modelData.value
                                        color: theme.textSecondary
                                        font.family: "0xProto"
                                        font.pixelSize: 8
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: "ESC TO CLOSE"
                                color: theme.textMuted
                                font.family: "0xProto"
                                font.pixelSize: 7
                            }
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: dashboard.open
        onActivated: dashboard.hide()
    }
}
