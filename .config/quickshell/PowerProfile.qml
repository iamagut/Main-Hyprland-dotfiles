import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    implicitHeight: 28
    implicitWidth: pill.implicitWidth

    readonly property var profiles: [
        { value: PowerProfile.PowerSaver, icon: "󰌪" },
        { value: PowerProfile.Balanced, icon: "󰗑" },
        { value: PowerProfile.Performance, icon: "󰓅" }
    ]

    readonly property bool expanded: hover.hovered

    // Single source of truth for the expand/collapse animation.
    // Every width, spacing and opacity below derives from this one
    // number, so the pill's outline and its contents always agree on
    // frame-by-frame size — no separate timers to fall out of sync,
    // regardless of which segment happens to be active.
    property real expandProgress: expanded ? 1 : 0
    Behavior on expandProgress {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: pill
        anchors.verticalCenter: parent.verticalCenter
        height: 28
        radius: height / 2
        color: root.expanded ? Color.md3.surface_container_highest : Color.md3.surface_container_low
        border.width: 1
        border.color: Qt.rgba(Color.md3.outline_variant.r, Color.md3.outline_variant.g, Color.md3.outline_variant.b, 0.35)
        implicitWidth: row.implicitWidth + 14
        clip: true

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        HoverHandler {
            id: hover
            cursorShape: root.expanded ? Qt.ArrowCursor : Qt.PointingHandCursor
        }

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 7
            spacing: 3 * root.expandProgress

            Repeater {
                model: root.profiles

                delegate: Rectangle {
                    id: option
                    required property var modelData

                    readonly property bool isActive: modelData.value === PowerProfiles.profile
                    readonly property real openWidth: 26

                    width: isActive ? openWidth : openWidth * root.expandProgress
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    radius: height / 2
                    opacity: isActive ? 1 : root.expandProgress
                    scale: tap.pressed ? 0.88 : 1
                    color: isActive
                           ? Color.md3.primary
                           : (optHover.hovered ? Color.md3.surface_container_high : "transparent")

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale {
                        NumberAnimation { duration: 140; easing.type: Easing.OutBack }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: option.modelData.icon
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 13
                        color: option.isActive ? Color.md3.on_primary : Color.md3.primary
                        opacity: option.opacity
                        visible: option.width > 4
                    }

                    HoverHandler {
                        id: optHover
                        enabled: root.expanded
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        id: tap
                        enabled: root.expanded && !option.isActive
                        onTapped: PowerProfiles.profile = option.modelData.value
                    }
                }
            }
        }
    }
}
