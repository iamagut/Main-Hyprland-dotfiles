import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspacesRoot
    spacing: 8

    property int capAt: 5
    property int totalWorkspaces: 10

    property color activeColor: Color.md3.primary
    property color occupiedColor: Color.md3.on_surface
    property color emptyColor: Color.md3.outline
    property color pillColor: Color.md3.surface_container_highest

    property int dotSize: 8
    property int pillWidth: 30
    property real hoverScale: 2.5

    property var visibleWorkspaces: {
        var _a = Hyprland.workspaces.values.length
        var _b = Hyprland.focusedWorkspace

        var list = []
        for (var i = 1; i <= totalWorkspaces; i++) {
            if (i <= capAt) {
                list.push(i)
                continue
            }

            var ws = Hyprland.workspaces.values.find(function (w) { return w.id === i })
            var hasWindows = Boolean(ws && ws.toplevels && ws.toplevels.values.length > 0)
            var isFocused = Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === i)

            if (hasWindows || isFocused) {
                list.push(i)
            }
        }
        return list
    }

    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() { Hyprland.refreshWorkspaces() }
        function onObjectRemovedPost() { Hyprland.refreshWorkspaces() }
    }

    Repeater {
        model: workspacesRoot.visibleWorkspaces

        delegate: Rectangle {
            id: pill
            required property int modelData

            property var ws: Hyprland.workspaces.values.find(function (w) { return w.id === modelData })
            property bool isFocused: Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData)
            property bool hasWindows: Boolean(ws && ws.toplevels && ws.toplevels.values.length > 0)
            property bool hovered: mouseArea.containsMouse

            width: isFocused ? workspacesRoot.pillWidth : workspacesRoot.dotSize
            height: workspacesRoot.dotSize
            radius: height / 2
            scale: hovered ? workspacesRoot.hoverScale : 1.0
            z: hovered ? 10 : 0

            color: isFocused ? workspacesRoot.activeColor
                   : hasWindows ? workspacesRoot.occupiedColor
                   : workspacesRoot.emptyColor

            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: modelData
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 6
                font.bold: true
                color: pill.isFocused ? Color.md3.on_primary_container
                       : pill.hasWindows ? Color.md3.surface
                       : Color.md3.surface
                opacity: pill.hovered ? 1 : 0

                Behavior on opacity { NumberAnimation { duration: 100 } }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + pill.modelData + '" })')
            }
        }
    }
}
