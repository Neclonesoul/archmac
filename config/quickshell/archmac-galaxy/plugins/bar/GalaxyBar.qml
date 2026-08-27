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
            spacing: 8

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

            Text {
                text: {
                    if (workspaces.direction > 0)
                        return "→"
                    if (workspaces.direction < 0)
                        return "←"

                    return "·"
                }

                color: theme.textMuted
                font.pixelSize: 12

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Text {
                text: hardware.model

                color: theme.textMuted
                font.family: "0xProto"
                font.pixelSize: 9
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
