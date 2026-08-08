import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Variants {
    id: root

    required property var theme
    required property var controller

    // Create one launcher window per available output
    model: Quickshell.screens

    PanelWindow {
        id: launcher

        property var modelData // `modelData` is provided by Variants
        screen: modelData
        visible: root.controller.visible && root.controller.targetScreen === modelData
        color: Qt.rgba(0, 0, 0, 0.47) // backdrop
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "everforest-launcher"

        /*
         * Build the visible application list.
         *
         * Search matches:
         *   - application name
         *   - generic name
         *   - executable string
         *   - desktop-entry comment
         *
         * Prefix matches are sorted before ordinary substring matches
         */
        readonly property var filteredEntries: {
            const needle = searchField.text.trim().toLowerCase();
            const applications = DesktopEntries.applications.values || [];

            // TODO: Add fuzzy search
            const matching = applications.filter(entry => {
                // Ignore malformed/unnamed desktop entries
                if (!entry || !entry.name)
                    return false;

                // Empty search shows all available applications
                if (needle.length === 0)
                    return true;

                const genericName = entry.genericName || "";
                const comment = entry.comment || "";
                const execString = entry.execString || "";
                const haystack = (entry.name + " " + genericName + " " + comment + " " + execString).toLowerCase();

                return haystack.includes(needle);
            });

            matching.sort((a, b) => {
                const aName = a.name.toLowerCase();
                const bName = b.name.toLowerCase();

                const aStarts = needle.length > 0 && aName.startsWith(needle);
                const bStarts = needle.length > 0 && bName.startsWith(needle);

                // Prefer applications whose names begin with the search query
                if (aStarts !== bStarts)
                    return aStarts ? -1 : 1;

                return aName.localeCompare(bName);
            });

            // Avoid rendering an unnecessarily large result list
            return matching.slice(0, 50);
        }

        // Keep launching in one place so mouse and keyboard paths behave identically
        function launchEntry(entry) {
            if (!entry)
                return;

            entry.execute();
            root.controller.hide();
        }

        // Launch the currently highlighted result when Enter is pressed
        function launchCurrent() {
            const index = results.currentIndex;

            if (index < 0 || index >= filteredEntries.length)
                return;

            launchEntry(filteredEntries[index]);
        }

        onVisibleChanged: {
            if (!visible)
                return;

            // When launcher opens
            searchField.text = ""; // Clear input
            results.currentIndex = 0; // Set to first entry
            Qt.callLater(() => searchField.forceActiveFocus()); // Get keyboard focus
        }

        // Clicking anywhere outside the launcher card closes the launcher
        MouseArea {
            anchors.fill: parent
            onClicked: root.controller.hide()
        }

        // Main Container
        Rectangle {
            id: launcherCard

            anchors.centerIn: parent
            width: Math.min(660, launcher.width - 48)
            height: Math.min(590, launcher.height - 80)

            radius: root.theme.radius + 4
            color: root.theme.bg0

            border.width: 1
            border.color: root.theme.bg3

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // Search box
                Rectangle {
                    width: parent.width
                    height: 50

                    radius: root.theme.radius
                    color: root.theme.bg1

                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: root.theme.green

                    TextInput {
                        id: searchField

                        anchors.fill: parent
                        anchors.margins: 14

                        color: root.theme.fg
                        selectionColor: root.theme.bgGreen
                        selectedTextColor: root.theme.fg

                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize + 2

                        clip: true // Stop overflowing test over input box

                        // Reset selection whenever the query changes
                        onTextChanged: Qt.callLater(() => {
                            results.currentIndex = results.count > 0 ? 0 : -1;
                            results.positionViewAtBeginning();
                        })

                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.controller.hide();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) { // Ctrl+n
                                if (results.count > 0) {
                                    results.currentIndex = Math.min(results.count - 1, results.currentIndex + 1);

                                    results.positionViewAtIndex(results.currentIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) { // Ctrl+p
                                if (results.count > 0) {
                                    results.currentIndex = Math.max(0, results.currentIndex - 1);

                                    results.positionViewAtIndex(results.currentIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                launcher.launchCurrent();
                                event.accepted = true;
                            }
                        }
                    }

                    // Placeholder text
                    Text {
                        anchors.fill: parent
                        anchors.margins: 14

                        verticalAlignment: Text.AlignVCenter

                        text: "Search applications"
                        visible: searchField.text.length === 0

                        color: root.theme.grey0
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize + 2
                    }
                }

                // Search results
                ListView {
                    id: results

                    width: parent.width
                    height: parent.height - 62

                    // ScriptModel exposes the JavaScript array as a proper QML model
                    // `modelData` in each delegate is therefore the DesktopEntry
                    model: ScriptModel {
                        values: launcher.filteredEntries
                    }

                    clip: true
                    spacing: 4

                    currentIndex: count > 0 ? 0 : -1

                    // Keep the selected row valid when search results shrink/grow
                    onCountChanged: {
                        if (count === 0)
                            currentIndex = -1;
                        else if (currentIndex < 0 || currentIndex >= count)
                            currentIndex = 0;
                    }

                    delegate: Rectangle {
                        id: resultRow

                        // These roles are supplied by ListView
                        required property var modelData
                        required property int index

                        property var entry: modelData
                        property bool selected: ListView.isCurrentItem

                        width: ListView.view.width
                        height: 58

                        radius: root.theme.radius

                        color: resultRow.selected ? root.theme.bgGreen : (resultMouse.containsMouse ? root.theme.bg2 : "transparent")

                        Row {
                            anchors.fill: parent
                            anchors.margins: 9
                            spacing: 13

                            // Application icon
                            Item {
                                width: 38
                                height: 38

                                IconImage {
                                    id: appIcon

                                    anchors.centerIn: parent
                                    implicitSize: 32

                                    source: Quickshell.iconPath(resultRow.entry.icon, true)

                                    visible: source.toString().length > 0
                                }
                                // fallback "first letter as icon" if unavailable
                                Text {
                                    anchors.centerIn: parent

                                    visible: !appIcon.visible

                                    text: resultRow.entry && resultRow.entry.name ? resultRow.entry.name[0].toUpperCase() : "?"

                                    color: root.theme.green
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.iconSize
                                    font.bold: true
                                }
                            }

                            // Application name and optional description
                            Column {
                                width: parent.width - 51

                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    width: parent.width

                                    text: resultRow.entry && resultRow.entry.name ? resultRow.entry.name : ""

                                    color: root.theme.fg
                                    elide: Text.ElideRight

                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.textSize + 1
                                    font.bold: resultRow.selected
                                }

                                Text {
                                    width: parent.width

                                    text: resultRow.entry ? (resultRow.entry.genericName || resultRow.entry.comment || "") : ""

                                    color: root.theme.grey1
                                    elide: Text.ElideRight
                                    visible: text.length > 0

                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }
                            }
                        }

                        // Hover follows the mouse by updating `ListView.currentIndex`
                        // Clicking launches exactly the same entry that is displayed
                        MouseArea {
                            id: resultMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: results.currentIndex = resultRow.index
                            onClicked: launcher.launchEntry(resultRow.entry)
                        }
                    }

                    // Empty state message for searches with no matches
                    Text {
                        anchors.centerIn: parent

                        visible: results.count === 0
                        text: "No application found"

                        color: root.theme.grey1
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textSize
                    }
                }
            }
        }
    }
}
