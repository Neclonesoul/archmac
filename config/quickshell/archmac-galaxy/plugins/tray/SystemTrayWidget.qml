import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: tray

    required property var theme
    required property var hostWindow

    implicitWidth: row.implicitWidth
    implicitHeight: 22

    Row {
        id: row

        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: trayItem

                required property var modelData

                width: 22
                height: 22

                radius: theme.radiusSmall

                color: mouse.containsMouse
                    ? "#20FFFFFF"
                    : "transparent"

                Image {
                    anchors.centerIn: parent

                    width: 15
                    height: 15

                    source: trayItem.modelData.icon

                    sourceSize.width: width
                    sourceSize.height: height

                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent

                    hoverEnabled: true

                    acceptedButtons:
                        Qt.LeftButton
                        | Qt.RightButton
                        | Qt.MiddleButton

                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        const item = trayItem.modelData

                        if (mouse.button === Qt.MiddleButton) {
                            item.secondaryActivate()
                            return
                        }

                        if (mouse.button === Qt.RightButton) {
                            if (item.hasMenu) {
                                item.display(
                                    tray.hostWindow,
                                    trayItem.x,
                                    trayItem.y + trayItem.height
                                )
                            }

                            return
                        }

                        if (item.onlyMenu && item.hasMenu) {
                            item.display(
                                tray.hostWindow,
                                trayItem.x,
                                trayItem.y + trayItem.height
                            )
                        } else {
                            item.activate()
                        }
                    }

                    onWheel: wheel => {
                        trayItem.modelData.scroll(
                            wheel.angleDelta.y,
                            false
                        )
                    }
                }
            }
        }
    }
}
