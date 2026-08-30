import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"

PanelWindow {
    id: root

    required property var shellScreen
    required property var theme
    required property var session

    screen: shellScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    focusable: session.open
    visible: session.open
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus:
        session.open
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: "#D9080C10"

        MouseArea {
            anchors.fill: parent
            onClicked: session.hide()
        }
    }

    Rectangle {
        width: 590
        height: session.pendingAction === "" ? 230 : 285
        anchors.centerIn: parent

        radius: theme.radiusPanel
        color: theme.panelSurface
        border.width: 1
        border.color: theme.panelBorder

        Behavior on height {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "ARCHMAC"
                    color: theme.textPrimary
                    font.family: "0xProto"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "SESSION"
                    color: theme.textMuted
                    font.family: "0xProto"
                    font.pixelSize: 9
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 9

                Repeater {
                    model: [
                        { name: "Lock", icon: "lock", action: "lock" },
                        { name: "Sleep", icon: "bedtime", action: "sleep" },
                        { name: "Logout", icon: "logout", action: "logout" },
                        { name: "Restart", icon: "restart_alt", action: "reboot" },
                        { name: "Shut down", icon: "power_settings_new", action: "shutdown" }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        radius: 13

                        color:
                            actionMouse.containsMouse
                                ? "#2CFFFFFF"
                                : "#14FFFFFF"

                        border.width:
                            session.pendingAction === modelData.action
                                ? 1 : 0

                        border.color: theme.panelBorder

                        Column {
                            anchors.centerIn: parent
                            spacing: 9

                            ArchIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.icon
                                size: 25
                                color: theme.textPrimary
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.name
                                color: theme.textSecondary
                                font.family: "0xProto"
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: session.request(modelData.action)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight:
                    session.pendingAction === "" ? 0 : 52

                visible: session.pendingAction !== ""
                radius: 11
                color: "#16FFFFFF"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 8

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Confirm "
                            + session.pendingAction.toUpperCase()
                            + "?"

                        color: theme.textSecondary
                        font.family: "0xProto"
                        font.pixelSize: 9
                    }

                    Rectangle {
                        width: 76
                        height: 32
                        radius: 9
                        color: "#18FFFFFF"

                        Text {
                            anchors.centerIn: parent
                            text: "CANCEL"
                            color: theme.textSecondary
                            font.family: "0xProto"
                            font.pixelSize: 8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: session.cancel()
                        }
                    }

                    Rectangle {
                        width: 82
                        height: 32
                        radius: 9
                        color: "#30FFFFFF"
                        border.width: 1
                        border.color: theme.panelBorder

                        Text {
                            anchors.centerIn: parent
                            text: "CONFIRM"
                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 8
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: session.confirm()
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: session.open
        onActivated: session.hide()
    }
}
