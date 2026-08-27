import QtQuick
import QtQuick.Layouts

Item {
    id: strip

    required property var workspaceService
    required property var theme

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: 24

    Row {
        id: workspaceRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: 10

            delegate: Rectangle {
                id: workspaceButton

                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active:
                    workspaceService.currentId === workspaceId
                readonly property bool occupied:
                    workspaceService.workspaceExists(workspaceId)

                width: active ? 30 : 21
                height: 22

                radius: 7

                color: active
                    ? "#32FFFFFF"
                    : mouse.containsMouse
                        ? "#18FFFFFF"
                        : "transparent"

                border.width: active ? 1 : 0
                border.color: "#42FFFFFF"

                /*
                 * Width follows workspace focus.
                 * Critically, this never blocks input.
                 */
                Behavior on width {
                    NumberAnimation {
                        duration: 130
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 110
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: workspaceButton.workspaceId

                    color: workspaceButton.active
                        ? theme.textPrimary
                        : workspaceButton.occupied
                            ? theme.textSecondary
                            : theme.textMuted

                    opacity: workspaceButton.occupied
                        || workspaceButton.active
                            ? 1
                            : 0.48

                    font.family: "0xProto"
                    font.pixelSize: 10
                    font.weight:
                        workspaceButton.active
                            ? Font.DemiBold
                            : Font.Normal
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                        workspaceService.activate(
                            workspaceButton.workspaceId
                        )
                }
            }
        }
    }

    /*
     * Direction pulse.
     *
     * This is deliberately subtle in Phase 1B.
     * The visual movement originates in the direction of travel:
     *
     *   3 -> 4 : indicator enters from the left and travels right
     *   4 -> 3 : indicator enters from the right and travels left
     *
     * Later this becomes the full spatial workspace transition model.
     */

    Rectangle {
        id: motionIndicator

        width: 14
        height: 2
        radius: 1

        anchors.bottom: parent.bottom

        color: theme.accent

        opacity: 0

        property real restingX: {
            const id = workspaceService.currentId - 1
            return Math.max(
                0,
                Math.min(
                    strip.width - width,
                    id * 25 + 4
                )
            )
        }

        x: restingX

        Connections {
            target: workspaceService

            function onTransitionSerialChanged() {
                motionAnimation.stop()

                const direction = workspaceService.direction

                motionIndicator.x =
                    motionIndicator.restingX -
                    direction * 18

                motionIndicator.opacity = 0.9

                motionAnimation.restart()
            }
        }

        ParallelAnimation {
            id: motionAnimation

            NumberAnimation {
                target: motionIndicator
                property: "x"
                to: motionIndicator.restingX
                duration: 150
                easing.type: Easing.OutCubic
            }

            SequentialAnimation {
                PauseAnimation {
                    duration: 70
                }

                NumberAnimation {
                    target: motionIndicator
                    property: "opacity"
                    to: 0
                    duration: 110
                }
            }
        }
    }
}
