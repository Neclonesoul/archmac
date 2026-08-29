import QtQuick
import QtQuick.Layouts

import Quickshell

import "../components"

PanelWindow {
    id: window

    required property var shellScreen
    required property var theme
    required property var osd

    screen: shellScreen

    anchors {
        top: true
    }

    margins {
        top: 50
    }

    implicitWidth: 300
    implicitHeight: 68

    exclusionMode:
        ExclusionMode.Ignore

    focusable: false
    aboveWindows: true

    color: "transparent"

    visible: osd.visible

    Rectangle {
        anchors.fill: parent

        radius: 11

        color: "#E611171C"

        border.width: 1
        border.color: "#405C7484"

        opacity:
            osd.visible
                ? 1
                : 0

        scale:
            osd.visible
                ? 1
                : 0.96

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type:
                    Easing.OutCubic
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 13

            spacing: 12

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38

                radius: 9

                color: "#203EA6FF"

                ArchIcon {
                    anchors.centerIn:
                        parent

                    name: {
                        switch (
                            osd.kind
                        ) {
                        case "mute":
                            return "volume_off"

                        case "brightness":
                            return "brightness_6"

                        case "mode":
                            return "tune"

                        default:
                            return "volume_up"
                        }
                    }

                    size: 20

                    color:
                        theme.textPrimary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true

                        text: osd.title

                        color:
                            theme.textPrimary

                        font.family:
                            "0xProto"

                        font.pixelSize: 10

                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        visible:
                            osd.showProgress
                            && osd.detail !== ""

                        text:
                            osd.detail

                        color:
                            theme.textSecondary

                        font.family:
                            "0xProto"

                        font.pixelSize: 9
                    }
                }

                Rectangle {
                    visible:
                        osd.showProgress

                    Layout.fillWidth: true
                    Layout.preferredHeight: 5

                    radius: 3

                    color:
                        "#28FFFFFF"

                    Rectangle {
                        height:
                            parent.height

                        width:
                            parent.width
                            * Math.max(
                                0,
                                Math.min(
                                    1,
                                    osd.value
                                )
                            )

                        radius:
                            parent.radius

                        color:
                            theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 75

                                easing.type:
                                    Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    visible:
                        !osd.showProgress
                        && osd.detail !== ""

                    Layout.fillWidth: true

                    text:
                        osd.detail

                    color:
                        theme.textMuted

                    font.pixelSize: 8

                    elide:
                        Text.ElideRight
                }
            }
        }
    }
}
