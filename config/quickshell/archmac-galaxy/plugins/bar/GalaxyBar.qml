import QtQuick
import QtQuick.Layouts

import Quickshell

import "../workspaces"
import "../tray"
import "../../panels/controlcentre"
import "../../panels/network"
import "../../components"
import "../../monitor"

PanelWindow {
    id: bar

    required property var shellScreen
    required property var theme
    required property var mode
    required property var hardware
    required property var workspaces
    required property var power
    required property var audio
    required property var telemetry
    required property var brightness
    required property var media
    required property var network
    required property var bluetooth
    required property var notifications
    required property var clock

    property bool controlCentreOpen: false
    property bool networkPanelOpen: false
    property bool hardwareMonitorOpen: false

    function toggleControlCentre() {
        const next = !controlCentreOpen

        networkPanelOpen = false
        hardwareMonitorOpen = false
        controlCentreOpen = next
    }

    function toggleNetworkPanel() {
        const next = !networkPanelOpen

        controlCentreOpen = false
        hardwareMonitorOpen = false
        networkPanelOpen = next
    }

    function toggleHardwareMonitor() {
        const next = !hardwareMonitorOpen

        controlCentreOpen = false
        networkPanelOpen = false
        hardwareMonitorOpen = next
    }

    ControlCentre {
        theme: bar.theme
        audio: bar.audio
        power: bar.power
        brightness: bar.brightness
        telemetry: bar.telemetry
        media: bar.media
        network: bar.network
        bluetooth: bar.bluetooth
        mode: bar.mode

        opened: bar.controlCentreOpen

        onCloseRequested:
            bar.controlCentreOpen = false
    }

    NetworkPanel {
        shellScreen: bar.shellScreen
        theme: bar.theme
        network: bar.network

        opened: bar.networkPanelOpen

        onCloseRequested:
            bar.networkPanelOpen = false
    }

    HardwareMonitor {
        shellScreen: bar.shellScreen
        theme: bar.theme
        telemetry: bar.telemetry

        opened: bar.hardwareMonitorOpen

        onCloseRequested:
            bar.hardwareMonitorOpen = false
    }

    screen: shellScreen

    anchors {
        left: true
        right: true
        top: true
    }

    implicitHeight: 34
    exclusiveZone: 34

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        anchors {
            leftMargin: 6
            rightMargin: 6
            topMargin: 3
            bottomMargin: 3
        }

        radius: theme.radiusLarge
        color: theme.surface

        border.width: 1
        border.color: theme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 7

            Text {
                text: "ARCHMAC"

                color: theme.textPrimary

                font.family: "0xProto"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 0.6
            }

            Rectangle {
                width: 1
                height: 15
                color: "#24FFFFFF"
            }

            WorkspaceStrip {
                workspaceService: workspaces
                theme: bar.theme

                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: telemetryText.implicitWidth + 16
                implicitHeight: 22

                radius: theme.radiusSmall
                color: theme.surfaceRaised

                Text {
                    id: telemetryText
                    anchors.centerIn: parent

                    text: telemetry.compactLabel

                    color:
                        telemetry.temperatureC >= 85
                            ? "#FF6B6B"
                            : theme.textMuted

                    font.family: "0xProto"
                    font.pixelSize: 8
                    font.weight: Font.Medium
                }

                HoverHandler {
                    id: telemetryHover
                    cursorShape:
                        Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped:
                        bar.toggleHardwareMonitor()
                }
            }

            Rectangle {
                id: audioCapsule

                implicitWidth: audioContent.implicitWidth + 16
                implicitHeight: 22

                radius: theme.radiusSmall

                color: audioMouse.containsMouse
                    ? "#20FFFFFF"
                    : theme.surfaceRaised

                Row {
                    id: audioContent

                    anchors.centerIn: parent
                    spacing: 5

                    ArchIcon {
                        name:
                            !audio.available
                                ? "volume_off"
                                : audio.muted
                                    ? "volume_off"
                                    : audio.volume >= 70
                                        ? "volume_up"
                                        : audio.volume >= 30
                                            ? "volume_down"
                                            : "volume_mute"

                        size: 15

                        color:
                            audio.muted
                                ? theme.textMuted
                                : theme.textSecondary
                    }

                    Text {
                        id: audioText

                        text:
                            audio.available
                                ? audio.volume + "%"
                                : "--"

                        color:
                            audio.muted
                                ? theme.textMuted
                                : theme.textSecondary

                        font.family: "0xProto"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    id: audioMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            audio.toggleMute()
                            return
                        }

                        bar.toggleControlCentre()
                    }

                    onWheel: wheel => {
                        if (wheel.angleDelta.y > 0)
                            audio.changeVolume(0.05)
                        else if (wheel.angleDelta.y < 0)
                            audio.changeVolume(-0.05)
                    }
                }
            }

            Rectangle {
                implicitWidth: batteryContent.implicitWidth + 16
                implicitHeight: 22

                radius: theme.radiusSmall

                color: theme.surfaceRaised

                Row {
                    id: batteryContent

                    anchors.centerIn: parent
                    spacing: 5

                    ArchIcon {
                        name:
                            power.charging
                                ? "battery_charging_full"
                                : power.percentage < 0
                                    ? "battery_unknown"
                                    : power.percentage <= 15
                                        ? "battery_1_bar"
                                        : power.percentage <= 30
                                            ? "battery_2_bar"
                                            : power.percentage <= 55
                                                ? "battery_4_bar"
                                                : power.percentage <= 80
                                                    ? "battery_5_bar"
                                                    : "battery_full"

                        size: 15

                        color: {
                            if (power.percentage < 0)
                                return theme.textMuted

                            if (power.percentage <= 15)
                                return "#FF6B6B"

                            if (power.percentage <= 30)
                                return "#FFD166"

                            return theme.textSecondary
                        }
                    }

                    Text {
                        id: batteryText

                        text:
                            power.percentage >= 0
                                ? power.percentage + "%"
                                : "--"

                        color: {
                            if (power.percentage < 0)
                                return theme.textMuted

                            if (power.percentage <= 15)
                                return "#FF6B6B"

                            if (power.percentage <= 30)
                                return "#FFD166"

                            return theme.textSecondary
                        }

                        font.family: "0xProto"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }
                }
            }

            Rectangle {
                id: networkCapsule

                implicitWidth:
                    networkContent.implicitWidth + 16

                implicitHeight: 22

                radius: theme.radiusSmall

                color:
                    networkMouse.containsMouse
                        ? "#20FFFFFF"
                        : theme.surfaceRaised

                Row {
                    id: networkContent

                    anchors.centerIn: parent
                    spacing: 4

                    ArchIcon {
                        name:
                            network.connectionType === "offline"
                                ? "wifi_off"
                                : network.connectionType === "ethernet"
                                    ? "lan"
                                    : "wifi"

                        size: 15

                        color:
                            network.connectionType === "offline"
                                ? "#FFD166"
                                : theme.textSecondary
                    }

                    ArchIcon {
                        visible:
                            network.connectionType !== "offline"

                        name: "south"
                        size: 13
                        color: theme.accent
                    }

                    Text {
                        id: networkText

                        text:
                            network.connectionType === "offline"
                                ? "OFF"
                                : network.downloadCompact

                        color:
                            network.connectionType === "offline"
                                ? "#FFD166"
                                : theme.textSecondary

                        font.family: "0xProto"
                        font.pixelSize: 8
                        font.weight: Font.DemiBold
                    }

                    ArchIcon {
                        visible:
                            network.connectionType !== "offline"

                        name: "north"
                        size: 13
                        color: theme.accent
                    }

                    Text {
                        visible:
                            network.connectionType !== "offline"

                        text:
                            network.uploadCompact

                        color: theme.textSecondary

                        font.family: "0xProto"
                        font.pixelSize: 8
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    id: networkMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        bar.controlCentreOpen = false

                        bar.toggleNetworkPanel()
                    }
                }
            }

            SystemTrayWidget {
                theme: bar.theme
                hostWindow: bar

                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                width: 1
                height: 14
                color: "#24FFFFFF"
            }

            Rectangle {
                id: notificationCapsule

                implicitWidth:
                    notificationContent.implicitWidth + 16

                implicitHeight: 22

                radius: theme.radiusSmall

                color:
                    notificationTap.pressed
                        ? "#30FFFFFF"
                        : notificationHover.hovered
                            ? "#20FFFFFF"
                            : notifications.centreOpen
                                ? "#283EA6FF"
                                : theme.surfaceRaised

                Row {
                    id: notificationContent

                    anchors.centerIn: parent
                    spacing: 5

                    ArchIcon {
                        name:
                            notifications.count > 0
                                ? "notifications"
                                : "notifications_none"

                        size: 15

                        color:
                            notifications.count > 0
                                ? theme.textPrimary
                                : theme.textMuted
                    }

                    Text {
                        id: notificationLabel

                        visible:
                            notifications.count > 0

                        text:
                            notifications.count

                        color:
                            theme.textPrimary

                        font.family: "0xProto"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }
                }

                HoverHandler {
                    id: notificationHover

                    cursorShape:
                        Qt.PointingHandCursor
                }

                TapHandler {
                    id: notificationTap

                    onTapped:
                        notifications.toggleCentre()
                }
            }

            Rectangle {
                id: modeCapsule

                implicitWidth: modeLabel.implicitWidth + 18
                implicitHeight: 22

                radius: theme.radiusSmall

                color: modeTap.pressed
                    ? "#30FFFFFF"
                    : modeHover.hovered
                        ? "#20FFFFFF"
                        : theme.surfaceRaised

                Text {
                    id: modeLabel

                    anchors.centerIn: parent

                    text: mode.current.toUpperCase()

                    color:
                        mode.current === "battery"
                            ? "#FFD166"
                            : mode.current === "performance"
                                ? theme.accent
                                : theme.textSecondary

                    font.family: "0xProto"
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }

                HoverHandler {
                    id: modeHover

                    cursorShape:
                        Qt.PointingHandCursor
                }

                TapHandler {
                    id: modeTap

                    onTapped: {
                        console.log(
                            "ARCHMAC mode click:",
                            mode.current
                        )

                        mode.next()
                    }
                }
            }

            Text {
                text: Qt.formatDateTime(clock.date, "HH:mm")

                color: theme.textPrimary

                font.family: "0xProto"
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
        }
    }
}
