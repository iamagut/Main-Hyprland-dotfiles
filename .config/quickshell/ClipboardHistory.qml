import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Item {
    id: clipboardRoot

    property bool active: false
    signal itemCopied()
    signal menuClosed()

    property string searchQuery: ""
    property string selectedType: "All" // All | Text | Images
    property int selectedIndex: 0
    property var allEntries: []
    property var filteredEntries: []
    property bool loading: false

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell/cliphist"
    readonly property var typeFilters: ["All", "Text", "Images"]

    onActiveChanged: {
        if (active) {
            searchQuery = ""
            selectedType = "All"
            selectedIndex = 0
            searchField.text = ""
            searchField.forceActiveFocus()
            refreshHistory()
        }
    }

    onSearchQueryChanged: applyFilter()
    onSelectedTypeChanged: {
        selectedIndex = 0
        applyFilter()
    }
    onSelectedIndexChanged: {
        if (filteredEntries.length > 0)
            entriesList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function isImagePreview(preview) {
        return typeof preview === "string" && preview.indexOf("[[ binary data ") === 0
    }

    function parseImageMeta(preview) {
        // [[ binary data 300 B png 64x64 ]]
        var m = preview.match(/^\[\[ binary data (.+?) (\w+) (\d+)x(\d+) \]\]$/)
        if (!m) {
            return { imageType: "img", imageSize: "", imageWidth: 0, imageHeight: 0 }
        }
        return {
            imageSize: m[1],
            imageType: m[2],
            imageWidth: parseInt(m[3]),
            imageHeight: parseInt(m[4])
        }
    }

    function parseList(text) {
        var lines = (text || "").split("\n")
        var list = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (!line || line.length === 0)
                continue

            var tab = line.indexOf("\t")
            if (tab < 0)
                continue

            var id = line.substring(0, tab)
            var preview = line.substring(tab + 1)
            var image = isImagePreview(preview)
            var meta = image ? parseImageMeta(preview) : null

            list.push({
                id: id,
                raw: line,
                preview: preview,
                isImage: image,
                imageType: meta ? meta.imageType : "",
                imageSize: meta ? meta.imageSize : "",
                imageWidth: meta ? meta.imageWidth : 0,
                imageHeight: meta ? meta.imageHeight : 0,
                cachePath: cacheDir + "/" + id
            })
        }

        allEntries = list
        applyFilter()
        loading = false
    }

    function applyFilter() {
        var query = searchQuery.trim().toLowerCase()
        var type = selectedType
        var list = []

        for (var i = 0; i < allEntries.length; i++) {
            var e = allEntries[i]
            if (type === "Text" && e.isImage)
                continue
            if (type === "Images" && !e.isImage)
                continue

            if (query !== "") {
                var hay = (e.preview || "").toLowerCase()
                if (e.isImage)
                    hay += " image " + (e.imageType || "") + " " + e.imageWidth + "x" + e.imageHeight
                if (hay.indexOf(query) < 0)
                    continue
            }

            list.push(e)
        }

        filteredEntries = list
        if (selectedIndex >= filteredEntries.length)
            selectedIndex = Math.max(0, filteredEntries.length - 1)
    }

    function refreshHistory() {
        loading = true
        if (listProcess.running)
            listProcess.running = false
        listProcess.running = true
    }

    function copyEntry(entry) {
        if (!entry)
            return

        var pipe = "printf '%s\\n' " + shellQuote(entry.raw) + " | cliphist decode | "
        if (entry.isImage) {
            var mime = entry.imageType === "jpg" ? "image/jpeg" : ("image/" + entry.imageType)
            pipe += "wl-copy --type " + mime
        } else {
            pipe += "wl-copy"
        }

        copyProcess.command = ["bash", "-c", pipe]
        copyProcess.running = true
        clipboardRoot.itemCopied()
    }

    function deleteEntry(entry) {
        if (!entry)
            return
        deleteProcess.command = ["bash", "-c",
            "printf '%s\\n' " + shellQuote(entry.raw) + " | cliphist delete; " +
            "rm -f " + shellQuote(entry.cachePath)]
        deleteProcess.running = true
    }

    function wipeHistory() {
        wipeProcess.running = true
    }

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", clipboardRoot.cacheDir]
        running: true
    }

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            id: listCollector
        }
        onExited: function(exitCode, exitStatus) {
            parseList(listCollector.text)
        }
    }

    Process {
        id: copyProcess
    }

    Process {
        id: deleteProcess
        onExited: function(exitCode, exitStatus) {
            refreshHistory()
        }
    }

    Process {
        id: wipeProcess
        command: ["bash", "-c",
            "cliphist wipe; rm -rf " + shellQuote(clipboardRoot.cacheDir) +
            " && mkdir -p " + shellQuote(clipboardRoot.cacheDir)]
        onExited: function(exitCode, exitStatus) {
            refreshHistory()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // --- HEADER ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "󰅌 Clipboard"
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 15
                font.bold: true
                color: Color.md3.primary
            }

            Text {
                text: loading ? "(loading…)" : ("(" + clipboardRoot.filteredEntries.length + " items)")
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
                    Text { text: "↑ ↓"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Navigate"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "↵"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Copy"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "Del"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Delete"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "Esc"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Close"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }
            }
        }

        // --- SEARCH + WIPE ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 10
                color: searchField.activeFocus ? Color.md3.surface_container_highest : Color.md3.surface_container_low
                border.color: searchField.activeFocus ? Color.md3.primary : Color.md3.outline_variant
                border.width: searchField.activeFocus ? 2 : 1

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "󰍉"
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 16
                        color: searchField.activeFocus ? Color.md3.primary : Color.md3.on_surface_variant
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 14
                        color: Color.md3.on_surface
                        clip: true

                        Text {
                            text: "Search clipboard history…"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 13
                            color: Color.md3.on_surface_variant
                            opacity: 0.6
                            visible: searchField.text === "" && !searchField.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onTextChanged: {
                            clipboardRoot.searchQuery = text
                            clipboardRoot.selectedIndex = 0
                        }

                        Keys.onDownPressed: {
                            if (clipboardRoot.selectedIndex + 1 < clipboardRoot.filteredEntries.length)
                                clipboardRoot.selectedIndex += 1
                        }

                        Keys.onUpPressed: {
                            if (clipboardRoot.selectedIndex > 0)
                                clipboardRoot.selectedIndex -= 1
                        }

                        Keys.onReturnPressed: {
                            if (clipboardRoot.filteredEntries.length > 0 && clipboardRoot.selectedIndex >= 0) {
                                clipboardRoot.copyEntry(clipboardRoot.filteredEntries[clipboardRoot.selectedIndex])
                            }
                        }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Delete) {
                                if (clipboardRoot.filteredEntries.length > 0 && clipboardRoot.selectedIndex >= 0) {
                                    clipboardRoot.deleteEntry(clipboardRoot.filteredEntries[clipboardRoot.selectedIndex])
                                    event.accepted = true
                                }
                            }
                        }

                        Keys.onEscapePressed: {
                            if (text.length > 0) {
                                text = ""
                            } else {
                                clipboardRoot.menuClosed()
                            }
                        }
                    }

                    Rectangle {
                        width: 22
                        height: 22
                        radius: 11
                        color: clearMouse.containsMouse ? Color.md3.surface_container_highest : "transparent"
                        visible: searchField.text.length > 0

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 13
                            color: Color.md3.on_surface_variant
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = ""
                                searchField.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 38
                height: 38
                radius: 10
                color: wipeMouse.containsMouse ? Color.md3.error_container : Color.md3.surface_container_low
                border.color: Color.md3.outline_variant
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰃢"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 16
                    color: wipeMouse.containsMouse ? Color.md3.on_error_container : Color.md3.error
                }

                MouseArea {
                    id: wipeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipboardRoot.wipeHistory()
                }
            }
        }

        // --- TYPE FILTERS ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: clipboardRoot.typeFilters

                delegate: Rectangle {
                    id: typePill
                    required property string modelData
                    required property int index

                    height: 28
                    width: typeText.implicitWidth + 20
                    radius: 14
                    color: clipboardRoot.selectedType === modelData ? Color.md3.primary : (typeMouse.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low)
                    border.color: clipboardRoot.selectedType === modelData ? Color.md3.primary : Color.md3.outline_variant
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: typeText
                        anchors.centerIn: parent
                        text: typePill.modelData
                        font.family: "Jetbrains Mono Nerd Font Propo"
                        font.pixelSize: 11
                        font.bold: clipboardRoot.selectedType === typePill.modelData
                        color: clipboardRoot.selectedType === typePill.modelData ? Color.md3.on_primary : Color.md3.on_surface
                    }

                    MouseArea {
                        id: typeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clipboardRoot.selectedType = typePill.modelData
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Color.md3.outline_variant
            opacity: 0.5
        }

        // --- ENTRIES ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: !clipboardRoot.loading && clipboardRoot.filteredEntries.length === 0
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰅌"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 36
                    color: Color.md3.on_surface_variant
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No clipboard items"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 14
                    font.bold: true
                    color: Color.md3.on_surface
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Copy text or images to populate history"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 11
                    color: Color.md3.on_surface_variant
                }
            }

            ListView {
                id: entriesList
                anchors.fill: parent
                visible: clipboardRoot.filteredEntries.length > 0
                spacing: 6
                clip: true
                model: clipboardRoot.filteredEntries

                delegate: Item {
                    id: listDelegate
                    required property var modelData
                    required property int index

                    width: entriesList.width
                    height: modelData.isImage ? 96 : 52

                    readonly property bool isSelected: clipboardRoot.selectedIndex === index

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        radius: 12
                        color: isSelected ? Color.md3.primary_container : (rowMouse.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low)
                        border.width: 0

                        scale: isSelected ? 1.01 : 1.0
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        layer.enabled: isSelected
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, 0.2)
                            shadowBlur: 0.3
                            shadowVerticalOffset: 2
                            shadowHorizontalOffset: 0
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 12
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            spacing: 12

                            // Thumbnail / icon
                            Rectangle {
                                width: modelData.isImage ? 72 : 32
                                height: modelData.isImage ? 72 : 32
                                radius: 8
                                color: Color.md3.surface_dim
                                clip: true

                                Text {
                                    anchors.centerIn: parent
                                    visible: !modelData.isImage
                                    text: "󰊄"
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 14
                                    color: isSelected ? Color.md3.primary : Color.md3.on_surface_variant
                                }

                                ClippingWrapperRectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: "transparent"
                                    visible: modelData.isImage

                                    Image {
                                        id: thumbImage
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        smooth: true
                                        mipmap: true
                                        source: ""

                                        Text {
                                            anchors.centerIn: parent
                                            visible: thumbImage.status !== Image.Ready
                                            text: "󰋩"
                                            font.family: "Jetbrains Mono Nerd Font Propo"
                                            font.pixelSize: 20
                                            color: Color.md3.on_surface_variant
                                        }
                                    }
                                }

                                Process {
                                    id: decodeProcess
                                    command: ["bash", "-c",
                                        "[ -f " + clipboardRoot.shellQuote(modelData.cachePath) + " ] || " +
                                        "printf '%s\\n' " + clipboardRoot.shellQuote(modelData.raw) +
                                        " | cliphist decode > " + clipboardRoot.shellQuote(modelData.cachePath)]

                                    onExited: function(exitCode, exitStatus) {
                                        if (exitCode === 0)
                                            thumbImage.source = "file://" + modelData.cachePath + "?t=" + Date.now()
                                    }
                                }

                                Component.onCompleted: {
                                    if (modelData.isImage)
                                        decodeProcess.running = true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 4

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.isImage
                                        ? ("Image · " + (modelData.imageType || "bin").toUpperCase())
                                        : modelData.preview.replace(/\s+/g, " ")
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: isSelected ? Color.md3.on_primary_container : Color.md3.on_surface
                                    elide: Text.ElideRight
                                    maximumLineCount: modelData.isImage ? 1 : 2
                                    wrapMode: Text.Wrap
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: modelData.isImage || modelData.preview.length > 0
                                    text: modelData.isImage
                                        ? ((modelData.imageWidth && modelData.imageHeight)
                                            ? (modelData.imageWidth + "×" + modelData.imageHeight + " · " + modelData.imageSize)
                                            : modelData.imageSize)
                                        : ("#" + modelData.id)
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 10
                                    color: isSelected ? Color.md3.on_primary_container : Color.md3.on_surface_variant
                                    elide: Text.ElideRight
                                    opacity: 0.85
                                }
                            }

                            Rectangle {
                                height: 20
                                width: kindText.implicitWidth + 12
                                radius: 10
                                color: isSelected ? Color.md3.primary : Color.md3.surface_container_high

                                Text {
                                    id: kindText
                                    anchors.centerIn: parent
                                    text: modelData.isImage ? "IMG" : "TXT"
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: isSelected ? Color.md3.on_primary : Color.md3.on_surface_variant
                                }
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: clipboardRoot.selectedIndex = index
                            onClicked: clipboardRoot.copyEntry(modelData)
                        }
                    }
                }
            }
        }
    }
}
