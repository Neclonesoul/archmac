import QtQuick
import QtQuick.Layouts

import Quickshell

import "../workspaces"

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
    required property var clock

    screen: shellScreen

    anchors {
        left: true
        right: true
        bottom: true
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
            }

            Rectangle {
                id: audioCapsule

                implicitWidth: audioText.implicitWidth + 16
                implicitHeight: 22

                radius: theme.radiusSmall

                color: audioMouse.containsMouse
                    ? "#20FFFFFF"
                    : theme.surfaceRaised

                Text {
                    id: audioText

                    anchors.centerIn: parent

                    text: audio.shortLabel

                    color: audio.muted
                        ? theme.textMuted
                        : theme.textSecondary

                    font.family: "0xProto"
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: audioMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            audio.toggleMute()
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
                implicitWidth: batteryText.implicitWidth + 16
                implicitHeight: 22

                radius: theme.radiusSmall

                color: theme.surfaceRaised

                Text {
                    id: batteryText

                    anchors.centerIn: parent

                    text: power.shortLabel

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

            Rectangle {
                implicitWidth: modeLabel.implicitWidth + 16
                implicitHeight: 22

                radius: theme.radiusSmall
                color: theme.surfaceRaised

                Text {
                    id: modeLabel

                    anchors.centerIn: parent

                    text: mode.current.toUpperCase()

                    color: theme.textSecondary
                    font.family: "0xProto"
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
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
