import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Bluetooth

PanelWindow {
    id: panel

    required property var shellScreen
    required property var theme
    required property var bluetooth

    property bool opened: false
    property bool discoveryHeld: false

    signal closeRequested()

    screen: shellScreen
    visible: opened

    anchors {
        top: true
        right: true
    }

    margins {
        top: 40
        right: 8
    }

    implicitWidth: 360
    implicitHeight: 430

    exclusiveZone: 0
    aboveWindows: true

    color: "transparent"

    function acquireDiscovery() {
        if (discoveryHeld)
            return

        bluetooth.acquireDiscovery()
        discoveryHeld = true
    }

    function releaseDiscovery() {
        if (!discoveryHeld)
            return

        bluetooth.releaseDiscovery()
        discoveryHeld = false
    }

    onOpenedChanged: {
        if (opened)
            acquireDiscovery()
        else
            releaseDiscovery()
    }

    Component.onDestruction:
        releaseDiscovery()

    Rectangle {
        anchors.fill: parent

        radius: theme.radiusLarge + 5
        color: theme.surfaceOverlay

        border.width: 1
        border.color: theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Column {
                    spacing: 2

                    Text {
                        text: "BLUETOOTH"

                        color: theme.textPrimary

                        font.family: "0xProto"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.8
                    }

                    Text {
                        text: {
                            if (!bluetooth.available)
                                return "No adapter"

                            if (!bluetooth.enabled)
                                return "Bluetooth off"

                            if (bluetooth.connectedDevices > 0)
                                return bluetooth.connectedDevices
                                    + " connected"

                            return bluetooth.discovering
                                ? "Scanning"
                                : "Ready"
                        }

                        color: theme.textMuted
                        font.pixelSize: 9
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "×"

                    color: closeMouse.containsMouse
                        ? theme.textPrimary
                        : theme.textMuted

                    font.pixelSize: 20

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

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48

                radius: theme.radiusMedium

                color: bluetooth.enabled
                    ? "#283EA6FF"
                    : theme.surfaceRaised

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    Text {
                        text: "Bluetooth"

                        color: theme.textPrimary
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text:
                            bluetooth.enabled
                                ? "ON"
                                : "OFF"

                        color: theme.textSecondary
                        font.family: "0xProto"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
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

            Text {
                text:
                    bluetooth.discovering
                        ? "DEVICES · SCANNING"
                        : "DEVICES"

                visible: bluetooth.enabled

                color: theme.textMuted
                font.pixelSize: 8
                font.letterSpacing: 0.7
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    bluetooth.enabled
                    && bluetooth.devices !== null

                clip: true
                spacing: 4

                model: bluetooth.devices

                delegate: Rectangle {
                    id: deviceRow

                    required property var modelData

                    width: ListView.view.width
                    height: 54

                    radius: theme.radiusMedium

                    color:
                        modelData.connected
                            ? "#203EA6FF"
                            : rowMouse.containsMouse
                                ? "#18FFFFFF"
                                : theme.surfaceRaised

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 11
                        anchors.rightMargin: 11
                        spacing: 9

                        Image {
                            width: 18
                            height: 18

                            source:
                                modelData.icon
                                    ? Quickshell.iconPath(
                                        modelData.icon
                                      )
                                    : ""

                            fillMode:
                                Image.PreserveAspectFit
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                width: 200

                                text:
                                    modelData.name
                                    || modelData.deviceName
                                    || modelData.address

                                elide: Text.ElideRight

                                color: theme.textPrimary
                                font.pixelSize: 10

                                font.weight:
                                    modelData.connected
                                        ? Font.DemiBold
                                        : Font.Normal
                            }

                            Text {
                                text: {
                                    let parts = []

                                    if (modelData.connected)
                                        parts.push("connected")
                                    else if (modelData.pairing)
                                        parts.push("pairing")
                                    else if (modelData.paired)
                                        parts.push("paired")
                                    else
                                        parts.push("available")

                                    if (modelData.trusted)
                                        parts.push("trusted")

                                    if (modelData.batteryAvailable) {
                                        parts.push(
                                            Math.round(
                                                modelData.battery
                                                * 100
                                            )
                                            + "%"
                                        )
                                    }

                                    return parts.join(" · ")
                                }

                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            text: {
                                if (modelData.pairing)
                                    return "CANCEL"

                                if (modelData.connected)
                                    return "DISCONNECT"

                                if (modelData.paired)
                                    return "CONNECT"

                                return "PAIR"
                            }

                            color:
                                modelData.connected
                                    ? theme.accent
                                    : theme.textSecondary

                            font.family: "0xProto"
                            font.pixelSize: 8
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        id: rowMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            const d = deviceRow.modelData

                            if (d.pairing) {
                                bluetooth.cancelPair(d)
                                return
                            }

                            if (d.connected) {
                                bluetooth.disconnectDevice(d)
                                return
                            }

                            if (d.paired) {
                                bluetooth.connectDevice(d)
                                return
                            }

                            bluetooth.pairDevice(d)
                        }
                    }
                }
            }

            Text {
                Layout.alignment:
                    Qt.AlignHCenter

                text:
                    bluetooth.discoveryUsers > 0
                        ? "BLUEZ · DISCOVERY ACTIVE"
                        : "BLUEZ"

                color: "#59616C"
                font.pixelSize: 8
                font.letterSpacing: 1
            }
        }
    }
}
