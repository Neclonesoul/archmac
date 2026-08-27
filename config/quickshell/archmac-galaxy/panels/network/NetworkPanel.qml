import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Networking

PanelWindow {
    id: panel

    required property var shellScreen
    required property var theme
    required property var network

    property bool opened: false
    property bool scannerHeld: false

    property var selectedNetwork: null
    property bool passwordMode: false
    property string statusMessage: ""

    signal closeRequested()

    screen: shellScreen
    visible: opened
    focusable: opened

    anchors {
        top: true
        right: true
    }

    margins {
        top: 40
        right: 8
    }

    implicitWidth: 360
    implicitHeight: 440

    exclusiveZone: 0
    aboveWindows: true

    color: "transparent"

    function acquireScanner() {
        if (scannerHeld)
            return

        network.acquireScanner()
        scannerHeld = true
    }

    function releaseScanner() {
        if (!scannerHeld)
            return

        network.releaseScanner()
        scannerHeld = false
    }

    function beginConnect(net) {
        if (!net)
            return

        statusMessage = ""

        /*
         * Saved networks and open networks can be attempted
         * without asking the user for credentials.
         */
        if (net.known
                || net.security === WifiSecurityType.Open) {
            network.connectNetwork(net)
            return
        }

        /*
         * Phase 4B supports normal personal PSK networks.
         * Enterprise Wi-Fi gets a clear fallback instead of
         * pretending we implement 802.1X already.
         */
        if (net.security === WifiSecurityType.WpaPsk
                || net.security === WifiSecurityType.Wpa2Psk
                || net.security === WifiSecurityType.Sae) {
            selectedNetwork = net
            passwordMode = true

            passwordInput.text = ""
            passwordInput.forceActiveFocus()
            return
        }

        statusMessage =
            "Enterprise/special Wi-Fi: use nmtui for now."
    }

    function submitPassword() {
        if (!selectedNetwork)
            return

        if (passwordInput.text.length < 1)
            return

        network.connectWithPsk(
            selectedNetwork,
            passwordInput.text
        )

        passwordInput.text = ""
        passwordMode = false
        selectedNetwork = null
    }

    onOpenedChanged: {
        if (opened)
            acquireScanner()
        else {
            releaseScanner()

            passwordMode = false
            selectedNetwork = null
            passwordInput.text = ""
        }
    }

    Component.onDestruction:
        releaseScanner()

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
                        text: "NETWORK"

                        color: theme.textPrimary

                        font.family: "0xProto"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.8
                    }

                    Text {
                        text: network.detailLabel

                        color: theme.textMuted
                        font.pixelSize: 9

                        elide: Text.ElideRight
                        width: 240
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48

                    radius: theme.radiusMedium

                    color: network.wifiEnabled
                        ? "#283EA6FF"
                        : theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "WI-FI"

                            color: theme.textMuted
                            font.pixelSize: 8
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                network.wifiEnabled
                                    ? "ON"
                                    : "OFF"

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
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
                    implicitHeight: 48

                    radius: theme.radiusMedium
                    color: theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "SIGNAL"

                            color: theme.textMuted
                            font.pixelSize: 8
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                network.wifiConnected
                                    ? network.signalPercent + "%"
                                    : "--"

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48

                    radius: theme.radiusMedium
                    color: theme.surfaceRaised

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "STATE"

                            color: theme.textMuted
                            font.pixelSize: 8
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                network.connectionType
                                    .toUpperCase()

                            color: theme.textPrimary
                            font.family: "0xProto"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 46

                visible: network.wifiConnected

                radius: theme.radiusMedium
                color: "#153EA6FF"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    Column {
                        Layout.fillWidth: true

                        Text {
                            width: 210

                            text: network.ssid

                            elide: Text.ElideRight

                            color: theme.textPrimary
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text:
                                "Connected · "
                                + network.signalPercent
                                + "%"

                            color: theme.textMuted
                            font.pixelSize: 8
                        }
                    }

                    Text {
                        text: "DISCONNECT"

                        color: theme.textSecondary

                        font.family: "0xProto"
                        font.pixelSize: 8
                        font.weight: Font.DemiBold

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                network.disconnectWifi()
                        }
                    }
                }
            }

            Text {
                text: "AVAILABLE NETWORKS"

                visible:
                    network.wifiEnabled
                    && network.wifiDevice !== null

                color: theme.textMuted
                font.pixelSize: 8
                font.letterSpacing: 0.7
            }

            ListView {
                id: networkList

                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    network.wifiEnabled
                    && network.wifiDevice !== null
                    && !panel.passwordMode

                clip: true
                spacing: 4

                model:
                    network.wifiDevice
                        ? network.wifiDevice.networks
                        : null

                delegate: Rectangle {
                    id: networkRow

                    required property var modelData

                    width: ListView.view.width
                    height: 44

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

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                width: 220

                                text:
                                    networkRow.modelData.name
                                    || "<hidden>"

                                elide: Text.ElideRight

                                color: theme.textPrimary

                                font.pixelSize: 10
                                font.weight:
                                    networkRow.modelData.connected
                                        ? Font.DemiBold
                                        : Font.Normal
                            }

                            Text {
                                text: {
                                    const strength =
                                        Math.round(
                                            networkRow
                                                .modelData
                                                .signalStrength
                                            * 100
                                        )

                                    const saved =
                                        networkRow
                                            .modelData
                                            .known
                                            ? "saved · "
                                            : ""

                                    return saved
                                        + strength
                                        + "%"
                                }

                                color: theme.textMuted
                                font.pixelSize: 8
                            }
                        }

                        Text {
                            text: {
                                if (networkRow.modelData.connected)
                                    return "CONNECTED"

                                if (networkRow.modelData.stateChanging)
                                    return "CONNECTING"

                                if (networkRow.modelData.security
                                        === WifiSecurityType.Open)
                                    return "OPEN"

                                return "SECURE"
                            }

                            color:
                                networkRow.modelData.connected
                                    ? theme.accent
                                    : theme.textMuted

                            font.family: "0xProto"
                            font.pixelSize: 8
                        }
                    }

                    MouseArea {
                        id: rowMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        enabled:
                            !networkRow.modelData.connected
                            && !networkRow.modelData.stateChanging

                        onClicked:
                            panel.beginConnect(
                                networkRow.modelData
                            )
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: panel.passwordMode

                spacing: 12

                Text {
                    text:
                        panel.selectedNetwork
                            ? "JOIN "
                              + panel.selectedNetwork.name
                            : "JOIN NETWORK"

                    color: theme.textPrimary

                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 40

                    radius: theme.radiusMedium

                    color: theme.surfaceRaised

                    border.width:
                        passwordInput.activeFocus
                            ? 1
                            : 0

                    border.color: theme.accent

                    TextInput {
                        id: passwordInput

                        anchors.fill: parent
                        anchors.margins: 10

                        verticalAlignment:
                            TextInput.AlignVCenter

                        echoMode:
                            TextInput.Password

                        color: theme.textPrimary

                        font.family: "0xProto"
                        font.pixelSize: 11

                        clip: true

                        onAccepted:
                            panel.submitPassword()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38

                        radius: theme.radiusMedium
                        color: theme.surfaceRaised

                        Text {
                            anchors.centerIn: parent

                            text: "CANCEL"

                            color: theme.textSecondary
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                panel.passwordMode = false
                                panel.selectedNetwork = null
                                passwordInput.text = ""
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38

                        radius: theme.radiusMedium
                        color: "#303EA6FF"

                        Text {
                            anchors.centerIn: parent

                            text: "CONNECT"

                            color: theme.textPrimary
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                panel.submitPassword()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            Text {
                Layout.fillWidth: true

                visible:
                    panel.statusMessage.length > 0

                text: panel.statusMessage

                wrapMode: Text.WordWrap

                color: "#FFD166"
                font.pixelSize: 9
            }

            Text {
                Layout.alignment:
                    Qt.AlignHCenter

                text:
                    network.scannerUsers > 0
                        ? "NETWORKMANAGER · SCANNING"
                        : "NETWORKMANAGER"

                color: "#59616C"
                font.pixelSize: 8
                font.letterSpacing: 1
            }
        }
    }
}
