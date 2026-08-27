import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: service

    readonly property var player:
        Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null

    readonly property bool available:
        player !== null

    readonly property string title:
        available && player.trackTitle
            ? player.trackTitle
            : "Nothing playing"

    readonly property string artist:
        available
            ? (
                player.trackArtist
                    || player.identity
                    || ""
              )
            : ""

    readonly property bool playing:
        available && player.isPlaying

    function previous() {
        if (available && player.canGoPrevious)
            player.previous()
    }

    function toggle() {
        if (available && player.canTogglePlaying)
            player.togglePlaying()
    }

    function next() {
        if (available && player.canGoNext)
            player.next()
    }
}
