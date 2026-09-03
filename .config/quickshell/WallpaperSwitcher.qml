import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Item {
    id: switcherRoot
    property bool active: false
    property int selectedIndex: 0
    signal wallpaperSelected(string path)

    ListModel {
        id: wallpaperModel
    }

    onActiveChanged: {
        if (active) {
            selectedIndex = 0
            if (wallpaperPathView.count > 0) {
                wallpaperPathView.currentIndex = 0
            }
            wallpaperPathView.forceActiveFocus()
        }
    }

    Process {
        id: findProcess
        command: ["find", Quickshell.env("HOME") + "/Pictures/wallpaper", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", ")"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var trimmed = data.trim()
                if (trimmed.length > 0) {
                    var homeDir = Quickshell.env("HOME") + "/Pictures/wallpaper/"
                    var rel = trimmed.startsWith(homeDir) ? trimmed.substring(homeDir.length) : trimmed
                    var parts = rel.split('/')
                    var category = parts.length > 1 ? parts[0] : "general"
                    var name = parts[parts.length - 1]

                    wallpaperModel.append({
                        "fullPath": trimmed,
                        "fileName": name,
                        "category": category
                    })
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Header Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "󰸉 Wallpapers"
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 15
                font.bold: true
                color: Color.md3.primary
            }

            Text {
                text: "(" + wallpaperModel.count + " available)"
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 12
                color: Color.md3.on_surface_variant
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 10
                opacity: 0.8

                RowLayout {
                    spacing: 4
                    Text { text: "← →"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Navigate"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "↵"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Apply"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "Esc"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Close"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }
            }
        }

        // Horizontal Row of Wallpapers with PathView for Infinite Scrolling & Centered Selection
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PathView {
                id: wallpaperPathView
                anchors.fill: parent
                model: wallpaperModel
                focus: true
                clip: true

                // Card width follows a 16:9 preview ratio from the available
                // height; how many fit is derived from width so cards never
                // overlap and always span the full width edge-to-edge.
                readonly property int cardMargin: 10
                readonly property int cardLabelArea: 26 // filename (18) + spacing (8)
                readonly property real previewAspectRatio: 16 / 9
                readonly property int cardWidth: {
                    if (height <= 0) return 200
                    var imageHeight = height - (cardMargin * 2) - cardLabelArea
                    if (imageHeight <= 0) return 200
                    var imageWidth = Math.round(imageHeight * previewAspectRatio)
                    return imageWidth + (cardMargin * 2)
                }
                readonly property int cardSpacing: 14
                readonly property int visibleCount: {
                    if (width <= 0) return 3
                    var raw = Math.floor((width - cardWidth) / (cardWidth + cardSpacing)) + 1
                    var odd = raw % 2 === 0 ? raw - 1 : raw // odd count keeps one card dead-center
                    return Math.max(3, Math.min(odd, wallpaperModel.count > 0 ? wallpaperModel.count : odd))
                }

                pathItemCount: Math.min(visibleCount, Math.max(wallpaperModel.count, 1))
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightRangeMode: PathView.StrictlyEnforceRange
                highlightMoveDuration: 280

                // PathView spaces pathItemCount items using a step of 1/pathItemCount
                // along the path (not 1/(pathItemCount-1)), so the outer items land
                // short of the path's actual endpoints by 1/(2*pathItemCount) on each
                // side. Overshoot the path by that amount so the visible cards still
                // span edge-to-edge.
                readonly property real pathSpan: {
                    var n = pathItemCount
                    var usable = width - cardWidth
                    return n > 1 ? usable * n / (n - 1) : usable
                }

                path: Path {
                    startX: (wallpaperPathView.width - wallpaperPathView.pathSpan) / 2
                    startY: wallpaperPathView.height / 2
                    PathLine {
                        x: (wallpaperPathView.width + wallpaperPathView.pathSpan) / 2
                        y: wallpaperPathView.height / 2
                    }
                }

                Keys.onLeftPressed: {
                    if (wallpaperModel.count > 0) {
                        var prevIndex = (switcherRoot.selectedIndex - 1 + wallpaperModel.count) % wallpaperModel.count
                        switcherRoot.selectedIndex = prevIndex
                        wallpaperPathView.currentIndex = prevIndex
                    }
                }

                Keys.onRightPressed: {
                    if (wallpaperModel.count > 0) {
                        var nextIndex = (switcherRoot.selectedIndex + 1) % wallpaperModel.count
                        switcherRoot.selectedIndex = nextIndex
                        wallpaperPathView.currentIndex = nextIndex
                    }
                }

                Keys.onReturnPressed: {
                    if (wallpaperModel.count > 0 && switcherRoot.selectedIndex >= 0 && switcherRoot.selectedIndex < wallpaperModel.count) {
                        var item = wallpaperModel.get(switcherRoot.selectedIndex)
                        if (item && item.fullPath) {
                            applyProcess.command = ["/home/iamagut/.local/bin/wallpaper-picker.sh", item.fullPath]
                            applyProcess.running = true
                            switcherRoot.wallpaperSelected(item.fullPath)
                        }
                    }
                }

                Keys.onEscapePressed: {
                    switcherRoot.wallpaperSelected("")
                }

                delegate: Item {
                    id: delegateItem
                    width: wallpaperPathView.cardWidth
                    height: wallpaperPathView.height

                    readonly property bool isSelected: PathView.isCurrentItem || (switcherRoot.selectedIndex === index)

                    Item {
                        id: cardContent
                        anchors.fill: parent
                        anchors.margins: wallpaperPathView.cardMargin

                        scale: isSelected ? 1.05 : 1.0
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Item { Layout.fillHeight: true }

                            // Wallpaper Image Preview Container
                            Item {
                                id: imageWrapper
                                Layout.fillWidth: true
                                Layout.preferredHeight: width / wallpaperPathView.previewAspectRatio

                                MultiEffect {
                                    source: imageContainer
                                    anchors.fill: imageContainer
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0, 0, 0, 0.6)
                                    shadowBlur: 0.6
                                    shadowVerticalOffset: 4
                                    shadowHorizontalOffset: 0
                                }

                                ClippingWrapperRectangle {
                                    id: imageContainer
                                    anchors.fill: parent
                                    radius: 10
                                    color: Color.md3.surface_dim

                                    Image {
                                        anchors.fill: parent
                                        source: "file://" + model.fullPath
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        smooth: true
                                        mipmap: true
                                    }
                                }

                                // Category Badge
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 6
                                    height: 18
                                    width: categoryText.implicitWidth + 10
                                    radius: 9
                                    color: isSelected ? Color.md3.primary : Color.md3.primary_container
                                    opacity: 0.95

                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        id: categoryText
                                        anchors.centerIn: parent
                                        text: model.category
                                        font.family: "Jetbrains Mono Nerd Font Propo"
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: isSelected ? Color.md3.on_primary : Color.md3.on_primary_container
                                    }
                                }
                            }

                            // Wallpaper Name Under Picture
                            Text {
                                Layout.fillWidth: true
                                height: 18
                                text: model.fileName
                                font.family: "Jetbrains Mono Nerd Font Propo"
                                font.pixelSize: 11
                                font.bold: isSelected
                                color: isSelected ? Color.md3.primary : Color.md3.on_surface
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Item { Layout.fillHeight: true }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (switcherRoot.selectedIndex === index) {
                                    applyProcess.command = ["/home/iamagut/.local/bin/wallpaper-picker.sh", model.fullPath]
                                    applyProcess.running = true
                                    switcherRoot.wallpaperSelected(model.fullPath)
                                } else {
                                    switcherRoot.selectedIndex = index
                                    wallpaperPathView.currentIndex = index
                                }
                            }
                        }
                    }
                }

                // Handle mouse wheel scrolling (convert vertical scroll to horizontal infinite navigation)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: (wheel) => {
                        if (wallpaperModel.count === 0) return
                        var delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
                        if (delta < 0) {
                            var nextIndex = (switcherRoot.selectedIndex + 1) % wallpaperModel.count
                            switcherRoot.selectedIndex = nextIndex
                            wallpaperPathView.currentIndex = nextIndex
                        } else if (delta > 0) {
                            var prevIndex = (switcherRoot.selectedIndex - 1 + wallpaperModel.count) % wallpaperModel.count
                            switcherRoot.selectedIndex = prevIndex
                            wallpaperPathView.currentIndex = prevIndex
                        }
                    }
                }
            }
        }
    }

    Process {
        id: applyProcess
    }
}
