import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: logoutRoot

    property bool active: false
    property int selectedIndex: 0

    signal actionExecuted()
    signal menuClosed()

    onActiveChanged: {
        if (active) {
            selectedIndex = 0
            buttonsRow.forceActiveFocus()
        }
    }

    ListModel {
        id: logoutModel
        ListElement { name: "Lock"; icon: ""; action: "hyprlock"; key: "l" }
        ListElement { name: "Logout"; icon: "󰍃"; action: "hyprctl dispatch \"hl.dsp.exec_cmd('hyprshutdown')\""; key: "e" }
        ListElement { name: "Suspend"; icon: "󰤄"; action: "hyprlock & sleep 1 && systemctl suspend"; key: "u" }
        ListElement { name: "Reboot"; icon: "󰜉"; action: "systemctl reboot"; key: "r" }
        ListElement { name: "Shutdown"; icon: "󰐥"; action: "systemctl poweroff"; key: "s" }
        ListElement { name: "Hibernate"; icon: "󰒲"; action: "systemctl hibernate"; key: "h" }
    }

    function runAction(index) {
        if (index >= 0 && index < logoutModel.count) {
            var item = logoutModel.get(index)
            runProcess.command = ["sh", "-c", item.action]
            runProcess.running = true
            logoutRoot.actionExecuted()
        }
    }

    Process {
        id: runProcess
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
                text: "󰍃 Session Menu"
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 15
                font.bold: true
                color: Color.md3.primary
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
                    Text { text: "Execute"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "Esc"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Close"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }
            }
        }

        // Horizontal Row of Buttons
        RowLayout {
            id: buttonsRow
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    logoutRoot.menuClosed()
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    selectedIndex = (selectedIndex - 1 + logoutModel.count) % logoutModel.count
                    event.accepted = true
                } else if (event.key === Qt.Key_Right) {
                    selectedIndex = (selectedIndex + 1) % logoutModel.count
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    runAction(selectedIndex)
                    event.accepted = true
                } else {
                    var char = event.text.toLowerCase()
                    for (var i = 0; i < logoutModel.count; i++) {
                        if (logoutModel.get(i).key === char) {
                            runAction(i)
                            event.accepted = true
                            return
                        }
                    }
                }
            }

            Repeater {
                model: logoutModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    
                    readonly property bool isSelected: index === selectedIndex
                    readonly property bool isHovered: mouseArea.containsMouse
                    
                    color: isSelected ? Color.md3.primary : (isHovered ? Color.md3.surface_container_highest : Color.md3.surface_container_low)
                    border.color: isSelected ? Color.md3.primary : Color.md3.outline_variant
                    border.width: 1

                    scale: isSelected ? 1.05 : 1.0
                    transformOrigin: Item.Center
                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        Item { Layout.fillHeight: true }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: model.icon
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 24
                            color: isSelected ? Color.md3.on_primary : Color.md3.primary
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: model.name
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 11
                            font.bold: isSelected
                            color: isSelected ? Color.md3.on_primary : Color.md3.on_surface
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "[" + model.key.toUpperCase() + "]"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 9
                            font.bold: true
                            color: isSelected ? Color.md3.on_primary : Color.md3.on_surface_variant
                            opacity: isSelected ? 0.9 : 0.6
                        }

                        Item { Layout.fillHeight: true }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (selectedIndex === index) {
                                runAction(index)
                            } else {
                                selectedIndex = index
                            }
                        }
                    }
                }
            }
        }
    }
}
