import QtQuick
import QtQuick.Layouts

import Quickshell

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
        top: 50
        right: 12
    }

    implicitWidth: 330
    implicitHeight:
        toastColumn.implicitHeight

    exclusionMode:
        ExclusionMode.Ignore

    focusable: false
    aboveWindows: true

    color: "transparent"

    /*
     * Toasts are intentionally separate from notification history.
     *
     * notification.tracked keeps history alive.
     * This array controls only what is temporarily visible.
     */
    property var toastQueue: []

    readonly property int maximumToasts: 4

    function addToast(notification) {
        let next =
            toastQueue.slice()

        /*
         * Newest notification appears at the top.
         */
        next.unshift(notification)

        if (
            next.length
            > maximumToasts
        ) {
            next =
                next.slice(
                    0,
                    maximumToasts
                )
        }

        toastQueue = next
    }

    function removeToast(notification) {
        const next = []

        for (
            const candidate
            of toastQueue
        ) {
            if (
                candidate
                !== notification
            ) {
                next.push(
                    candidate
                )
            }
        }

        toastQueue = next
    }

    Connections {
        target: notifications

        function onReceived(
            notification
        ) {
            window.addToast(
                notification
            )
        }
    }

    ColumnLayout {
        id: toastColumn

        width: parent.width

        spacing: 8

        Repeater {
            model:
                window.toastQueue

            delegate: Rectangle {
                id: card

                required property var modelData

                Layout.fillWidth: true

                implicitHeight:
                    content.implicitHeight
                    + 24

                radius: 11

                color:
                    "#E612181D"

                border.width: 1
                border.color:
                    "#405C7484"

                opacity: 1
                scale: 1

                Component.onCompleted: {
                    appearAnimation.start()
                    expiryTimer.start()
                }

                ParallelAnimation {
                    id: appearAnimation

                    NumberAnimation {
                        target: card
                        property: "opacity"

                        from: 0
                        to: 1

                        duration: 110
                    }

                    NumberAnimation {
                        target: card
                        property: "scale"

                        from: 0.97
                        to: 1

                        duration: 130

                        easing.type:
                            Easing.OutCubic
                    }
                }

                Timer {
                    id: expiryTimer

                    interval: 4200
                    repeat: false

                    onTriggered:
                        disappearAnimation.start()
                }

                SequentialAnimation {
                    id: disappearAnimation

                    NumberAnimation {
                        target: card
                        property: "opacity"

                        to: 0

                        duration: 100
                    }

                    ScriptAction {
                        script:
                            window.removeToast(
                                card.modelData
                            )
                    }
                }

                ColumnLayout {
                    id: content

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 12
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

                            color:
                                theme.textMuted

                            font.family:
                                "0xProto"

                            font.pixelSize: 8
                            font.weight:
                                Font.DemiBold

                            elide:
                                Text.ElideRight
                        }

                        Text {
                            text: "×"

                            color:
                                theme.textMuted

                            font.pixelSize: 13

                            TapHandler {
                                onTapped: {
                                    /*
                                     * Explicit close dismisses it
                                     * from both toast and history.
                                     */
                                    notifications.dismiss(
                                        modelData
                                    )

                                    window.removeToast(
                                        modelData
                                    )
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            modelData.summary

                        color:
                            theme.textPrimary

                        font.family:
                            "0xProto"

                        font.pixelSize: 10
                        font.weight:
                            Font.DemiBold

                        wrapMode:
                            Text.Wrap
                    }

                    Text {
                        visible:
                            modelData.body !== ""

                        Layout.fillWidth: true

                        text:
                            modelData.body

                        color:
                            theme.textSecondary

                        font.pixelSize: 9

                        wrapMode:
                            Text.Wrap
                    }
                }
            }
        }
    }
}
