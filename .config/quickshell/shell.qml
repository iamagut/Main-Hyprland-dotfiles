import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
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

        function toggleLogoutMenu() {
            if (panel.activeOverlay === "logout" && panel.overlayOpen) {
                panel.overlayOpen = false
            } else {
                panel.activeOverlay = "logout"
                panel.overlayOpen = true
            }
        }
        function openLogoutMenu() {
            panel.activeOverlay = "logout"
            panel.overlayOpen = true
        }
        function closeLogoutMenu() {
            if (panel.activeOverlay === "logout") panel.overlayOpen = false
        }

        function toggleClipboardHistory() {
            if (panel.activeOverlay === "clipboard" && panel.overlayOpen) {
                panel.overlayOpen = false
            } else {
                panel.activeOverlay = "clipboard"
                panel.overlayOpen = true
            }
        }
        function openClipboardHistory() {
            panel.activeOverlay = "clipboard"
            panel.overlayOpen = true
        }
        function closeClipboardHistory() {
            if (panel.activeOverlay === "clipboard") panel.overlayOpen = false
        }

        function toggleClockHover() {
            if (panel.activeOverlay === "clock" && panel.overlayOpen) {
                panel.overlayOpen = false
            } else {
                panel.activeOverlay = "clock"
                panel.overlayOpen = true
            }
        }
        function openClockHover() {
            panel.activeOverlay = "clock"
            panel.overlayOpen = true
        }
        function closeClockHover() {
            if (panel.activeOverlay === "clock") panel.overlayOpen = false
        }
    }

    // Main Panel Window containing Top Bar & Dropdown Overlays
    PanelWindow {
        id: panel
        anchors {
            top: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: overlayOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Math.round(barHeight * barVisibilityProgress)

        readonly property int barHeight: 40
        readonly property int wallpaperOverlayHeight: 230
        readonly property int wallpaperBulgeWidth: Math.min(780, panel.width - 40)
        readonly property int wallpaperBulgeX: Math.round((panel.width - wallpaperBulgeWidth) / 2)

        readonly property int launcherOverlayHeight: 540
        readonly property int launcherBulgeWidth: Math.min(808, panel.width - 40)
        readonly property int launcherBulgeX: Math.round((panel.width - launcherBulgeWidth) / 2)

        readonly property int logoutOverlayHeight: 150
        readonly property int logoutBulgeWidth: Math.min(620, panel.width - 40)
        readonly property int logoutBulgeX: Math.round((panel.width - logoutBulgeWidth) / 2)

        readonly property int clipboardOverlayHeight: 540
        readonly property int clipboardBulgeWidth: Math.min(808, panel.width - 40)
        readonly property int clipboardBulgeX: Math.round((panel.width - clipboardBulgeWidth) / 2)

        readonly property int targetOverlayHeight: activeOverlay === "wallpaper" ? wallpaperOverlayHeight
            : (activeOverlay === "launcher" ? launcherOverlayHeight
            : (activeOverlay === "clipboard" ? clipboardOverlayHeight : logoutOverlayHeight))
        readonly property int targetBulgeWidth: activeOverlay === "wallpaper" ? wallpaperBulgeWidth
            : (activeOverlay === "launcher" ? launcherBulgeWidth
            : (activeOverlay === "clipboard" ? clipboardBulgeWidth : logoutBulgeWidth))
        readonly property int targetBulgeX: activeOverlay === "wallpaper" ? wallpaperBulgeX
            : (activeOverlay === "launcher" ? launcherBulgeX
            : (activeOverlay === "clipboard" ? clipboardBulgeX : logoutBulgeX))

        property real currentOverlayHeight: targetOverlayHeight
        Behavior on currentOverlayHeight {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        property real currentBulgeWidth: targetBulgeWidth
        Behavior on currentBulgeWidth {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        property real currentBulgeX: targetBulgeX
        Behavior on currentBulgeX {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        property string activeOverlay: "launcher" // "launcher", "wallpaper", "clipboard", or "logout"
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

        implicitWidth: panel.width
        readonly property int maxOverlayHeight: Math.max(wallpaperOverlayHeight, Math.max(launcherOverlayHeight, Math.max(clipboardOverlayHeight, logoutOverlayHeight)))
        implicitHeight: barHeight + maxOverlayHeight + 16

        color: "transparent"

        // Input hit-test region:
        // Top bar always interactive. Dropdown bulging overlays only active when expanded.
        mask: Region {
            Region {
                shape: RegionShape.Rect
                x: 0
                y: 0
                width: panel.width
                height: Math.round(panel.barHeight * panel.barVisibilityProgress)
            }
            Region {
                shape: RegionShape.Rect
                x: Math.max(0, panel.currentBulgeX - 16)
                y: panel.barHeight
                width: panel.currentBulgeWidth + 32
                height: Math.round(panel.openProgress * panel.currentOverlayHeight * panel.barVisibilityProgress)
            }
        }

        // SVG Path for panel background (bulging panel with concave top corners and convex bottom corners)
        readonly property string backgroundPathSvg: {
            var W = panel.width
            var Hbar = panel.barHeight
            var P = panel.openProgress
            var Hbulge = P * panel.currentOverlayHeight

            if (Hbulge <= 0.5) {
                return "M 0 0 L " + W + " 0 L " + W + " " + Hbar + " L 0 " + Hbar + " Z"
            }

            // Keep corner radius fixed at 16 while open; only shrink when the bulge
            // is too short to fit full fillets (otherwise corners look square mid-animation).
            var R = Math.min(16, Hbulge * 0.5)
            var Ybottom = Hbar + Hbulge
            var X1 = panel.currentBulgeX
            var X2 = X1 + panel.currentBulgeWidth
            var Yside = Math.max(Hbar + R, Ybottom - R)

            return "M 0 0 " +
                   "L " + W + " 0 " +
                   "L " + W + " " + Hbar + " " +
                   "L " + (X2 + R) + " " + Hbar + " " +
                   "A " + R + " " + R + " 0 0 0 " + X2 + " " + (Hbar + R) + " " +
                   "L " + X2 + " " + Yside + " " +
                   "A " + R + " " + R + " 0 0 1 " + (X2 - R) + " " + Ybottom + " " +
                   "L " + (X1 + R) + " " + Ybottom + " " +
                   "A " + R + " " + R + " 0 0 1 " + X1 + " " + Yside + " " +
                   "L " + X1 + " " + (Hbar + R) + " " +
                   "A " + R + " " + R + " 0 0 0 " + (X1 - R) + " " + Hbar + " " +
                   "L 0 " + Hbar + " Z"
        }

        // Background container with Shape drawing
        Item {
            id: background
            anchors.fill: parent
            opacity: panel.barVisibilityProgress

            Shape {
                id: backgroundShape
                anchors.fill: parent
                containsMode: Shape.FillContains

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.15)
                    shadowBlur: 0.3
                    shadowVerticalOffset: 2
                    shadowHorizontalOffset: 0
                }

                ShapePath {
                    fillColor: Color.md3.background
                    strokeColor: Color.md3.outline_variant
                    strokeWidth: 0

                    PathSvg {
                        path: panel.backgroundPathSvg
                    }
                }
            }

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

                    PowerProfile { Layout.alignment: Qt.AlignVCenter }
                    Wifi { Layout.alignment: Qt.AlignVCenter }
                    Volume { Layout.alignment: Qt.AlignVCenter }
                    Battery {}
                }
            }

            // --- DROPDOWN OVERLAY SECTION ---
            Item {
                id: overlaySection
                anchors.top: bar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.round(panel.openProgress * panel.currentOverlayHeight)
                visible: panel.openProgress > 0
                opacity: panel.openProgress
                clip: true

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: panel.wallpaperBulgeWidth
                    height: panel.wallpaperOverlayHeight
                    opacity: (panel.overlayOpen && panel.activeOverlay === "wallpaper") ? 1 : 0
                    visible: opacity > 0.001
                    enabled: opacity > 0.99

                    transform: Translate {
                        y: Math.round(-panel.wallpaperOverlayHeight * (1 - panel.openProgress))
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.InOutQuad }
                    }

                    WallpaperSwitcher {
                        anchors.fill: parent
                        active: panel.overlayOpen && panel.activeOverlay === "wallpaper"
                        onWallpaperSelected: panel.overlayOpen = false
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: panel.launcherBulgeWidth
                    height: panel.launcherOverlayHeight
                    opacity: (panel.overlayOpen && panel.activeOverlay === "launcher") ? 1 : 0
                    visible: opacity > 0.001
                    enabled: opacity > 0.99

                    transform: Translate {
                        y: Math.round(-panel.launcherOverlayHeight * (1 - panel.openProgress))
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.InOutQuad }
                    }

                    AppLauncher {
                        anchors.fill: parent
                        active: panel.overlayOpen && panel.activeOverlay === "launcher"
                        onAppLaunched: panel.overlayOpen = false
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: panel.clipboardBulgeWidth
                    height: panel.clipboardOverlayHeight
                    opacity: (panel.overlayOpen && panel.activeOverlay === "clipboard") ? 1 : 0
                    visible: opacity > 0.001
                    enabled: opacity > 0.99

                    transform: Translate {
                        y: Math.round(-panel.clipboardOverlayHeight * (1 - panel.openProgress))
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.InOutQuad }
                    }

                    ClipboardHistory {
                        anchors.fill: parent
                        active: panel.overlayOpen && panel.activeOverlay === "clipboard"
                        onItemCopied: panel.overlayOpen = false
                        onMenuClosed: panel.overlayOpen = false
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: panel.logoutBulgeWidth
                    height: panel.logoutOverlayHeight
                    opacity: (panel.overlayOpen && panel.activeOverlay === "logout") ? 1 : 0
                    visible: opacity > 0.001
                    enabled: opacity > 0.99

                    transform: Translate {
                        y: Math.round(-panel.logoutOverlayHeight * (1 - panel.openProgress))
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.InOutQuad }
                    }

                    LogoutMenu {
                        anchors.fill: parent
                        active: panel.overlayOpen && panel.activeOverlay === "logout"
                        onActionExecuted: panel.overlayOpen = false
                        onMenuClosed: panel.overlayOpen = false
                    }
                }
            }
        }
    }

    // --- OSD WINDOW ---
    OSD {}
}
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
