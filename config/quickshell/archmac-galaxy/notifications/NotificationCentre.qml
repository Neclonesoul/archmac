import QtQuick
import QtQuick.Layouts

import Quickshell

import "../components"

PanelWindow {
    id: window

    required property var shellScreen
    required property var theme
    required property var notifications

    screen: shellScreen

    anchors {
        top: true
        right: true
    }

    margins {
        top: 42
        right: 8
    }

    implicitWidth: 340
    implicitHeight: 520

    exclusionMode: ExclusionMode.Ignore
    focusable: false
    aboveWindows: true

    color: "transparent"

    visible: notifications.centreOpen

    Rectangle {
        anchors.fill: parent

        radius: 12

        color: "#F011171C"

        border.width: 1
        border.color: "#405C7484"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12

            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true

                    text: "NOTIFICATIONS"

                    color: theme.textPrimary

                    font.family: "0xProto"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }

                Text {
                    visible:
                        notifications.count > 0

                    text: "CLEAR"

                    color: theme.textMuted

                    font.family: "0xProto"
                    font.pixelSize: 8

                    TapHandler {
                        onTapped:
                            notifications.dismissAll()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

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
                            notifications.closeCentre()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1

                color: "#24FFFFFF"
            }

            Text {
                visible:
                    notifications.count === 0

                Layout.fillWidth: true
                Layout.fillHeight: true

                text: "No notifications"

                color: theme.textMuted

                horizontalAlignment:
                    Text.AlignHCenter

                verticalAlignment:
                    Text.AlignVCenter

                font.family: "0xProto"
                font.pixelSize: 9
            }

            ListView {
                visible:
                    notifications.count > 0

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 8
                clip: true

                model:
                    notifications.notifications

                delegate: Rectangle {
                    required property var modelData

                    width:
                        ListView.view.width

                    implicitHeight:
                        cardContent.implicitHeight
                        + 20

                    radius: 9

                    color: "#C91A232A"

                    border.width: 1
                    border.color: "#30485A66"

                    ColumnLayout {
                        id: cardContent

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 10
                        }

                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true

                                text:
                                    modelData.appName !== ""
                                        ? modelData.appName
                                        : "NOTIFICATION"

                                color: theme.textMuted

                                font.family: "0xProto"
                                font.pixelSize: 7

                                elide:
                                    Text.ElideRight
                            }

                            ArchIcon {
                                name: "close"
                                size: 14

                                color: theme.textMuted

                                TapHandler {
                                    onTapped:
                                        notifications.dismiss(
                                            modelData
                                        )
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                modelData.summary

                            color: theme.textPrimary

                            font.family: "0xProto"
                            font.pixelSize: 9
                            font.weight:
                                Font.DemiBold

                            wrapMode: Text.Wrap
                        }

                        Text {
                            visible:
                                modelData.body !== ""

                            Layout.fillWidth: true

                            text:
                                modelData.body

                            color:
                                theme.textSecondary

                            font.pixelSize: 8

                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }
}
