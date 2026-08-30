import QtQuick
import QtQuick.Layouts

import Quickshell

import "../components"

PanelWindow {
    id: window

    required property var shellScreen
    required property var theme
    required property var telemetry

    property bool opened: false

    signal closeRequested()

    screen: shellScreen

    anchors {
        top: true
        right: true
    }

    margins {
        top: 42
        right: 8
    }

    implicitWidth: 390
    implicitHeight: 650

    exclusionMode: ExclusionMode.Ignore
    focusable: false
    aboveWindows: true

    color: "transparent"
    visible: opened

    Rectangle {
        anchors.fill: parent

        radius: theme.radiusPanel
        color: theme.panelSurface

        border.width: 1
        border.color: theme.panelBorder

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14

            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Row {
                    Layout.fillWidth: true
                    spacing: 7

                    ArchIcon {
                        name: "monitoring"
                        size: 17
                        color: theme.accent
                    }

                    Text {
                        text: "HARDWARE MONITOR"
                        color: theme.textPrimary
                        font.family: "0xProto"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26

                    radius: 6

                    color:
                        closeTap.pressed
                            ? "#30FFFFFF"
                            : closeHover.hovered
                                ? "#20FFFFFF"
                                : "transparent"

                    ArchIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 16
                        color: theme.textSecondary
                    }

                    HoverHandler {
                        id: closeHover
                        cursorShape:
                            Qt.PointingHandCursor
                    }

                    TapHandler {
                        id: closeTap

                        onTapped:
                            window.closeRequested()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#24FFFFFF"
            }

            GridLayout {
                Layout.fillWidth: true

                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                MetricCard {
                    Layout.fillWidth: true

                    theme: window.theme
                    icon: "memory"
                    title: "CPU LOAD"

                    value:
                        telemetry.cpuPercent >= 0
                            ? telemetry.cpuPercent + "%"
                            : "--"
                }

                MetricCard {
                    Layout.fillWidth: true

                    theme: window.theme
                    icon: "speed"
                    title: "CPU CLOCK"

                    value:
                        telemetry.cpuClockGHz >= 0
                            ? telemetry.cpuClockGHz.toFixed(2)
                                + " GHz"
                            : "--"
                }

                MetricCard {
                    Layout.fillWidth: true

                    theme: window.theme
                    icon: "thermostat"
                    title: "CPU TEMP"

                    warning:
                        telemetry.temperatureC >= 85

                    value:
                        telemetry.temperatureC >= 0
                            ? telemetry.temperatureC + "°C"
                            : "--"
                }

                MetricCard {
                    Layout.fillWidth: true

                    theme: window.theme
                    icon: "developer_board"
                    title: "MEMORY"

                    value:
                        telemetry.memoryPercent >= 0
                            ? telemetry.memoryPercent + "%"
                            : "--"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 110

                radius: theme.radiusMedium
                color: theme.surfaceRaised

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "LIVE HISTORY"
                            color: theme.textMuted
                            font.family: "0xProto"
                            font.pixelSize: 8
                        }

                        Text {
                            text: "2 MIN"
                            color: theme.textMuted
                            font.family: "0xProto"
                            font.pixelSize: 7
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "CPU"
                                color: theme.textSecondary
                                font.family: "0xProto"
                                font.pixelSize: 7
                            }

                            Sparkline {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                theme: window.theme
                                values:
                                    telemetry.cpuHistory

                                minimum: 0
                                maximum: 100
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "TEMP"
                                color: theme.textSecondary
                                font.family: "0xProto"
                                font.pixelSize: 7
                            }

                            Sparkline {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                theme: window.theme
                                values:
                                    telemetry.temperatureHistory

                                minimum: 30
                                maximum: 100
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "RAM"
                                color: theme.textSecondary
                                font.family: "0xProto"
                                font.pixelSize: 7
                            }

                            Sparkline {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                theme: window.theme
                                values:
                                    telemetry.memoryHistory

                                minimum: 0
                                maximum: 100
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 74

                radius: theme.radiusMedium
                color: theme.surfaceRaised

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    Text {
                        text: "LOGICAL CPU CORES"
                        color: theme.textMuted
                        font.family: "0xProto"
                        font.pixelSize: 8
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model:
                                telemetry.corePercents.length

                            delegate: Rectangle {
                                required property int index

                                Layout.fillWidth: true
                                Layout.preferredHeight: 36

                                radius: 7
                                color: "#18FFFFFF"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Text {
                                        anchors.horizontalCenter:
                                            parent.horizontalCenter

                                        text:
                                            "CPU" + index

                                        color: theme.textMuted
                                        font.family: "0xProto"
                                        font.pixelSize: 7
                                    }

                                    Text {
                                        anchors.horizontalCenter:
                                            parent.horizontalCenter

                                        text:
                                            telemetry.corePercents[index]
                                            !== undefined
                                                ? telemetry.corePercents[index]
                                                    + "%"
                                                : "--"

                                        color: theme.textPrimary
                                        font.family: "0xProto"
                                        font.pixelSize: 9
                                    }
                                }
                            }
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                MetricCard {
                    Layout.fillWidth: true

                    theme: window.theme
                    icon: "developer_board"
                    title: "INTEL GPU"

                    value:
                        telemetry.gpuActualMHz >= 0
                            ? telemetry.gpuActualMHz
                                + " MHz"
                            : "--"
                }

                MetricCard {
                    Layout.fillWidth: true

                    theme: window.theme
                    icon: "battery_full"
                    title: "BATTERY HEALTH"

                    warning:
                        telemetry.batteryHealthPercent >= 0
                        && telemetry.batteryHealthPercent < 70

                    value:
                        telemetry.batteryHealthPercent >= 0
                            ? telemetry.batteryHealthPercent
                                + "%"
                            : "--"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight:
                    details.implicitHeight + 22

                radius: theme.radiusMedium
                color: theme.surfaceRaised

                ColumnLayout {
                    id: details

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 11
                    }

                    spacing: 7

                    DetailRow {
                        theme: window.theme
                        title: "CPU RANGE"
                        value:
                            telemetry.cpuMinGHz >= 0
                            && telemetry.cpuMaxGHz >= 0
                                ? telemetry.cpuMinGHz.toFixed(1)
                                    + " – "
                                    + telemetry.cpuMaxGHz.toFixed(1)
                                    + " GHz"
                                : "--"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "GOVERNOR"
                        value:
                            telemetry.cpuGovernor
                    }

                    DetailRow {
                        theme: window.theme
                        title: "RAM"
                        value:
                            telemetry.memoryUsedGiB >= 0
                                ? telemetry.memoryUsedGiB.toFixed(1)
                                    + " / "
                                    + telemetry.memoryTotalGiB.toFixed(1)
                                    + " GiB"
                                : "--"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "AVAILABLE"
                        value:
                            telemetry.memoryAvailableGiB >= 0
                                ? telemetry.memoryAvailableGiB.toFixed(1)
                                    + " GiB"
                                : "--"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "CACHE"
                        value:
                            telemetry.memoryCacheGiB >= 0
                                ? telemetry.memoryCacheGiB.toFixed(1)
                                    + " GiB"
                                : "--"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "SWAP"
                        value:
                            telemetry.swapTotalGiB > 0
                                ? telemetry.swapUsedGiB.toFixed(1)
                                    + " / "
                                    + telemetry.swapTotalGiB.toFixed(1)
                                    + " GiB  ·  "
                                    + telemetry.swapPercent
                                    + "%"
                                : "NONE"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "GPU RANGE"
                        value:
                            telemetry.gpuMinMHz >= 0
                            && telemetry.gpuMaxMHz >= 0
                                ? telemetry.gpuMinMHz
                                    + " – "
                                    + telemetry.gpuMaxMHz
                                    + " MHz"
                                : "--"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "BATTERY"
                        value:
                            telemetry.batteryStatus
                            + "  ·  "
                            + (
                                telemetry.batteryVoltageV >= 0
                                    ? telemetry.batteryVoltageV.toFixed(2)
                                        + " V"
                                    : "--"
                            )
                    }

                    DetailRow {
                        theme: window.theme
                        title: "BATTERY POWER"
                        value:
                            telemetry.batteryPowerW >= 0
                                ? telemetry.batteryPowerW.toFixed(1)
                                    + " W"
                                : "--"
                    }

                    DetailRow {
                        theme: window.theme
                        title: "CYCLES"
                        value:
                            telemetry.batteryCycles >= 0
                                ? String(
                                    telemetry.batteryCycles
                                )
                                : "--"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight:
                    storageContent.implicitHeight + 22

                radius: theme.radiusMedium
                color: theme.surfaceRaised

                ColumnLayout {
                    id: storageContent

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 11
                    }

                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true

                        Row {
                            Layout.fillWidth: true
                            spacing: 6

                            ArchIcon {
                                name: "hard_drive"
                                size: 14
                                color: theme.textMuted
                            }

                            Text {
                                text: "ROOT STORAGE"
                                color: theme.textMuted
                                font.family: "0xProto"
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            text:
                                telemetry.storagePercent >= 0
                                    ? telemetry.storagePercent
                                        + "%"
                                    : "--"

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5

                        radius: 3
                        color: "#20FFFFFF"

                        Rectangle {
                            height: parent.height
                            width:
                                telemetry.storagePercent >= 0
                                    ? parent.width
                                        * Math.min(
                                            telemetry.storagePercent,
                                            100
                                        )
                                        / 100
                                    : 0

                            radius: parent.radius
                            color: theme.accent
                        }
                    }

                    Text {
                        text:
                            telemetry.storageUsedGiB >= 0
                                ? telemetry.storageUsedGiB.toFixed(1)
                                    + " GiB used  ·  "
                                    + telemetry.storageAvailableGiB.toFixed(1)
                                    + " GiB available"
                                : "--"

                        color: theme.textSecondary
                        font.family: "0xProto"
                        font.pixelSize: 8
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Text {
                Layout.fillWidth: true

                text:
                    "2s telemetry  ·  kernel interfaces"

                horizontalAlignment:
                    Text.AlignRight

                color: theme.textMuted
                font.family: "0xProto"
                font.pixelSize: 7
            }
        }
    }

    component MetricCard: Rectangle {
        required property var theme

        property string icon: ""
        property string title: ""
        property string value: "--"
        property bool warning: false

        implicitHeight: 62

        radius: theme.radiusMedium
        color: theme.surfaceRaised

        Column {
            anchors.centerIn: parent
            spacing: 4

            Row {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                spacing: 5

                ArchIcon {
                    name: icon
                    size: 14

                    color:
                        warning
                            ? "#FF6B6B"
                            : theme.textMuted
                }

                Text {
                    text: title

                    color:
                        warning
                            ? "#FF6B6B"
                            : theme.textMuted

                    font.family: "0xProto"
                    font.pixelSize: 8
                }
            }

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                text: value

                color:
                    warning
                        ? "#FF6B6B"
                        : theme.textPrimary

                font.family: "0xProto"
                font.pixelSize: 13
                font.weight: Font.Medium
            }
        }
    }

    component DetailRow: RowLayout {
        required property var theme

        property string title: ""
        property string value: "--"

        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true

            text: title
            color: theme.textMuted

            font.family: "0xProto"
            font.pixelSize: 8
        }

        Text {
            text: value
            color: theme.textSecondary

            font.family: "0xProto"
            font.pixelSize: 8
        }
    }
}
