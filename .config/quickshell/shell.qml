import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

ShellRoot {
    IpcHandler {
        target: "qsIpc"

        function toggleWallpaperSwitcher() {
            if (panel.activeOverlay === "wallpaper" && panel.overlayOpen) {
                panel.overlayOpen = false
            } else {
                panel.activeOverlay = "wallpaper"
                panel.overlayOpen = true
            }
        }
        function openWallpaperSwitcher() {
            panel.activeOverlay = "wallpaper"
            panel.overlayOpen = true
        }
        function closeWallpaperSwitcher() {
            if (panel.activeOverlay === "wallpaper") panel.overlayOpen = false
        }

        function toggleAppLauncher() {
            if (panel.activeOverlay === "launcher" && panel.overlayOpen) {
                panel.overlayOpen = false
            } else {
                panel.activeOverlay = "launcher"
                panel.overlayOpen = true
            }
        }
        function openAppLauncher() {
            panel.activeOverlay = "launcher"
            panel.overlayOpen = true
        }
        function closeAppLauncher() {
            if (panel.activeOverlay === "launcher") panel.overlayOpen = false
        }
    }

    // Main Panel Window containing Top Bar & Dropdown Overlays
    PanelWindow {
        id: panel
        anchors {
            top: true
            left: false
            right: false
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (overlayOpen && activeOverlay === "launcher") ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Math.round(barHeight * barVisibilityProgress)

        // Input hit-test region: when the dropdown is closed,
        // let pointer events pass through to apps underneath.
        // When openProgress > 0, expand the mask to cover the active overlay.
        mask: Region {
            shape: RegionShape.Rect
            x: 0
            y: 0
            width: panel.width
            height: (panel.barHeight + panel.openProgress * panel.overlayHeight) * panel.barVisibilityProgress
            radius: 0
        }

        readonly property int barHeight: 40
        readonly property int overlayHeight: 560

        property string activeOverlay: "launcher" // "launcher" or "wallpaper"
        property bool overlayOpen: false

        readonly property bool hideForFullscreen: Boolean(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.hasFullscreen)
        property real barVisibilityProgress: hideForFullscreen ? 0 : 1

        Behavior on barVisibilityProgress {
            NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
        }
        onHideForFullscreenChanged: {
            if (hideForFullscreen) overlayOpen = false
            barVisibilityProgress = hideForFullscreen ? 0 : 1
        }

        // Animated progress for opening/closing the dropdown overlays.
        property real openProgress: 0
        Behavior on openProgress {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        onOverlayOpenChanged: openProgress = overlayOpen ? 1 : 0

        implicitWidth: 1025
        implicitHeight: barHeight + overlayHeight

        color: "transparent"

        Rectangle {
            id: background
            height: panel.barHeight + panel.openProgress * panel.overlayHeight
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            opacity: panel.barVisibilityProgress
            color: Color.md3.background
            radius: 8
            border.color: Color.md3.outline_variant
            border.width: 1
            clip: true

            // --- TOP BAR ---
            Rectangle {
                id: bar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: panel.barHeight
                color: "transparent"
                z: 2

                // --- LEFT SECTION ---
                Row {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 14
                    }
                    spacing: 10

                    // App Launcher Trigger Button
                    Rectangle {
                        height: 28
                        width: 28
                        radius: 8
                        color: (panel.overlayOpen && panel.activeOverlay === "launcher") ? Color.md3.primary : (launcherBtnMouse.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low)
                        border.color: (panel.overlayOpen && panel.activeOverlay === "launcher") ? Color.md3.primary : Color.md3.outline_variant
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "󰵆"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 14
                            color: (panel.overlayOpen && panel.activeOverlay === "launcher") ? Color.md3.on_primary : Color.md3.primary
                        }

                        MouseArea {
                            id: launcherBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (panel.activeOverlay === "launcher" && panel.overlayOpen) {
                                    panel.overlayOpen = false
                                } else {
                                    panel.activeOverlay = "launcher"
                                    panel.overlayOpen = true
                                }
                            }
                        }
                    }

                    // Wallpaper Switcher Trigger Button
                    Rectangle {
                        height: 28
                        width: 28
                        radius: 8
                        color: (panel.overlayOpen && panel.activeOverlay === "wallpaper") ? Color.md3.primary : (wallpaperBtnMouse.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low)
                        border.color: (panel.overlayOpen && panel.activeOverlay === "wallpaper") ? Color.md3.primary : Color.md3.outline_variant
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "󰸉"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 14
                            color: (panel.overlayOpen && panel.activeOverlay === "wallpaper") ? Color.md3.on_primary : Color.md3.primary
                        }

                        MouseArea {
                            id: wallpaperBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (panel.activeOverlay === "wallpaper" && panel.overlayOpen) {
                                    panel.overlayOpen = false
                                } else {
                                    panel.activeOverlay = "wallpaper"
                                    panel.overlayOpen = true
                                }
                            }
                        }
                    }

                    Workspaces {}
                }

                // --- CENTER SECTION ---
                Clock {
                    anchors.centerIn: parent
                }

                // --- RIGHT SECTION ---
                RowLayout {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 14
                    }
                    spacing: 20

                    Wifi { Layout.alignment: Qt.AlignVCenter }
                    Volume { Layout.alignment: Qt.AlignVCenter }
                }
            }

            // --- DROPDOWN OVERLAY SECTION ---
            Item {
                id: overlaySection
                anchors.top: bar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: panel.overlayHeight
                visible: panel.openProgress > 0
                opacity: panel.openProgress

                transform: Translate {
                    y: -14 * (1 - panel.openProgress)
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Color.md3.outline_variant
                }

                // Wallpaper Switcher
                WallpaperSwitcher {
                    anchors.fill: parent
                    opacity: (panel.overlayOpen && panel.activeOverlay === "wallpaper") ? 1 : 0
                    visible: opacity > 0.001
                    enabled: opacity > 0.99

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.InOutQuad }
                    }

                    onWallpaperSelected: panel.overlayOpen = false
                }

                // App Launcher
                AppLauncher {
                    anchors.fill: parent
                    opacity: (panel.overlayOpen && panel.activeOverlay === "launcher") ? 1 : 0
                    visible: opacity > 0.001
                    enabled: opacity > 0.99
                    active: panel.overlayOpen && panel.activeOverlay === "launcher"

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.InOutQuad }
                    }

                    onAppLaunched: panel.overlayOpen = false
                }
            }
        }
    }

    // --- OSD WINDOW ---
    OSD {}
}
