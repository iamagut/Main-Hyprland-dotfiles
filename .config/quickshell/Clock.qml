import QtQuick
import Quickshell

Item {
  id: clockRoot

  property bool expanded: mouseArea.containsMouse

  implicitWidth: background.implicitWidth
  implicitHeight: background.implicitHeight
  width: implicitWidth
  height: implicitHeight

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }

  Rectangle {
    id: background
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: layout.implicitWidth + (clockRoot.expanded ? 24 : 12)
    implicitHeight: layout.implicitHeight + 8
    radius: height / 2
    color: clockRoot.expanded ? Color.md3.surface_container_high : "transparent"

    Behavior on implicitWidth {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
    Behavior on color {
      ColorAnimation { duration: 200 }
    }

    Row {
      id: layout
      anchors.centerIn: parent
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(systemClock.date, "hh:mm")
        color: Color.md3.on_surface
        font.pixelSize: 14
        font.bold: true
        font.family: "Jetbrains Mono Nerd Font Propo"
      }

      Text {
        id: dateText
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(systemClock.date, "dddd, MMMM d")
        color: Color.md3.on_surface_variant
        font.pixelSize: 12
        font.family: "Jetbrains Mono Nerd Font Propo"
        clip: true

        opacity: clockRoot.expanded ? 1 : 0
        width: clockRoot.expanded ? implicitWidth : 0

        Behavior on opacity {
          NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Behavior on width {
          NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
  }
}
 import QtQuick
import Quickshell

Row {
    id: clockRoot
    spacing: 6

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(systemClock.date, "hh:mm")
        color: Color.md3.on_surface
        font.pixelSize: 14
        font.bold: true
        font.family: "Jetbrains Mono Nerd Font Propo"
    }
}
