import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var shellScreen
    required property var theme
    required property var overview
    required property var workspaces
    required property var windows

    screen: shellScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    focusable: overview.open
    visible: overview.open
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus:
        overview.open
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

    readonly property var occupiedWorkspaceIds: {
        let serial = windows.serial
        let current = workspaces.currentId
        let ids = []

        for (let i = 1; i <= 10; ++i) {
            if (windows.windowsForWorkspace(i).length > 0 || i === current)
                ids.push(i)
        }

        return ids
    }

    function focusWindow(windowData) {
        overview.hide()
        workspaces.activate(windowData.workspaceId)
        windows.focusWindow(windowData.address)
    }

    function selectWorkspace(id) {
        overview.hide()
        workspaces.activate(id)
    }

    Rectangle {
        anchors.fill: parent
        color: "#EC080C10"

        MouseArea {
            anchors.fill: parent
            onClicked: overview.hide()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42

            Text {
                text: "GALAXY OVERVIEW"
                color: theme.textPrimary
                font.family: "0xProto"
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: windows.count + " WINDOWS  ·  SUPER+TAB"
                color: theme.textMuted
                font.family: "0xProto"
                font.pixelSize: 9
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46

            radius: 14
            color: theme.panelSurface
            border.width: 1
            border.color: theme.panelBorder

            Row {
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: 10

                    delegate: Rectangle {
                        required property int index

                        readonly property int workspaceId: index + 1
                        readonly property bool active:
                            workspaces.currentId === workspaceId

                        readonly property int count: {
                            let serial = windows.serial
                            return windows
                                .windowsForWorkspace(workspaceId)
                                .length
                        }

                        width: active ? 48 : 38
                        height: 28
                        radius: 8

                        color:
                            active
                                ? "#30FFFFFF"
                                : mouse.containsMouse
                                    ? "#18FFFFFF"
                                    : "transparent"

                        border.width: active ? 1 : 0
                        border.color: theme.panelBorder

                        Text {
                            anchors.centerIn: parent

                            text:
                                count > 0
                                    ? workspaceId + " · " + count
                                    : workspaceId

                            color:
                                active
                                    ? theme.textPrimary
                                    : count > 0
                                        ? theme.textSecondary
                                        : theme.textMuted

                            font.family: "0xProto"
                            font.pixelSize: 9
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                root.selectWorkspace(workspaceId)
                        }
                    }
                }
            }
        }

        GridView {
            id: workspaceGrid

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: root.occupiedWorkspaceIds

            readonly property int columns:
                count <= 2 ? Math.max(1, count) : 2

            readonly property int rows:
                Math.max(1, Math.ceil(count / columns))

            cellWidth: width / columns
            cellHeight: height / rows

            delegate: Item {
                id: workspaceDelegate

                required property int modelData

                width: workspaceGrid.cellWidth
                height: workspaceGrid.cellHeight

                readonly property int workspaceId: modelData

                Rectangle {
                    id: workspaceCard

                    anchors.fill: parent
                    anchors.margins: 7

                    radius: theme.radiusPanel
                    color: theme.panelSurface

                    border.width: 1
                    border.color:
                        workspaces.currentId
                            === workspaceDelegate.workspaceId
                                ? theme.accent
                                : theme.panelBorder

                    Rectangle {
                        id: header

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }

                        height: 38
                        radius: workspaceCard.radius

                        color: "#10FFFFFF"

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 14
                                verticalCenter: parent.verticalCenter
                            }

                            text:
                                "WORKSPACE "
                                + workspaceDelegate.workspaceId

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors {
                                right: parent.right
                                rightMargin: 14
                                verticalCenter: parent.verticalCenter
                            }

                            text:
                                windows.windowsForWorkspace(
                                    workspaceDelegate.workspaceId
                                ).length + " WINDOWS"

                            color: theme.textMuted
                            font.family: "0xProto"
                            font.pixelSize: 8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                root.selectWorkspace(
                                    workspaceDelegate.workspaceId
                                )
                        }
                    }

                    Item {
                        id: desktop

                        anchors {
                            top: header.bottom
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            margins: 12
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: "#16000000"
                            border.width: 1
                            border.color: "#18FFFFFF"
                        }

                        Repeater {
                            model: {
                                let serial = windows.serial
                                return windows.windowsForWorkspace(
                                    workspaceDelegate.workspaceId
                                )
                            }

                            delegate: Rectangle {
                                id: windowCard

                                required property var modelData

                                readonly property real sx:
                                    desktop.width
                                    / Math.max(1, shellScreen.width)

                                readonly property real sy:
                                    desktop.height
                                    / Math.max(1, shellScreen.height)

                                x: Math.max(
                                    4,
                                    modelData.x * sx
                                )

                                y: Math.max(
                                    4,
                                    modelData.y * sy
                                )

                                width: Math.max(
                                    90,
                                    Math.min(
                                        desktop.width - x - 4,
                                        modelData.width * sx
                                    )
                                )

                                height: Math.max(
                                    54,
                                    Math.min(
                                        desktop.height - y - 4,
                                        modelData.height * sy
                                    )
                                )

                                radius: 9

                                color:
                                    windowMouse.containsMouse
                                        ? "#38FFFFFF"
                                        : "#24FFFFFF"

                                border.width: modelData.focused ? 2 : 1

                                border.color:
                                    modelData.focused
                                        ? theme.accent
                                        : theme.cardBorder

                                Column {
                                    anchors {
                                        fill: parent
                                        margins: 8
                                    }

                                    spacing: 3

                                    Row {
                                        width: parent.width
                                        spacing: 6

                                        Rectangle {
                                            width: 22
                                            height: 22
                                            radius: 6
                                            color: "#28FFFFFF"

                                            Text {
                                                anchors.centerIn: parent

                                                text:
                                                    modelData.className.length
                                                        > 0
                                                        ? modelData
                                                            .className[0]
                                                            .toUpperCase()
                                                        : "?"

                                                color: theme.textPrimary
                                                font.family: "0xProto"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                            }
                                        }

                                        Text {
                                            width:
                                                parent.width - 30

                                            text:
                                                modelData.className
                                                    || "Window"

                                            color: theme.textPrimary
                                            elide: Text.ElideRight

                                            font.family: "0xProto"
                                            font.pixelSize: 9
                                            font.weight: Font.DemiBold
                                        }
                                    }

                                    Text {
                                        width: parent.width

                                        text: modelData.title

                                        visible:
                                            windowCard.height > 72

                                        color: theme.textSecondary
                                        elide: Text.ElideRight

                                        font.family: "0xProto"
                                        font.pixelSize: 8
                                    }
                                }

                                MouseArea {
                                    id: windowMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked:
                                        root.focusWindow(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: overview.open
        onActivated: overview.hide()
    }
}
