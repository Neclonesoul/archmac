import QtQuick

Text {
    id: icon

    /*
     * ARCHMAC Galaxy semantic icon primitive.
     *
     * Material Symbols Rounded is used only for shell/system semantics.
     * Real application identity remains desktop-entry/icon-theme driven.
     */
    property string name: ""
    property int size: 18

    text: name

    color: "white"

    font.family: "Material Symbols Rounded"
    font.pixelSize: size
    font.weight: Font.Normal

    /*
     * Variable font axes:
     * FILL = 0 outlined
     * wght = 400
     * GRAD = 0
     * opsz = icon size
     */
    font.variableAxes: ({
        "FILL": 0,
        "wght": 400,
        "GRAD": 0,
        "opsz": size
    })

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
