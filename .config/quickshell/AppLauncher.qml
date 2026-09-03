import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Effects

Item {
    id: launcherRoot

    property bool active: false
    signal appLaunched()

    property string searchQuery: ""
    property string selectedCategory: "All"
    property int selectedIndex: 0
    property bool isGridView: false

    property var recentAppIds: []

    property var filteredApps: []
    property var categoriesList: ["All", "Internet", "Development", "Office", "Graphics", "Multimedia", "System", "Utility", "Games"]

    onActiveChanged: {
        if (active) {
            searchQuery = ""
            selectedIndex = 0
            searchField.text = ""
            searchField.forceActiveFocus()
            updateFilteredApps()
        }
    }

    function getDisplayCategory(catList) {
        if (!catList || catList.length === 0) return "Utility"
        var catsStr = catList.join(" ").toLowerCase()
        if (catsStr.includes("development") || catsStr.includes("ide") || catsStr.includes("building")) return "Development"
        if (catsStr.includes("network") || catsStr.includes("webbrowser") || catsStr.includes("email") || catsStr.includes("chat")) return "Internet"
        if (catsStr.includes("audiovideo") || catsStr.includes("audio") || catsStr.includes("video") || catsStr.includes("player") || catsStr.includes("music")) return "Multimedia"
        if (catsStr.includes("graphics") || catsStr.includes("photography") || catsStr.includes("image")) return "Graphics"
        if (catsStr.includes("office") || catsStr.includes("wordprocessor") || catsStr.includes("spreadsheet") || catsStr.includes("document")) return "Office"
        if (catsStr.includes("system") || catsStr.includes("settings") || catsStr.includes("packagemanager") || catsStr.includes("terminal")) return "System"
        if (catsStr.includes("game")) return "Games"
        return "Utility"
    }

    function getIconSource(iconName) {
        if (!iconName || iconName === "") return "image://icon/application-x-executable"
        if (iconName.startsWith("/")) return "file://" + iconName
        if (iconName.startsWith("file://") || iconName.startsWith("image://")) return iconName
        return Quickshell.iconPath(iconName, "application-x-executable")
    }

    function updateFilteredApps() {
        var allApps = DesktopEntries.applications.values || []
        var query = searchQuery.trim().toLowerCase()
        var catFilter = selectedCategory

        var list = []
        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i]
            if (!app || app.noDisplay) continue

            var appCategory = getDisplayCategory(app.categories)
            if (catFilter !== "All" && appCategory !== catFilter) {
                continue
            }

            if (query !== "") {
                var name = (app.name || "").toLowerCase()
                var genName = (app.genericName || "").toLowerCase()
                var comment = (app.comment || "").toLowerCase()
                var execStr = (app.execString || "").toLowerCase()
                var appId = (app.id || "").toLowerCase()

                if (name.includes(query) || genName.includes(query) || comment.includes(query) || execStr.includes(query) || appId.includes(query)) {
                    var score = 0
                    if (name.startsWith(query)) score += 100
                    else if (name.includes(query)) score += 50
                    if (genName.startsWith(query)) score += 30
                    if (appId.startsWith(query)) score += 40

                    list.push({
                        app: app,
                        category: appCategory,
                        score: score
                    })
                }
            } else {
                list.push({
                    app: app,
                    category: appCategory,
                    score: 0
                })
            }
        }

        list.sort(function(a, b) {
            if (b.score !== a.score) return b.score - a.score
            return a.app.name.localeCompare(b.app.name)
        })

        filteredApps = list
        if (selectedIndex >= filteredApps.length) {
            selectedIndex = Math.max(0, filteredApps.length - 1)
        }
    }

    function launchApp(app) {
        if (!app) return

        var id = app.id
        if (id) {
            var idx = recentAppIds.indexOf(id)
            if (idx !== -1) recentAppIds.splice(idx, 1)
            recentAppIds.unshift(id)
            if (recentAppIds.length > 6) recentAppIds.pop()
        }

        app.execute()
        launcherRoot.appLaunched()
    }

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            updateFilteredApps()
        }
    }

    onSearchQueryChanged: updateFilteredApps()
    onSelectedIndexChanged: {
        if (isGridView) {
            appsGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
        } else {
            appsList.positionViewAtIndex(selectedIndex, ListView.Contain)
        }
    }
    onSelectedCategoryChanged: {
        selectedIndex = 0
        updateFilteredApps()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // --- HEADER BAR ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "󰵆 Applications"
                font.family: "Jetbrains Mono Nerd Font Propo"
                font.pixelSize: 15
                font.bold: true
                color: Color.md3.primary
            }

            Text {
                text: "(" + launcherRoot.filteredApps.length + " available)"
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
                    Text { text: "↑ ↓ ← →"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Navigate"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "↵"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Launch"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "Esc"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; font.bold: true; color: Color.md3.primary }
                    Text { text: "Close"; font.family: "Jetbrains Mono Nerd Font Propo"; font.pixelSize: 11; color: Color.md3.on_surface_variant }
                }
            }
        }

        // --- SEARCH BAR & VIEW TOGGLE ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Search Box
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
                            text: "Type to search apps..."
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 13
                            color: Color.md3.on_surface_variant
                            opacity: 0.6
                            visible: searchField.text === "" && !searchField.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onTextChanged: {
                            launcherRoot.searchQuery = text
                            launcherRoot.selectedIndex = 0
                        }

                        Keys.onDownPressed: {
                            var cols = launcherRoot.isGridView ? Math.max(1, Math.floor(appsGrid.width / appsGrid.cellWidth)) : 1
                            if (launcherRoot.selectedIndex + cols < launcherRoot.filteredApps.length) {
                                launcherRoot.selectedIndex += cols
                            } else {
                                launcherRoot.selectedIndex = launcherRoot.filteredApps.length - 1
                            }
                        }

                        Keys.onUpPressed: {
                            var cols = launcherRoot.isGridView ? Math.max(1, Math.floor(appsGrid.width / appsGrid.cellWidth)) : 1
                            if (launcherRoot.selectedIndex - cols >= 0) {
                                launcherRoot.selectedIndex -= cols
                            } else {
                                launcherRoot.selectedIndex = 0
                            }
                        }

                        Keys.onRightPressed: {
                            if (launcherRoot.isGridView && launcherRoot.selectedIndex + 1 < launcherRoot.filteredApps.length) {
                                launcherRoot.selectedIndex += 1
                            }
                        }

                        Keys.onLeftPressed: {
                            if (launcherRoot.isGridView && launcherRoot.selectedIndex - 1 >= 0) {
                                launcherRoot.selectedIndex -= 1
                            }
                        }

                        Keys.onReturnPressed: {
                            if (launcherRoot.filteredApps.length > 0 && launcherRoot.selectedIndex >= 0) {
                                var item = launcherRoot.filteredApps[launcherRoot.selectedIndex]
                                if (item) launcherRoot.launchApp(item.app)
                            }
                        }

                        Keys.onEscapePressed: {
                            if (text.length > 0) {
                                text = ""
                            } else {
                                launcherRoot.appLaunched()
                            }
                        }
                    }

                    // Clear Button
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

            // Grid / List View Toggle Button
            Rectangle {
                width: 38
                height: 38
                radius: 10
                color: viewToggleMouse.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low
                border.color: Color.md3.outline_variant
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: launcherRoot.isGridView ? "󰕰" : "󰕲"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 16
                    color: Color.md3.primary
                }

                MouseArea {
                    id: viewToggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcherRoot.isGridView = !launcherRoot.isGridView
                }
            }
        }

        // --- CATEGORIES FILTER BAR ---
        ScrollView {
            Layout.fillWidth: true
            height: 32
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            RowLayout {
                spacing: 6

                Repeater {
                    model: launcherRoot.categoriesList

                    delegate: Rectangle {
                        id: catPill
                        required property string modelData
                        required property int index

                        height: 28
                        width: catText.implicitWidth + 20
                        radius: 14
                        color: launcherRoot.selectedCategory === modelData ? Color.md3.primary : (catMouse.containsMouse ? Color.md3.surface_container_highest : Color.md3.surface_container_low)
                        border.color: launcherRoot.selectedCategory === modelData ? Color.md3.primary : Color.md3.outline_variant
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            id: catText
                            anchors.centerIn: parent
                            text: catPill.modelData
                            font.family: "Jetbrains Mono Nerd Font Propo"
                            font.pixelSize: 11
                            font.bold: launcherRoot.selectedCategory === catPill.modelData
                            color: launcherRoot.selectedCategory === catPill.modelData ? Color.md3.on_primary : Color.md3.on_surface
                        }

                        MouseArea {
                            id: catMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcherRoot.selectedCategory = catPill.modelData
                        }
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Color.md3.outline_variant
            opacity: 0.5
        }

        // --- MAIN APPLICATIONS DISPLAY ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- EMPTY STATE ---
            ColumnLayout {
                anchors.centerIn: parent
                visible: launcherRoot.filteredApps.length === 0
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰅖"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 36
                    color: Color.md3.on_surface_variant
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No applications found"
                    font.family: "Jetbrains Mono Nerd Font Propo"
                    font.pixelSize: 14
                    font.bold: true
                    color: Color.md3.on_surface
                }
            }

            // --- GRID VIEW ---
            GridView {
                id: appsGrid
                anchors.fill: parent
                visible: launcherRoot.isGridView && launcherRoot.filteredApps.length > 0
                cellWidth: 195
                cellHeight: 96
                clip: true
                model: launcherRoot.filteredApps

                delegate: Item {
                    id: gridDelegate
                    required property var modelData
                    required property int index

                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight

                    readonly property bool isSelected: launcherRoot.selectedIndex === index

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 12
                        color: isSelected ? Color.md3.primary_container : (gridMouse.containsMouse ? Color.md3.surface_container_highest : "transparent")
                        border.width: 0

                        scale: isSelected ? 1.04 : 1.0
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }

                        Behavior on color { ColorAnimation { duration: 120 } }

                        layer.enabled: isSelected
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, 0.25)
                            shadowBlur: 0.4
                            shadowVerticalOffset: 3
                            shadowHorizontalOffset: 0
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Rectangle {
                                width: 42
                                height: 42
                                radius: 8
                                color: Color.md3.surface_dim

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 3
                                    source: launcherRoot.getIconSource(modelData.app.icon)
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    smooth: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.app.name
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: isSelected ? Color.md3.on_primary_container : Color.md3.on_surface
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.app.genericName || modelData.category
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 10
                                    color: isSelected ? Color.md3.on_primary_container : Color.md3.on_surface_variant
                                    elide: Text.ElideRight
                                    opacity: 0.8
                                }
                            }
                        }

                        MouseArea {
                            id: gridMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcherRoot.launchApp(modelData.app)
                            onEntered: launcherRoot.selectedIndex = index
                        }
                    }
                }
            }

            // --- LIST VIEW ---
            ListView {
                id: appsList
                anchors.fill: parent
                visible: !launcherRoot.isGridView && launcherRoot.filteredApps.length > 0
                spacing: 4
                clip: true
                model: launcherRoot.filteredApps

                delegate: Item {
                    id: listDelegate
                    required property var modelData
                    required property int index

                    width: appsList.width
                    height: 48

                    readonly property bool isSelected: launcherRoot.selectedIndex === index

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        radius: 10
                        color: isSelected ? Color.md3.primary_container : (listMouse.containsMouse ? Color.md3.surface_container_highest : "transparent")
                        border.width: 0

                        scale: isSelected ? 1.02 : 1.0
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
                            spacing: 12

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 6
                                color: Color.md3.surface_dim

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: launcherRoot.getIconSource(modelData.app.icon)
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.app.name
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: isSelected ? Color.md3.on_primary_container : Color.md3.on_surface
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.app.comment || modelData.app.genericName || modelData.app.execString
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 10
                                    color: isSelected ? Color.md3.on_primary_container : Color.md3.on_surface_variant
                                    elide: Text.ElideRight
                                    opacity: 0.8
                                }
                            }

                            Rectangle {
                                height: 20
                                width: catTagText.implicitWidth + 12
                                radius: 10
                                color: isSelected ? Color.md3.primary : Color.md3.surface_container_high

                                Text {
                                    id: catTagText
                                    anchors.centerIn: parent
                                    text: modelData.category
                                    font.family: "Jetbrains Mono Nerd Font Propo"
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: isSelected ? Color.md3.on_primary : Color.md3.on_surface_variant
                                }
                            }
                        }

                        MouseArea {
                            id: listMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcherRoot.launchApp(modelData.app)
                            onEntered: launcherRoot.selectedIndex = index
                        }
                    }
                }
            }
        }
    }
}
