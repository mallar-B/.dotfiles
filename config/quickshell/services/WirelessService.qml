import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth

Scope {
    id: root

    property QtObject notifications: null
    property bool scanRequested: false
    property string wifiGeneration: ""
    property string settingsKind: ""
    property string rescanTarget: ""

    readonly property bool networkingAvailable: Networking.backend !== NetworkBackendType.None

    readonly property var wifiDevice: {
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi)
                return device;
        }

        return null;
    }

    readonly property bool wifiAvailable: networkingAvailable && wifiDevice !== null

    readonly property bool wifiEnabled: wifiAvailable && Networking.wifiHardwareEnabled && Networking.wifiEnabled

    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []

    readonly property var connectedWifi: {
        for (const network of wifiNetworks) {
            if (network.connected)
                return network;
        }

        return null;
    }
    readonly property bool wifiScanning: wifiDevice && wifiDevice.scannerEnabled

    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter

    readonly property bool bluetoothAvailable: bluetoothAdapter !== null

    readonly property bool bluetoothEnabled: bluetoothAvailable && bluetoothAdapter.enabled

    readonly property var bluetoothDevices: bluetoothAdapter ? bluetoothAdapter.devices.values : []

    readonly property int connectedBluetoothCount: {
        let count = 0;

        for (const device of bluetoothDevices) {
            if (device.connected)
                ++count;
        }

        return count;
    }
    readonly property bool bluetoothScanning: bluetoothAdapter && bluetoothAdapter.discovering

    readonly property string statusText: {
        const result = [];

        result.push(connectedWifi ? "Wi-Fi: " + connectedWifi.name : wifiEnabled ? "Wi-Fi disconnected" : "Wi-Fi off");

        if (connectedBluetoothCount > 0) {
            result.push(connectedBluetoothCount + " Bluetooth device" + (connectedBluetoothCount === 1 ? "" : "s"));
        }

        return result.join(" • ");
    }

    // ------------------------------------------------------------
    // Scanning
    // ------------------------------------------------------------

    Timer {
        id: rescanTimer

        interval: 200

        onTriggered: {
            if (!root.scanRequested)
                return;

            if (root.rescanTarget === "wifi" && root.wifiDevice)
                root.wifiDevice.scannerEnabled = true;

            if (root.rescanTarget === "bluetooth" && root.bluetoothAdapter)
                root.bluetoothAdapter.discovering = true;

            root.rescanTarget = "";
        }
    }

    function startScan() {
        scanRequested = true;
        updateScan();
        updateWifiGeneration();
    }

    function stopScan() {
        scanRequested = false;

        rescanTimer.stop();
        rescanTarget = "";

        updateScan();
    }

    function updateScan() {
        if (wifiDevice)
            wifiDevice.scannerEnabled = scanRequested && wifiEnabled;

        if (bluetoothAdapter)
            bluetoothAdapter.discovering = scanRequested && bluetoothAdapter.enabled;
    }

    function rescanWifi() {
        if (!wifiDevice || !wifiEnabled)
            return;

        wifiDevice.scannerEnabled = false;

        rescanTarget = "wifi";
        rescanTimer.restart();
    }

    function rescanBluetooth() {
        if (!bluetoothAdapter || !bluetoothAdapter.enabled)
            return;

        bluetoothAdapter.discovering = false;

        rescanTarget = "bluetooth";
        rescanTimer.restart();
    }

    onWifiDeviceChanged: updateScan()
    onBluetoothAdapterChanged: updateScan()
    onConnectedWifiChanged: Qt.callLater(updateWifiGeneration)

    // ------------------------------------------------------------
    // Wi-Fi
    // ------------------------------------------------------------

    function toggleWifi() {
        if (!networkingAvailable) {
            notify("Wi-Fi unavailable", "NetworkManager is not available.");
            return;
        }

        if (!Networking.wifiHardwareEnabled) {
            notify("Wi-Fi unavailable", "Wi-Fi is hardware blocked.");
            return;
        }

        Networking.wifiEnabled = !Networking.wifiEnabled;
        Qt.callLater(updateScan);
    }

    function wifiNeedsPassword(network) {
        if (!network || network.known)
            return false;

        return network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae;
    }

    function wifiUsesPsk(network) {
        return network && (network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae);
    }

    function connectWifi(network, password) {
        if (!network || network.connected || network.stateChanging)
            return;

        if (password)
            network.connectWithPsk(password);
        else
            network.connect();
    }

    function disconnectWifi(network) {
        if (network && network.connected)
            network.disconnect();
    }

    function forgetWifi(network) {
        if (network && network.known)
            network.forget();
    }

    function wifiSignalIcon(strength) {
        if (strength >= 0.75)
            return "network-wireless-signal-excellent-symbolic";

        if (strength >= 0.50)
            return "network-wireless-signal-good-symbolic";

        if (strength >= 0.25)
            return "network-wireless-signal-ok-symbolic";

        return "network-wireless-signal-weak-symbolic";
    }

    function wifiSecurityLabel(network) {
        return network ? WifiSecurityType.toString(network.security) : "";
    }

    // ------------------------------------------------------------
    // Wi-Fi generation
    //
    // EHT = Wi-Fi 7
    // HE  = Wi-Fi 6
    // VHT = Wi-Fi 5
    // HT  = Wi-Fi 4
    // ------------------------------------------------------------

    Process {
        id: wifiGenerationProbe

        stdout: StdioCollector {
            id: iwOutput
        }

        onExited: function (exitCode) {
            if (exitCode !== 0) {
                root.wifiGeneration = "";
                return;
            }

            const text = iwOutput.text;

            if (/\bEHT[- ]/i.test(text))
                root.wifiGeneration = "7";
            else if (/\bHE[- ]/i.test(text))
                root.wifiGeneration = "6";
            else if (/\bVHT[- ]/i.test(text))
                root.wifiGeneration = "5";
            else if (/\bHT[- ]/i.test(text))
                root.wifiGeneration = "4";
            else
                root.wifiGeneration = "";
        }
    }

    function updateWifiGeneration() {
        wifiGeneration = "";

        if (!wifiDevice || !connectedWifi)
            return;

        /*
         * NetworkDevice.name is the control-interface name,
         * e.g. wlp2s0.
         */
        wifiGenerationProbe.exec(["sh", "-c", "command -v iw >/dev/null 2>&1 || exit 127; exec iw dev \"$1\" link", "sh", wifiDevice.name]);
    }

    // ------------------------------------------------------------
    // Bluetooth
    // ------------------------------------------------------------

    function toggleBluetooth() {
        const adapter = bluetoothAdapter;

        if (!adapter) {
            notify("Bluetooth unavailable", "No Bluetooth adapter is available.");
            return;
        }

        if (adapter.enabled) {
            adapter.enabled = false;
            return;
        }

        if (adapter.state === BluetoothAdapterState.Blocked) {
            rfkillProcess.exec(["rfkill", "unblock", "bluetooth"]);

            return;
        }

        adapter.enabled = true;
    }

    function connectBluetooth(device) {
        if (!device || device.connected || device.pairing)
            return;

        if (device.paired)
            device.connect();
        else
            device.pair();
    }

    function disconnectBluetooth(device) {
        if (device && device.connected)
            device.disconnect();
    }

    function forgetBluetooth(device) {
        if (device && device.paired)
            device.forget();
    }

    Process {
        id: rfkillProcess

        onExited: function (code) {
            if (code !== 0) {
                root.notify("Bluetooth blocked", "Could not unblock Bluetooth with rfkill.");
                return;
            }

            rfkillDelay.restart();
        }
    }

    Timer {
        id: rfkillDelay

        interval: 250

        onTriggered: {
            if (!root.bluetoothAdapter)
                return;

            if (root.bluetoothAdapter.state === BluetoothAdapterState.Blocked) {
                root.notify("Bluetooth blocked", "Bluetooth is still blocked by rfkill.");
                return;
            }

            root.bluetoothAdapter.enabled = true;
            root.updateScan();
        }
    }

    // ------------------------------------------------------------
    // Settings applications
    // ------------------------------------------------------------

    Process {
        id: settingsProbe

        onExited: function (exitCode) {
            const kind = root.settingsKind;
            root.settingsKind = "";

            if (exitCode !== 0) {
                root.notify(kind === "wifi" ? "Network settings unavailable" : "Bluetooth settings unavailable", kind === "wifi" ? "nm-connection-editor is not installed." : "blueman-manager is not installed.");

                return;
            }

            if (kind === "wifi") {
                Quickshell.execDetached(["nm-connection-editor"]);
            } else {
                /*
                 * User requested killing blueman-applet before
                 * opening the manager.
                 */
                Quickshell.execDetached(["sh", "-c", "pkill blueman-applet 2>/dev/null || true; exec blueman-manager"]);
            }
        }
    }

    function openWifiSettings() {
        if (settingsProbe.running)
            return;

        settingsKind = "wifi";

        settingsProbe.exec(["sh", "-c", "command -v nm-connection-editor >/dev/null 2>&1"]);
    }

    function openBluetoothSettings() {
        if (settingsProbe.running)
            return;

        settingsKind = "bluetooth";

        settingsProbe.exec(["sh", "-c", "command -v blueman-manager >/dev/null 2>&1"]);
    }

    // ------------------------------------------------------------

    function notify(title, body) {
        if (notifications && typeof notifications.showLocal === "function") {
            notifications.showLocal(title, body, "network-wireless-symbolic");
        }
    }
}
