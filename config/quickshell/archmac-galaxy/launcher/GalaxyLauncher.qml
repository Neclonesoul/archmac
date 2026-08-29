import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

PanelWindow {
    id: window

    required property var shellScreen
    required property var theme
    required property var launcher

    screen: shellScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode:
        ExclusionMode.Ignore

    aboveWindows: true

    focusable:
        launcher.open

    visible:
        launcher.open

    color:
        "#52000000"

    /*
     * Full-screen click target so clicking outside
     * the launcher closes it.
     */
    MouseArea {
        anchors.fill: parent

        onClicked:
            launcher.hide()
    }

    Rectangle {
        id: panel

        width:
            Math.min(
                650,
                window.width - 80
            )

        height:
            Math.min(
                510,
                window.height - 130
            )

        anchors {
            horizontalCenter:
                parent.horizontalCenter

            top:
                parent.top

            topMargin: 92
        }

        radius: 16

        color:
            "#F211171C"

        border.width: 1
        border.color:
            "#405C7484"

        MouseArea {
            anchors.fill: parent

            /*
             * Consume clicks inside the panel so the
             * full-screen close target does not fire.
             */
            onClicked: mouse => {
                mouse.accepted = true
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14

            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                radius: 10

                color:
                    "#D7192229"

                border.width: 1
                border.color:
                    searchField.activeFocus
                        ? "#506FA8C6"
                        : "#30485A66"

                TextInput {
                    id: searchField

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 16
                        rightMargin: 16
                    }

                    focus:
                        launcher.open

                    text:
                        launcher.query

                    color:
                        theme.textPrimary

                    selectionColor:
                        "#405D88A0"

                    selectedTextColor:
                        theme.textPrimary

                    font.family:
                        "0xProto"

                    font.pixelSize: 13

                    clip: true

                    onTextChanged: {
                        if (
                            launcher.query
                            !== text
                        ) {
                            launcher.query =
                                text
                        }
                    }

                    Keys.onPressed:
                        event => {
                            if (
                                event.key
                                === Qt.Key_Down
                            ) {
                                launcher.moveSelection(
                                    1
                                )

                                event.accepted = true
                                return
                            }

                            if (
                                event.key
                                === Qt.Key_Up
                            ) {
                                launcher.moveSelection(
                                    -1
                                )

                                event.accepted = true
                                return
                            }

                            if (
                                event.key
                                === Qt.Key_Return
                                || event.key
                                === Qt.Key_Enter
                            ) {
                                launcher.launchSelected()

                                event.accepted = true
                                return
                            }

                            if (
                                event.key
                                === Qt.Key_Escape
                            ) {
                                launcher.hide()

                                event.accepted = true
                            }
                        }
                }

                Text {
                    visible:
                        searchField.text.length
                        === 0

                    anchors {
                        left:
                            searchField.left

                        verticalCenter:
                            parent.verticalCenter
                    }

                    text:
                        "Search apps, calculate, or type clip…"

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 13
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true

                    text:
                        launcher.calculatorActive
                            ? "CALCULATOR"
                            : launcher.clipboardActive
                                ? "CLIPBOARD"
                                : launcher.query === ""
                                    ? "APPLICATIONS"
                                    : "RESULTS"

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 8
                    font.weight:
                        Font.DemiBold
                }

                Text {
                    text:
                        launcher.calculatorActive
                            ? (
                                launcher.calculatorPending
                                    ? "CALCULATING"
                                    : "ENTER TO COPY"
                            )
                            : launcher.clipboardActive
                                ? (
                                    launcher.clipboardLoading
                                        ? "LOADING"
                                        : launcher.resultCount
                                            + " ITEMS"
                                )
                                : launcher.resultCount
                                + (
                                    launcher.resultCount
                                    === 1
                                        ? " RESULT"
                                        : " RESULTS"
                                )

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 8
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight:
                    launcher.calculatorActive
                        ? 92
                        : 0

                visible:
                    launcher.calculatorActive

                radius: 10

                color:
                    "#E61A2228"

                border.width: 1
                border.color:
                    "#30485A66"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14

                    spacing: 6

                    Text {
                        Layout.fillWidth: true

                        text:
                            launcher.calculatorExpression

                        color:
                            theme.textMuted

                        font.family:
                            "0xProto"

                        font.pixelSize: 10

                        elide:
                            Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            launcher.calculatorPending
                                ? "…"
                                : (
                                    launcher.calculatorResult
                                    === ""
                                        ? "No result"
                                        : "= "
                                            + launcher.calculatorResult
                                )

                        color:
                            theme.textPrimary

                        font.family:
                            "0xProto"

                        font.pixelSize: 18
                        font.weight:
                            Font.DemiBold

                        elide:
                            Text.ElideRight
                    }
                }

                TapHandler {
                    enabled:
                        launcher.calculatorActive
                        && !launcher.calculatorPending
                        && launcher.calculatorResult !== ""

                    onTapped:
                        launcher.copyCalculatorResult()
                }
            }

            ListView {
                id: clipboardResults

                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    launcher.clipboardActive

                clip: true
                spacing: 4

                model:
                    launcher.filteredClipboardEntries

                currentIndex:
                    launcher.selectedIndex

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width:
                        ListView.view.width

                    height: 50

                    radius: 9

                    color:
                        index
                        === launcher.selectedIndex
                            ? "#253F6072"
                            : clipHover.hovered
                                ? "#151FFFFFF"
                                : "transparent"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                        }

                        spacing: 10

                        Text {
                            text: "C"

                            color:
                                theme.textMuted

                            font.family:
                                "0xProto"

                            font.pixelSize: 8
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                modelData.preview

                            color:
                                theme.textPrimary

                            font.family:
                                "0xProto"

                            font.pixelSize: 9

                            elide:
                                Text.ElideRight
                        }

                        Text {
                            visible:
                                index
                                === launcher.selectedIndex

                            text: "↵"

                            color:
                                theme.textMuted

                            font.pixelSize: 12
                        }
                    }

                    HoverHandler {
                        id: clipHover

                        onHoveredChanged: {
                            if (hovered)
                                launcher.selectedIndex =
                                    index
                        }
                    }

                    TapHandler {
                        onTapped:
                            launcher.restoreClipboard(
                                modelData
                            )
                    }
                }

                Text {
                    visible:
                        launcher.clipboardActive
                        && !launcher.clipboardLoading
                        && launcher.resultCount === 0

                    anchors.centerIn:
                        parent

                    text:
                        "No matching clipboard entries"

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 10
                }
            }

            ListView {
                id: results

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                spacing: 4

                visible:
                    !launcher.calculatorActive
                    && !launcher.clipboardActive

                model:
                    launcher.filteredApplications

                currentIndex:
                    launcher.selectedIndex

                onCurrentIndexChanged: {
                    if (
                        launcher.selectedIndex
                        !== currentIndex
                    ) {
                        launcher.selectedIndex =
                            currentIndex
                    }
                }

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    width:
                        ListView.view.width

                    height: 52

                    radius: 9

                    color:
                        index
                        === launcher.selectedIndex
                            ? "#253F6072"
                            : rowHover.hovered
                                ? "#151FFFFFF"
                                : "transparent"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }

                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34

                            radius: 8

                            color:
                                "#1DFFFFFF"

                            IconImage {
                                anchors.centerIn:
                                    parent

                                width: 22
                                height: 22

                                source:
                                    Quickshell.iconPath(
                                        modelData.icon
                                    )
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 2

                            Text {
                                Layout.fillWidth: true

                                text:
                                    modelData.name

                                color:
                                    theme.textPrimary

                                font.family:
                                    "0xProto"

                                font.pixelSize: 10
                                font.weight:
                                    Font.DemiBold

                                elide:
                                    Text.ElideRight
                            }

                            Text {
                                visible:
                                    modelData.genericName
                                    !== ""

                                Layout.fillWidth: true

                                text:
                                    modelData.genericName

                                color:
                                    theme.textMuted

                                font.pixelSize: 8

                                elide:
                                    Text.ElideRight
                            }
                        }

                        Text {
                            visible:
                                index
                                === launcher.selectedIndex

                            text: "↵"

                            color:
                                theme.textMuted

                            font.pixelSize: 12
                        }
                    }

                    HoverHandler {
                        id: rowHover

                        onHoveredChanged: {
                            if (hovered)
                                launcher.selectedIndex =
                                    index
                        }
                    }

                    TapHandler {
                        onTapped:
                            launcher.launch(
                                modelData
                            )
                    }
                }

                Text {
                    visible:
                        !launcher.calculatorActive
                        && !launcher.clipboardActive
                        && launcher.resultCount
                        === 0

                    anchors.centerIn:
                        parent

                    text: "No matching applications"

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 10
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true

                    text:
                        launcher.calculatorActive
                            ? "↵ copy result    esc close"
                            : launcher.clipboardActive
                                ? "↑ ↓ navigate    ↵ restore clipboard"
                                : "↑ ↓ navigate    ↵ open"

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 7
                }

                Text {
                    text:
                        "ESC close"

                    color:
                        theme.textMuted

                    font.family:
                        "0xProto"

                    font.pixelSize: 7
                }
            }
        }
    }

    Connections {
        target: launcher

        function onOpenChanged() {
            if (launcher.open) {
                searchField.text =
                    launcher.query

                searchField.forceActiveFocus()
            }
        }
    }
}
