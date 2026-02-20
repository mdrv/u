import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.u

/**
 * Orientation control component for Hyprland.
 * Manages display and input rotation (monitor, touchscreen, pen).
 */
Column {
    id: root
    width: 32
    spacing: 4

    readonly property bool debugMode: Quickshell.env("DEBUG") === "1"
    property int orientation: 0
    property string configFile: Quickshell.env("HOME") + "/.config/hypr/hyprland.conf"

    // CCW Button
    Rectangle {
        width: parent.width
        height: 32
        color: ccwMouse.pressed ? "#22ffffff" : "transparent"
        radius: 4

        Text {
            text: "↪️"
            color: Theme.overlayText
            font.pointSize: 18
            anchors.centerIn: parent
        }

        MouseArea {
            id: ccwMouse
            anchors.fill: parent
            onClicked: rotateCCW()
        }
    }

    // Current State Indicator
    Rectangle {
		visible: false
        width: parent.width
        height: 32
        color: "#11ffffff"
        radius: 4

        Text {
            text: getOrientationIcon(root.orientation)
            color: Theme.overlayText
            font.pointSize: 14
            anchors.centerIn: parent
        }
    }

    // CW Button
    Rectangle {
        width: parent.width
        height: 32
        color: cwMouse.pressed ? "#22ffffff" : "transparent"
        radius: 4

        Text {
            text: "↩️"
            color: Theme.overlayText
            font.pointSize: 18
            anchors.centerIn: parent
        }

        MouseArea {
            id: cwMouse
            anchors.fill: parent
            onClicked: rotateCW()
        }
    }

    function getOrientationIcon(o) {
        switch(o) {
            case 0: return "↕";
            case 1: return "⇨";
            case 2: return "🔃";
            case 3: return "⇦";
            default: return "↕";
        }
    }

    function rotateCW() {
        var next = (root.orientation + 3) % 4;
        applyOrientation(next);
    }

    function rotateCCW() {
        var next = (root.orientation + 1) % 4;
        applyOrientation(next);
    }

    function applyOrientation(val) {
        if (debugMode) console.log("Applying orientation:", val);
        root.orientation = val;

        // 1. Update Monitor
        applyMonitorProcess.command = ["hyprctl", "keyword", "monitor", "DSI-1, preferred, auto, 1.5, transform, " + val];
        applyMonitorProcess.running = true;

        // 2. Update Input Devices (Touch/Pen)
        applyTouchProcess.command = ["hyprctl", "keyword", "device:nvtcapacitivetouchscreen:transform", val.toString()];
        applyTouchProcess.running = true;

        applyPenProcess.command = ["hyprctl", "keyword", "device:nvtcapacitivepen:transform", val.toString()];
        applyPenProcess.running = true;

        // 3. Persist to hyprland.conf
        persistProcess.command = ["sed", "-i", "s/^\\$orientation = .*/$orientation = " + val + "/", root.configFile];
        persistProcess.running = true;
    }

    // Processes for execution
    Process { id: applyMonitorProcess; running: false }
    Process { id: applyTouchProcess; running: false }
    Process { id: applyPenProcess; running: false }
    Process { id: persistProcess; running: false }

    Process {
        id: readProcess
        command: ["grep", "\\$orientation", root.configFile]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (debugMode) console.log("Orientation config output:", this.text);
                var match = this.text.match(/\$orientation = (\d+)/);
                if (match) {
                    if (debugMode) console.log("Parsed orientation:", match[1]);
                    root.orientation = parseInt(match[1]);
                } else {
                    if (debugMode) console.log("No orientation match found, using default 0");
                    root.orientation = 0;
                }
            }
        }
    }

    // Refresh orientation when component is ready or when panel opens
    function refresh() {
        readProcess.running = false;
        readProcess.running = true;
    }

    Component.onCompleted: refresh()
}
