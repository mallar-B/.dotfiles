import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Widgets

Item {
    id: root

    required property var theme
    required property QtObject wireless
    required property QtObject targetWindow

    property int tab: 0

    property var pendingWifi: null
    property string wifiError: ""

    property var contextObject: null
    property string contextType: ""
    property real contextY: 0

    property bool askPassword: false
    property bool previousWindowFocusable: false

    implicitWidth: theme.buttonWidth
    implicitHeight: theme.buttonHeight

    // ------------------------------------------------------------
    // Wi-Fi interaction
    // ------------------------------------------------------------

    function wifiFailed(network) {
        if (!network)
            return;

        if (wireless.wifiUsesPsk(network)) {
            pendingWifi = network;
            askPassword = true;
            wifiError = "Connection failed — check password";
            passwordInput.text = "";
            passwordFocusTimer.restart();
        } else {
            wifiError = "Connection failed";
        }
    }

    function chooseWifi(network) {
        if (!network || network.connected || network.stateChanging)
            return;

        pendingWifi = network;
        wifiError = "";

        if (network.known || network.security === WifiSecurityType.Open) {
            askPassword = false;
            wireless.connectWifi(network, "");
        } else if (wireless.wifiUsesPsk(network)) {
            askPassword = true;
            passwordInput.text = "";
            passwordFocusTimer.restart();
        }
    }

    function submitPassword() {
        if (!pendingWifi || passwordInput.text.length === 0)
            return;

        wifiError = "";

        wireless.connectWifi(pendingWifi, passwordInput.text);
    }

    Timer {
        id: passwordFocusTimer

        interval: 1
        repeat: false

        onTriggered: passwordInput.forceActiveFocus()
    }

    // Connections {
    //     target: root.pendingWifi
    //     ignoreUnknownSignals: true
    //
    //     function onConnectionFailed(reason) {
    //         if (!root.pendingWifi)
    //             return;
    //
    //         if (root.wireless.wifiUsesPsk(root.pendingWifi)) {
    //             root.askPassword = true;
    //             root.wifiError = "Connection failed — enter password again";
    //
    //             // Don't keep the wrong password in the UI.
    //             passwordInput.text = "";
    //
    //             passwordFocusTimer.restart();
    //         } else {
    //             root.wifiError = ConnectionFailReason.toString(reason);
    //         }
    //     }
    //
    //     function onConnectedChanged() {
    //         if (!root.pendingWifi || !root.pendingWifi.connected)
    //             return;
    //
    //         root.pendingWifi = null;
    //         root.askPassword = false;
    //         root.wifiError = "";
    //         passwordInput.text = "";
    //
    //         root.wireless.updateWifiGeneration();
    //     }
    // }

    // ------------------------------------------------------------
    // Context actions
    // ------------------------------------------------------------

    function showContext(type, object, item) {
        contextType = type;
        contextObject = object;

        contextY = item.mapToItem(popupBackground, 0, item.height).y;
    }

    function contextActions() {
        if (!contextObject)
            return [];

        const actions = [];

        if (contextObject.connected)
            actions.push("Disconnect");
        else
            actions.push("Connect");

        if (contextType === "wifi" && contextObject.known)
            actions.push("Forget");

        if (contextType === "bluetooth" && contextObject.paired)
            actions.push("Forget");

        return actions;
    }

    function runContextAction(action) {
        const object = contextObject;
        const type = contextType;

        contextObject = null;

        if (!object)
            return;

        if (type === "wifi") {
            if (action === "Connect")
                chooseWifi(object);
            else if (action === "Disconnect")
                wireless.disconnectWifi(object);
            else
                wireless.forgetWifi(object);

            return;
        }

        if (action === "Connect")
            wireless.connectBluetooth(object);
        else if (action === "Disconnect")
            wireless.disconnectBluetooth(object);
        else
            wireless.forgetBluetooth(object);
    }

    // ------------------------------------------------------------
    // Bar icon
    // ------------------------------------------------------------

    function wifiIconName() {
        if (!wireless.wifiEnabled)
            return "network-wireless-offline-symbolic";

        if (!wireless.connectedWifi)
            return "network-wireless-signal-none-symbolic";

        return wireless.wifiSignalIcon(wireless.connectedWifi.signalStrength);
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius

        color: popup.visible ? root.theme.bgGreen : barMouse.containsMouse ? root.theme.bg2 : "transparent"

        border.width: popup.visible ? 1 : 0
        border.color: root.theme.green

        IconImage {
            anchors.centerIn: parent
            implicitSize: root.theme.iconSize

            source: Quickshell.iconPath(root.wifiIconName(), "network-wireless-symbolic")
        }

        IconImage {
            visible: root.wireless.connectedBluetoothCount > 0

            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.rightMargin: 2
            anchors.bottomMargin: 2

            implicitSize: 11

            source: Quickshell.iconPath("bluetooth-active-symbolic", "bluetooth-symbolic")
        }

        MouseArea {
            id: barMouse

            anchors.fill: parent
            hoverEnabled: true

            onClicked: popup.visible = !popup.visible
        }
    }

    HoverTooltip {
        theme: root.theme
        anchorItem: root

        visible: barMouse.containsMouse && !popup.visible

        text: root.wireless.statusText
    }

    // ============================================================
    // MAIN POPUP
    // ============================================================

    PopupWindow {
        id: popup

        anchor.item: root
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right

        anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide

        anchor.margins.left: 10

        grabFocus: true
        color: "transparent"

        implicitWidth: 360
        implicitHeight: 520

        onVisibleChanged: {
            if (visible) {
                /*
                 * PanelWindow.focusable defaults to false.
                 * The popup can visually open without the parent
                 * layershell surface accepting keyboard input.
                 */
                root.previousWindowFocusable = root.targetWindow.focusable;

                root.targetWindow.focusable = true;

                root.wireless.startScan();
            } else {
                root.wireless.stopScan();

                root.targetWindow.focusable = root.previousWindowFocusable;

                root.pendingWifi = null;
                root.askPassword = null;
                root.contextObject = null;
                root.wifiError = "";

                searchInput.text = "";
                passwordInput.text = "";
            }
        }

        Rectangle {
            id: popupBackground

            anchors.fill: parent

            radius: root.theme.radius + 2
            color: root.theme.bg0

            border.width: 1
            border.color: root.theme.bg3

            Column {
                id: content

                anchors.fill: parent
                anchors.margins: 10

                spacing: 8

                // ------------------------------------------------
                // Header
                // ------------------------------------------------

                Item {
                    width: content.width
                    height: 34

                    Row {
                        anchors.left: parent.left

                        spacing: 5

                        Repeater {
                            model: ["Wi-Fi", "Bluetooth"]

                            delegate: Rectangle {
                                id: tabButton

                                required property string modelData
                                required property int index

                                width: 100
                                height: 32

                                radius: root.theme.radius

                                color: root.tab === index ? root.theme.bgGreen : tabMouse.containsMouse ? root.theme.bg2 : "transparent"

                                border.width: root.tab === index ? 1 : 0

                                border.color: root.theme.green

                                Text {
                                    anchors.centerIn: parent

                                    text: tabButton.modelData

                                    color: root.tab === tabButton.index ? root.theme.green : root.theme.fg

                                    font.family: root.theme.fontFamily

                                    font.pixelSize: root.theme.textSize
                                }

                                MouseArea {
                                    id: tabMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: {
                                        root.tab = tabButton.index;

                                        root.contextObject = null;
                                        root.pendingWifi = null;
                                        root.wifiError = "";

                                        searchInput.text = "";
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right

                        width: 32
                        height: 32

                        radius: root.theme.radius

                        color: gearMouse.containsMouse ? root.theme.bg2 : "transparent"

                        IconImage {
                            anchors.centerIn: parent

                            implicitSize: 18

                            source: Quickshell.iconPath("preferences-system-symbolic", "emblem-system-symbolic")
                        }

                        MouseArea {
                            id: gearMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if (root.tab === 0)
                                    root.wireless.openWifiSettings();
                                else
                                    root.wireless.openBluetoothSettings();
                            }
                        }
                    }
                }

                // ------------------------------------------------
                // Search
                // ------------------------------------------------

                Rectangle {
                    width: content.width
                    height: 34

                    radius: root.theme.radius
                    color: root.theme.bg1

                    border.width: 1

                    border.color: searchInput.activeFocus ? root.theme.green : root.theme.bg3

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        visible: searchInput.text.length === 0

                        text: root.tab === 0 ? "Search Wi-Fi…" : "Search devices…"

                        color: root.theme.grey1

                        font.family: root.theme.fontFamily

                        font.pixelSize: root.theme.textSize
                    }

                    TextInput {
                        id: searchInput

                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        verticalAlignment: TextInput.AlignVCenter

                        color: root.theme.fg

                        selectByMouse: true
                        clip: true

                        font.family: root.theme.fontFamily

                        font.pixelSize: root.theme.textSize

                        Keys.onEscapePressed: popup.visible = false
                    }
                }

                // ==================================================
                // Wi-Fi
                // ==================================================

                Item {
                    visible: root.tab === 0

                    width: content.width
                    height: visible ? 430 : 0

                    Column {
                        anchors.fill: parent
                        spacing: 6

                        Row {
                            width: parent.width
                            height: 30
                            spacing: 5

                            Text {
                                width: parent.width - 115
                                anchors.verticalCenter: parent.verticalCenter

                                text: !root.wireless.wifiAvailable ? "Wi-Fi unavailable" : root.wireless.wifiScanning ? "Wi-Fi • scanning…" : "Wi-Fi"

                                color: root.wireless.wifiScanning ? root.theme.green : root.theme.grey1

                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize
                            }

                            Rectangle {
                                width: 30
                                height: 28
                                radius: root.theme.radius

                                color: wifiRescanMouse.containsMouse ? root.theme.bg2 : "transparent"

                                IconImage {
                                    anchors.centerIn: parent
                                    implicitSize: 16

                                    source: Quickshell.iconPath("view-refresh-symbolic", "view-refresh")
                                }

                                MouseArea {
                                    id: wifiRescanMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    enabled: root.wireless.wifiEnabled

                                    onClicked: root.wireless.rescanWifi()
                                }
                            }

                            Rectangle {
                                width: 75
                                height: 28

                                radius: root.theme.radius

                                color: root.wireless.wifiEnabled ? root.theme.bgGreen : root.theme.bg2

                                border.width: 1

                                border.color: root.wireless.wifiEnabled ? root.theme.green : root.theme.bg3

                                Text {
                                    anchors.centerIn: parent

                                    text: root.wireless.wifiEnabled ? "On" : "Off"

                                    color: root.wireless.wifiEnabled ? root.theme.green : root.theme.grey1

                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: root.wireless.toggleWifi()
                                }
                            }
                        }

                        ScriptModel {
                            id: wifiModel

                            values: {
                                const query = searchInput.text.toLowerCase();

                                const networks = root.wireless.wifiDevice ? root.wireless.wifiDevice.networks.values : [];

                                return [...networks].filter(n => n.name && n.name.toLowerCase().includes(query)).sort((a, b) => {
                                    if (a.connected !== b.connected)
                                        return a.connected ? -1 : 1;

                                    return b.signalStrength - a.signalStrength;
                                });
                            }
                        }

                        ListView {
                            id: wifiList

                            width: parent.width

                            height: root.askPassword ? 280 : 355

                            clip: true
                            spacing: 4

                            model: wifiModel

                            delegate: Rectangle {
                                id: wifiRow

                                required property var modelData

                                width: wifiList.width
                                height: 50

                                radius: root.theme.radius

                                color: modelData.connected ? root.theme.bgGreen : wifiMouse.containsMouse ? root.theme.bg2 : "transparent"

                                border.width: modelData.connected ? 1 : 0

                                border.color: root.theme.green

                                Connections {
                                    target: wifiRow.modelData

                                    function onConnectionFailed(reason) {
                                        root.wifiFailed(wifiRow.modelData);
                                    }

                                    function onConnectedChanged() {
                                        if (!wifiRow.modelData.connected)
                                            return;

                                        if (root.pendingWifi === wifiRow.modelData) {
                                            root.pendingWifi = null;
                                            root.askPassword = false;
                                            root.wifiError = "";
                                            passwordInput.text = "";
                                        }

                                        root.wireless.updateWifiGeneration();
                                    }
                                }

                                Item {
                                    id: wifiIconArea

                                    anchors.left: parent.left
                                    anchors.leftMargin: 8

                                    anchors.verticalCenter: parent.verticalCenter

                                    width: 24
                                    height: 24

                                    IconImage {
                                        anchors.centerIn: parent

                                        implicitSize: 21

                                        source: Quickshell.iconPath(root.wireless.wifiSignalIcon(wifiRow.modelData.signalStrength), "network-wireless-symbolic")
                                    }

                                    /*
                                     * QuickShell does not expose
                                     * generation for scanned APs.
                                     *
                                     * Show it only on the currently
                                     * negotiated connection.
                                     */
                                    Rectangle {
                                        visible: wifiRow.modelData.connected && root.wireless.wifiGeneration.length > 0
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        width: 11
                                        height: 11
                                        radius: 3
                                        color: "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: root.wireless.wifiGeneration
                                            color: root.theme.green
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }
                                }

                                Column {
                                    anchors.left: wifiIconArea.right

                                    anchors.leftMargin: 8

                                    anchors.right: parent.right
                                    anchors.rightMargin: 8

                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        width: parent.width

                                        text: wifiRow.modelData.name

                                        color: wifiRow.modelData.connected ? root.theme.green : root.theme.fg

                                        elide: Text.ElideRight

                                        font.family: root.theme.fontFamily

                                        font.pixelSize: root.theme.textSize
                                    }

                                    Text {
                                        text: Math.round(wifiRow.modelData.signalStrength * 100) + "% • " + root.wireless.wifiSecurityLabel(wifiRow.modelData) + (wifiRow.modelData.connected ? " • Connected" : wifiRow.modelData.known ? " • Saved" : "")

                                        color: root.theme.grey1

                                        font.family: root.theme.fontFamily

                                        font.pixelSize: root.theme.smallTextSize
                                    }
                                }

                                MouseArea {
                                    id: wifiMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton) {
                                            root.showContext("wifi", wifiRow.modelData, wifiRow);

                                            return;
                                        }

                                        root.chooseWifi(wifiRow.modelData);
                                    }
                                }
                            }
                        }

                        // ------------------------------------------
                        // Password prompt
                        // ------------------------------------------

                        Rectangle {
                            visible: root.pendingWifi !== null && root.askPassword

                            width: parent.width
                            height: visible ? 70 : 0

                            radius: root.theme.radius

                            color: root.theme.bg1

                            border.width: 1

                            border.color: root.wifiError.length > 0 ? root.theme.red : root.theme.bg3

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8

                                anchors.top: parent.top
                                anchors.topMargin: 6

                                text: root.wifiError.length > 0 ? root.wifiError : "Password for " + (root.pendingWifi ? root.pendingWifi.name : "")

                                color: root.wifiError.length > 0 ? root.theme.red : root.theme.grey1

                                font.family: root.theme.fontFamily

                                font.pixelSize: root.theme.smallTextSize
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: connectButton.left

                                anchors.leftMargin: 8
                                anchors.rightMargin: 6

                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 6

                                height: 30

                                radius: root.theme.radius

                                color: root.theme.bg0

                                border.width: passwordInput.activeFocus ? 1 : 0

                                border.color: root.theme.green

                                TextInput {
                                    id: passwordInput

                                    anchors.fill: parent

                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8

                                    verticalAlignment: TextInput.AlignVCenter

                                    focus: root.pendingWifi !== null

                                    echoMode: TextInput.Password

                                    color: root.theme.fg

                                    selectByMouse: true
                                    clip: true

                                    font.family: root.theme.fontFamily

                                    font.pixelSize: root.theme.textSize

                                    Keys.onReturnPressed: root.submitPassword()

                                    Keys.onEnterPressed: root.submitPassword()

                                    Keys.onEscapePressed: {
                                        root.pendingWifi = null;
                                        root.wifiError = "";
                                    }
                                }
                            }

                            Rectangle {
                                id: connectButton

                                anchors.right: parent.right
                                anchors.rightMargin: 8

                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 6

                                width: 70
                                height: 30

                                radius: root.theme.radius

                                color: connectMouse.containsMouse ? root.theme.bgGreen : root.theme.bg2

                                Text {
                                    anchors.centerIn: parent

                                    text: "Connect"
                                    color: root.theme.green

                                    font.family: root.theme.fontFamily

                                    font.pixelSize: root.theme.smallTextSize
                                }

                                MouseArea {
                                    id: connectMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: root.submitPassword()
                                }
                            }
                        }
                    }
                }

                // ==================================================
                // Bluetooth
                // ==================================================

                Item {
                    visible: root.tab === 1

                    width: content.width
                    height: visible ? 430 : 0

                    Column {
                        anchors.fill: parent
                        spacing: 6

                        Row {
                            width: parent.width
                            height: 30
                            spacing: 5

                            Text {
                                width: parent.width - 115
                                anchors.verticalCenter: parent.verticalCenter

                                text: !root.wireless.bluetoothAvailable ? "Bluetooth unavailable" : root.wireless.bluetoothScanning ? "Bluetooth • scanning…" : "Bluetooth"

                                color: root.wireless.bluetoothScanning ? root.theme.green : root.theme.grey1

                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.smallTextSize
                            }

                            Rectangle {
                                width: 30
                                height: 28
                                radius: root.theme.radius

                                color: btRescanMouse.containsMouse ? root.theme.bg2 : "transparent"

                                IconImage {
                                    anchors.centerIn: parent
                                    implicitSize: 16

                                    source: Quickshell.iconPath("view-refresh-symbolic", "view-refresh")
                                }

                                MouseArea {
                                    id: btRescanMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    enabled: root.wireless.bluetoothEnabled

                                    onClicked: root.wireless.rescanBluetooth()
                                }
                            }

                            Rectangle {
                                width: 75
                                height: 28

                                radius: root.theme.radius

                                color: root.wireless.bluetoothEnabled ? root.theme.bgGreen : root.theme.bg2

                                border.width: 1

                                border.color: root.wireless.bluetoothEnabled ? root.theme.green : root.theme.bg3

                                Text {
                                    anchors.centerIn: parent

                                    text: root.wireless.bluetoothEnabled ? "On" : "Off"

                                    color: root.wireless.bluetoothEnabled ? root.theme.green : root.theme.grey1

                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.smallTextSize
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: root.wireless.toggleBluetooth()
                                }
                            }
                        }

                        ScriptModel {
                            id: bluetoothModel

                            values: {
                                const query = searchInput.text.toLowerCase();

                                const devices = root.wireless.bluetoothAdapter ? root.wireless.bluetoothAdapter.devices.values : [];

                                return [...devices].filter(device => (device.name || device.deviceName || device.address).toLowerCase().includes(query)).sort((a, b) => {
                                    if (a.connected !== b.connected)
                                        return a.connected ? -1 : 1;

                                    if (a.paired !== b.paired)
                                        return a.paired ? -1 : 1;

                                    return (a.name || "").localeCompare(b.name || "");
                                });
                            }
                        }

                        ListView {
                            id: bluetoothList

                            width: parent.width
                            height: 390

                            clip: true
                            spacing: 4

                            model: bluetoothModel

                            delegate: Rectangle {
                                id: bluetoothRow

                                required property var modelData

                                width: bluetoothList.width
                                height: 50

                                radius: root.theme.radius

                                color: modelData.connected ? root.theme.bgGreen : btMouse.containsMouse ? root.theme.bg2 : "transparent"

                                border.width: modelData.connected ? 1 : 0

                                border.color: root.theme.green

                                IconImage {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8

                                    anchors.verticalCenter: parent.verticalCenter

                                    implicitSize: 21

                                    source: Quickshell.iconPath(bluetoothRow.modelData.icon, "bluetooth-symbolic")
                                }

                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 40

                                    anchors.right: parent.right
                                    anchors.rightMargin: 8

                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        width: parent.width

                                        text: bluetoothRow.modelData.name || bluetoothRow.modelData.deviceName || bluetoothRow.modelData.address

                                        color: bluetoothRow.modelData.connected ? root.theme.green : root.theme.fg

                                        elide: Text.ElideRight

                                        font.family: root.theme.fontFamily

                                        font.pixelSize: root.theme.textSize
                                    }

                                    Text {
                                        text: {
                                            const device = bluetoothRow.modelData;

                                            if (device.connected && device.batteryAvailable) {
                                                return "Connected • " + Math.round(device.battery * 100) + "%";
                                            }

                                            if (device.connected)
                                                return "Connected";

                                            if (device.pairing)
                                                return "Pairing…";

                                            if (device.paired)
                                                return "Paired";

                                            return device.address;
                                        }

                                        color: root.theme.grey1

                                        font.family: root.theme.fontFamily

                                        font.pixelSize: root.theme.smallTextSize
                                    }
                                }

                                MouseArea {
                                    id: btMouse

                                    anchors.fill: parent
                                    hoverEnabled: true

                                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton) {
                                            root.showContext("bluetooth", bluetoothRow.modelData, bluetoothRow);

                                            return;
                                        }

                                        /*
                                         * Left click = connect only.
                                         */
                                        root.wireless.connectBluetooth(bluetoothRow.modelData);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ======================================================
            // RIGHT CLICK CONTEXT MENU
            // ======================================================

            Rectangle {
                id: contextMenu

                visible: root.contextObject !== null && root.contextActions().length > 0

                z: 100

                width: 125

                height: visible ? contextColumn.implicitHeight + 8 : 0

                x: popupBackground.width - width - 8

                y: Math.min(root.contextY, popupBackground.height - height - 8)

                radius: root.theme.radius

                color: root.theme.bg1

                border.width: 1
                border.color: root.theme.bg3

                Column {
                    id: contextColumn

                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.top: parent.top
                    anchors.topMargin: 4

                    spacing: 2

                    Repeater {
                        model: root.contextActions()

                        delegate: Rectangle {
                            id: contextAction

                            required property string modelData

                            width: contextColumn.width
                            height: 30

                            radius: root.theme.radius

                            color: contextMouse.containsMouse ? (modelData === "Forget" ? root.theme.bgRed : root.theme.bg2) : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10

                                anchors.verticalCenter: parent.verticalCenter

                                text: contextAction.modelData

                                color: contextAction.modelData === "Forget" ? root.theme.red : root.theme.fg

                                font.family: root.theme.fontFamily

                                font.pixelSize: root.theme.smallTextSize
                            }

                            MouseArea {
                                id: contextMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: root.runContextAction(contextAction.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
