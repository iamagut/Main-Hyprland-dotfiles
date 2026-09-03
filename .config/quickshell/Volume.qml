import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

RowLayout {
    id: volumeRoot
    spacing: 6

    property var sink: Pipewire.defaultAudioSink

    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

    readonly property string deviceName: ready ? (sink.name || sink.description || sink.id || "") : ""

    readonly property bool isEarbuds: {
        var name = deviceName.toLowerCase()
        return name.includes("earbud") || name.includes("buds") || name.includes("airpods")
    }

    readonly property bool isHeadphone: {
        var name = deviceName.toLowerCase()
        return (name.includes("headphone") || name.includes("headset") || name.includes("bluetooth") || name.includes("bt-") || name.includes("hfp") || name.includes("a2dp")) && !isEarbuds
    }

    readonly property string icon: {
        if (!ready) return "󰝟"
        if (muted) return "󰝟"
        if (isEarbuds) return "󱡏"
        if (isHeadphone) return "󰋋"
        if (vol === 0) return "󰕿"
        if (vol < 50) return "󰖀"
        return "󰕾"
    }

    Text {
        text: volumeRoot.icon
        color: volumeRoot.muted ? Color.md3.error : Color.md3.primary
        font.pixelSize: 14
        font.family: 'Jetbrains Mono Nerd Font Propo'
    }

    Text {
        text: {
            if (!volumeRoot.ready) return '-'
            if (volumeRoot.muted) return 'Muted'
            return volumeRoot.vol + '%'
        }
        color: volumeRoot.muted ? Color.md3.error : Color.md3.on_surface
        font.pixelSize: 14
        font.family: 'Jetbrains Mono Nerd Font Propo'
    }

    PwObjectTracker {
        objects: volumeRoot.sink ? [volumeRoot.sink] : []
    }
}
