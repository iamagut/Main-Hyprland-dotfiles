import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: switcherRoot
    signal wallpaperSelected(string path)

    ListModel {
        id: wallpaperModel
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
        anchors.margins: 12
        spacing: 10

        // Header
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
        }

        // Vertical Grid of Wallpapers
        GridView {
            id: gridView
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 200
            cellHeight: 170
            clip: true
            model: wallpaperModel

            delegate: Item {
                width: gridView.cellWidth
                height: gridView.cellHeight

                Rectangle {
                    id: itemCard
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 12
                    color: mouseArea.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low
                    border.color: mouseArea.containsMouse ? Color.md3.primary : Color.md3.outline_variant
                    border.width: mouseArea.containsMouse ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        // Image Preview Container
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            clip: true
                            color: Color.md3.surface_dim

                            Image {
                                anchors.fill: parent
                                source: "file://" + model.fullPath
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                                mipmap: true
                            }

                            // Category Badge
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 6
                                height: 20
                                width: categoryText.implicitWidth + 12
                                radius: 10
                                color: Color.md3.primary_container
                                opacity: 0.9

                                Text {
                                    id: categoryText
                                    anchors.centerIn: parent
                                    text: model.category
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Color.md3.on_primary_container
                                }
                            }
                        }

                        // Filename Label
                        Text {
                            Layout.fillWidth: true
                            text: model.fileName
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 11
                            color: mouseArea.containsMouse ? Color.md3.primary : Color.md3.on_surface
                            elide: Text.ElideMiddle
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            applyProcess.command = ["/home/iamagut/.local/bin/wallpaper-picker.sh", model.fullPath]
                            applyProcess.running = true
                            switcherRoot.wallpaperSelected(model.fullPath)
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
