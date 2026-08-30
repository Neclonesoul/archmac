import QtQuick
import QtQuick.Layouts

import Quickshell

import "../../components"

PanelWindow {
    id: panel

    required property var theme
    required property var audio
    required property var power
    required property var brightness
    required property var telemetry
    required property var media
    required property var network
    required property var bluetooth
    required property var mode

    property bool opened: false

    signal closeRequested()

    visible: opened

    anchors {
        top: true
        right: true
    }

    margins {
        top: 40
        right: 8
    }

    implicitWidth: 350
    implicitHeight: media.available ? 500 : 420

    exclusiveZone: 0
    aboveWindows: true

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        radius: theme.radiusPanel
        color: theme.surfaceOverlay

        border.width: 1
        border.color: theme.border

        opacity: panel.opened ? 1 : 0
        scale: panel.opened ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation {
                duration: 130
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 13

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "SYSTEM"

                    color: theme.textPrimary

                    font.family: "0xProto"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }

                Item {
                    Layout.fillWidth: true
                }

                ArchIcon {
                    name: "close"
                    size: 18

                    color:
                        closeMouse.containsMouse
                            ? theme.textPrimary
                            : theme.textMuted

                    MouseArea {
                        id: closeMouse

                        anchors.fill: parent
                        anchors.margins: -8

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            panel.closeRequested()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#20FFFFFF"
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "VOLUME"
                    color: theme.textMuted
                    font.pixelSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: audio.shortLabel
                    color: theme.textPrimary
                    font.family: "0xProto"
                    font.pixelSize: 10

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6

                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            audio.toggleMute()
                    }
                }
            }

            Rectangle {
                id: volumeTrack

                Layout.fillWidth: true
                implicitHeight: 9

                radius: 5
                color: "#22FFFFFF"

                Rectangle {
                    height: parent.height
                    radius: parent.radius

                    width:
                        audio.volume >= 0
                            ? parent.width
                              * Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        audio.volume / 100
                                    )
                                )
                            : 0

                    color: theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    function apply(x) {
                        audio.setVolume(
                            Math.max(
                                0,
                                Math.min(1, x / width)
                            )
                        )
                    }

                    onPressed:
                        mouse => apply(mouse.x)

                    onPositionChanged: mouse => {
                        if (pressed)
                            apply(mouse.x)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "BRIGHTNESS"
                    color: theme.textMuted
                    font.pixelSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text:
                        brightness.percentage >= 0
                            ? brightness.percentage + "%"
                            : "--"

                    color: theme.textPrimary
                    font.family: "0xProto"
                    font.pixelSize: 10
                }
            }

            Rectangle {
                id: brightnessTrack

                Layout.fillWidth: true
                implicitHeight: 9

                radius: 5
                color: "#22FFFFFF"

                Rectangle {
                    height: parent.height
                    radius: parent.radius

                    width:
                        brightness.percentage >= 0
                            ? parent.width
                              * brightness.percentage / 100
                            : 0

                    color: theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    function apply(x) {
                        brightness.setPercentage(
                            x / width * 100
                        )
                    }

                    onPressed:
                        mouse => apply(mouse.x)

                    onPositionChanged: mouse => {
                        if (pressed)
                            apply(mouse.x)
                    }
                }
            }

            Text {
                text: "MODE"

                color: theme.textMuted
                font.pixelSize: 8
                font.letterSpacing: 0.7
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        "fancy",
                        "balanced",
                        "performance",
                        "battery"
                    ]

                    delegate: Rectangle {
                        required property string modelData

                        Layout.fillWidth: true
                        implicitHeight: 42

                        radius: theme.radiusMedium

                        color:
                            mode.current === modelData
                                ? "#283EA6FF"
                                : theme.surfaceRaised

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                anchors.horizontalCenter:
                                    parent.horizontalCenter

                                text:
                                    modelData.toUpperCase()

                                color:
                                    mode.current === modelData
                                        ? theme.textPrimary
                                        : theme.textSecondary

                                font.family: "0xProto"
                                font.pixelSize: 7
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                mode.apply(modelData)
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true

                text: mode.description

                color: theme.textMuted
                font.pixelSize: 8
            }

            Text {
                text: "CONNECTIVITY"

                color: theme.textMuted
                font.pixelSize: 8
                font.letterSpacing: 0.7
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 58

                    radius: theme.radiusMedium

                    color:
                        network.wifiEnabled
                            ? "#203EA6FF"
                            : theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 4

                            ArchIcon {
                                name:
                                    network.wifiEnabled
                                        ? "wifi"
                                        : "wifi_off"

                                size: 14
                                color: theme.textMuted
                            }

                            Text {
                                text: "WI-FI"
                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: {
                                if (!network.wifiEnabled)
                                    return "OFF"

                                if (network.wifiConnected)
                                    return network.signalPercent + "%"

                                return "ON"
                            }

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            width: 130

                            text:
                                network.wifiConnected
                                    ? network.ssid
                                    : network.detailLabel

                            elide: Text.ElideRight
                            horizontalAlignment:
                                Text.AlignHCenter

                            color: theme.textMuted
                            font.pixelSize: 7
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            network.toggleWifi()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 58

                    radius: theme.radiusMedium

                    color:
                        bluetooth.enabled
                            ? "#203EA6FF"
                            : theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 4

                            ArchIcon {
                                name:
                                    bluetooth.enabled
                                        ? "bluetooth"
                                        : "bluetooth_disabled"

                                size: 14
                                color: theme.textMuted
                            }

                            Text {
                                text: "BLUETOOTH"
                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: {
                                if (!bluetooth.available)
                                    return "--"

                                if (!bluetooth.enabled)
                                    return "OFF"

                                if (bluetooth.connectedDevices > 0)
                                    return bluetooth.connectedDevices
                                        + " CONNECTED"

                                return "ON"
                            }

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                bluetooth.enabled
                                    ? "BlueZ"
                                    : "Radio disabled"

                            color: theme.textMuted
                            font.pixelSize: 7
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            bluetooth.toggleEnabled()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52

                    radius: theme.radiusMedium
                    color: theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 4

                            ArchIcon {
                                name: "memory"
                                size: 14
                                color: theme.textMuted
                            }

                            Text {
                                text: "CPU"
                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                telemetry.cpuPercent >= 0
                                    ? telemetry.cpuPercent + "%"
                                    : "--"

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 13
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52

                    radius: theme.radiusMedium
                    color: theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 4

                            ArchIcon {
                                name: "developer_board"
                                size: 14
                                color: theme.textMuted
                            }

                            Text {
                                text: "MEMORY"
                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                telemetry.memoryPercent >= 0
                                    ? telemetry.memoryPercent + "%"
                                    : "--"

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 13
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52

                    radius: theme.radiusMedium
                    color: theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 4

                            ArchIcon {
                                name: "thermostat"
                                size: 14

                                color:
                                    telemetry.temperatureC >= 85
                                        ? "#FF6B6B"
                                        : theme.textMuted
                            }

                            Text {
                                text: "TEMP"

                                color:
                                    telemetry.temperatureC >= 85
                                        ? "#FF6B6B"
                                        : theme.textMuted

                                font.pixelSize: 8
                            }
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                telemetry.temperatureC >= 0
                                    ? telemetry.temperatureC + "°C"
                                    : "--"

                            color:
                                telemetry.temperatureC >= 85
                                    ? "#FF6B6B"
                                    : theme.textPrimary

                            font.family: "0xProto"
                            font.pixelSize: 13
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 52

                    radius: theme.radiusMedium
                    color: theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: 4

                            ArchIcon {
                                name:
                                    power.charging
                                        ? "battery_charging_full"
                                        : "battery_full"

                                size: 14
                                color: theme.textMuted
                            }

                            Text {
                                text: "BATTERY"
                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                power.percentage >= 0
                                    ? power.percentage + "%"
                                    : "--"

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 13
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: media.available ? 74 : 0

                visible: media.available

                radius: theme.radiusMedium
                color: theme.surfaceRaised

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 11
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true

                            text: media.title

                            elide: Text.ElideRight

                            color: theme.textPrimary
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text: media.artist

                            elide: Text.ElideRight

                            color: theme.textMuted
                            font.pixelSize: 9
                        }
                    }

                    ArchIcon {
                        name: "skip_previous"
                        size: 21
                        color: theme.textSecondary

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            cursorShape: Qt.PointingHandCursor
                            onClicked: media.previous()
                        }
                    }

                    ArchIcon {
                        name:
                            media.playing
                                ? "pause"
                                : "play_arrow"

                        size: 21
                        color: theme.textPrimary

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            cursorShape: Qt.PointingHandCursor
                            onClicked: media.toggle()
                        }
                    }

                    ArchIcon {
                        name: "skip_next"
                        size: 21
                        color: theme.textSecondary

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -7
                            cursorShape: Qt.PointingHandCursor
                            onClicked: media.next()
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter

                text: "ARCHMAC · GALAXY"

                color: "#59616C"
                font.pixelSize: 8
                font.letterSpacing: 1.2
            }
        }
    }
}
