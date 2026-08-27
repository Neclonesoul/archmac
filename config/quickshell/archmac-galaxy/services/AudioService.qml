import QtQuick

import Quickshell.Services.Pipewire

QtObject {
    id: service

    readonly property var sink: Pipewire.defaultAudioSink

    /*
     * PipeWire audio properties are valid only while the node is tracked.
     */
    property PwObjectTracker sinkTracker: PwObjectTracker {
        objects: service.sink ? [service.sink] : []
    }

    readonly property bool available:
        Pipewire.ready
        && sink !== null
        && sink.audio !== null

    readonly property int volume:
        available
            ? Math.round(sink.audio.volume * 100)
            : -1

    readonly property bool muted:
        available && sink.audio.muted

    readonly property string shortLabel:
        !available
            ? "VOL --"
            : muted
                ? "MUTE"
                : "VOL " + volume + "%"

    function toggleMute() {
        if (!available)
            return

        sink.audio.muted = !sink.audio.muted
    }

    function setVolume(value) {
        if (!available)
            return

        const bounded = Math.max(0, Math.min(1, value))
        sink.audio.volume = bounded
    }

    function changeVolume(delta) {
        if (!available)
            return

        setVolume(sink.audio.volume + delta)
    }
}
