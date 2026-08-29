import QtQuick

import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: service

    property int receivedSerial: 0
    property bool centreOpen: false

    readonly property var notifications:
        server.trackedNotifications

    readonly property var notificationValues:
        server.trackedNotifications.values

    readonly property int count:
        notificationValues.length

    signal received(var notification)

    function dismiss(notification) {
        if (notification)
            notification.dismiss()
    }

    function dismissAll() {
        const items =
            notifications.values.slice()

        for (const notification of items)
            notification.dismiss()
    }

    function toggleCentre() {
        centreOpen = !centreOpen
    }

    function closeCentre() {
        centreOpen = false
    }

    property NotificationServer server: NotificationServer {
        id: server

        keepOnReload: true

        bodySupported: true
        actionsSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true

            service.receivedSerial += 1
            service.received(notification)
        }
    }
}
