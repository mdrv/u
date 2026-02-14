import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.u

PanelWindow {
    id: root
    visible: false

    readonly property bool debugMode: Quickshell.env("DEBUG") === "1"
    property bool isInitializing: true  // Start as initializing to prevent early triggers
    property bool isReady: false
    property bool brightnessFetched: false
    property bool volumeFetched: false
    property bool fetchInProgress: false  // Prevent duplicate fetches
    property var modelData: null

    anchors {
        top: true
        left: true
    }

    margins {
        top: Theme.spacingLarge
    }

    implicitWidth: screen.width
    implicitHeight: screen.height

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay

    PopupWindow {
        id: popup
        visible: root.visible && root.isReady
        anchor.window: root
        anchor.rect.x: 0
        anchor.rect.y: 0
        anchor.rect.width: 24
        anchor.rect.height: 24

        implicitWidth: 32
        implicitHeight: 420
        color: "transparent"

        Column {
            spacing: Theme.spacingSmall
            anchors.fill: parent
            anchors.topMargin: Theme.spacingSmall
            anchors.bottomMargin: Theme.spacingSmall

            Text {
                text: "CONTROLS"
                color: Theme.overlayText
                font.bold: true
                font.pointSize: 7
                anchors.horizontalCenter: parent.horizontalCenter
                visible: parent.width >= 40
            }

            Column {
                width: parent.width
                spacing: 4
                
                Text {
                    text: "☀️"
                    color: Theme.overlayText
                    font.pointSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Slider {
                    id: brightnessSlider
                    width: parent.width
                    implicitHeight: 90
                    orientation: Qt.Vertical
                    from: 0
                    to: 100
                    value: 50
                    stepSize: 5

                    onValueChanged: {
                        if (root.isInitializing) return

                        var sliderRatio = value / 100
                        var transformedPercentage = Math.pow(sliderRatio, 1/4) * 100
                        var rounded = Math.round(transformedPercentage)

                        brightnessProcess.command = ["brightnessctl", "-e4", "-n2", "set", rounded + "%"]
                        brightnessProcess.running = false
                        brightnessProcess.running = true
                    }

                    background: Rectangle {
                        implicitWidth: 48
                        implicitHeight: 90
                        color: "#22ffffff"
                        radius: 4
                        
                        Rectangle {
                            width: parent.width
                            height: (1 - brightnessSlider.visualPosition) * parent.height
                            color: Theme.overlayText
                            opacity: 0.5
                            radius: 4
                            anchors.bottom: parent.bottom
                        }
                    }

                    handle: Rectangle {
                        y: brightnessSlider.visualPosition * (brightnessSlider.availableHeight - height)
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: 48
                        implicitHeight: 6
                        color: Theme.overlayText
                        radius: 2
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 4
                
                Text {
                    text: "🔊"
                    color: Theme.overlayText
                    font.pointSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Slider {
                    id: volumeSlider
                    width: parent.width
                    implicitHeight: 90
                    orientation: Qt.Vertical
                    from: 0
                    to: 100
                    value: 50
                    stepSize: 5

                    onValueChanged: {
                        if (root.isInitializing) return

                        volumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(value) + "%"]
                        volumeProcess.running = false
                        volumeProcess.running = true
                    }

                    background: Rectangle {
                        implicitWidth: 48
                        implicitHeight: 90
                        color: "#22ffffff"
                        radius: 4
                        
                        Rectangle {
                            width: parent.width
                            height: (1 - volumeSlider.visualPosition) * parent.height
                            color: Theme.overlayText
                            opacity: 0.5
                            radius: 4
                            anchors.bottom: parent.bottom
                        }
                    }

                    handle: Rectangle {
                        y: volumeSlider.visualPosition * (volumeSlider.availableHeight - height)
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: 48
                        implicitHeight: 6
                        color: Theme.overlayText
                        radius: 2
                    }
                }
            }

            OrientationControl {
                id: orientationControl
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Process {
        id: brightnessProcess
        command: ["brightnessctl", "-e4", "-n2", "set", "50%"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: if (debugMode) console.log("Brightness command output:", this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: if (debugMode) console.log("Brightness command error:", this.text)
        }
    }

    property int maxBrightness: 2047

    Process {
        id: getMaxBrightnessProcess
        command: ["brightnessctl", "max"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                maxBrightness = parseInt(this.text)
            }
        }
    }

    Process {
        id: getBrightnessProcess
        command: ["brightnessctl", "-m", "get"]
        running: false

        onRunningChanged: {
            if (debugMode) console.log("getBrightnessProcess.running:", this.running)
        }

        onExited: (exitCode, exitStatus) => {
            if (debugMode) console.log("getBrightnessProcess exited:", exitCode, exitStatus)
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (debugMode) console.log("Brightness output:", this.text)
                var currentValue = parseInt(this.text)
                var percentage = Math.round((currentValue / maxBrightness) * 100)
                brightnessSlider.value = percentage
                root.brightnessFetched = true
                root.checkReady()
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text && this.text.trim().length > 0) {
                    if (debugMode) console.log("Failed to fetch brightness:", this.text)
                }
                root.brightnessFetched = true
                root.checkReady()
            }
        }
    }

    Process {
        id: volumeProcess
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "50%"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: if (debugMode) console.log("Volume command output:", this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: if (debugMode) console.log("Volume command error:", this.text)
        }
    }

    Process {
        id: getVolumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        onRunningChanged: {
            if (debugMode) console.log("getVolumeProcess.running:", this.running)
        }

        onExited: (exitCode, exitStatus) => {
            if (debugMode) console.log("getVolumeProcess exited:", exitCode, exitStatus)
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (debugMode) console.log("Volume output:", this.text)
                var output = this.text
                // Output format: "Volume: 0.35" - extract the decimal value
                var match = output.match(/Volume:\s+(\d+\.\d+)/)
                if (match) {
                    var volumeDecimal = parseFloat(match[1])
                    volumeSlider.value = Math.round(volumeDecimal * 100)
                }
                root.volumeFetched = true
                root.checkReady()
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text && this.text.trim().length > 0) {
                    if (debugMode) console.log("Failed to fetch volume:", this.text)
                }
                root.volumeFetched = true
                root.checkReady()
            }
        }
    }

    function checkReady() {
        if (brightnessFetched && volumeFetched) {
            if (debugMode) console.log("Both fetches complete, panel ready")
            root.fetchInProgress = false
            root.isInitializing = false
            root.isReady = true
        }
    }

    Timer {
        id: fetchTimeout
        interval: 2000
        running: false
        onTriggered: {
            if (debugMode) console.log("Fetch timeout - showing panel anyway")
            root.fetchInProgress = false
            root.isReady = true
            root.isInitializing = false
        }
    }

    Component.onCompleted: {
        getMaxBrightnessProcess.running = false
        getMaxBrightnessProcess.running = true
    }

    onVisibleChanged: {
        if (visible) {
            if (root.fetchInProgress) {
                if (debugMode) console.log("Fetch already in progress, skipping")
                return
            }

            if (debugMode) console.log("Panel opening, starting fetch...")
            root.fetchInProgress = true
            root.isInitializing = true
            root.isReady = false
            root.brightnessFetched = false
            root.volumeFetched = false
            fetchTimeout.running = true

            getBrightnessProcess.running = false
            getBrightnessProcess.running = true
            getVolumeProcess.running = false
            getVolumeProcess.running = true
            
            orientationControl.refresh()
        } else {
            if (debugMode) console.log("Panel closing")
            root.fetchInProgress = false
            root.isInitializing = true  // Reset for next open
            fetchTimeout.running = false
        }
    }
}
