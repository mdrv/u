import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.u

PanelWindow {
    id: root
    visible: false

    anchors {
        top: true
        left: true
    }

    margins {
        top: Theme.spacingSmall
    }

    implicitWidth: screen.width
    implicitHeight: screen.height

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay

    PopupWindow {
        id: popup
        visible: root.visible
        anchor.window: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height

        implicitWidth: 250
        implicitHeight: 150
        mask: Region {}
        color: Theme.overlayBackground

        Column {
            spacing: Theme.spacingSmall
            anchors.fill: parent
            anchors.margins: Theme.spacingSmall

            Row {
                spacing: Theme.spacingSmall
                width: parent.width

                Item { width: 0 }

                Column {
                    spacing: Theme.spacingSmall

                    Text {
                        text: "Brightness & Volume"
                        color: Theme.overlayText
                        font.bold: true
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item { width: 0 }

                    Button {
                        text: "X"
                        onClicked: root.visible = false
                        background: Rectangle {
                            color: Theme.buttonBackground
                            radius: Theme.radiusSmall
                        }
                    }
                }
            }

            Column {
                spacing: Theme.spacingSmall

                Text {
                    text: "Brightness:"
                    color: Theme.overlayText
                    font.pointSize: 12
                }

                Slider {
                    id: brightnessSlider
                    from: 0
                    to: 100
                    value: 50
                    stepSize: 5
                }
            }

            Column {
                spacing: Theme.spacingSmall

                Text {
                    text: "Volume:"
                    color: Theme.overlayText
                    font.pointSize: 12
                }

                Slider {
                    id: volumeSlider
                    from: 0
                    to: 100
                    value: 50
                    stepSize: 5
                }
            }
        }
    }

    Process {
        id: brightnessProcess
        command: ["brightnessctl", "-e4", "-n2", "set", "50%"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: console.log("Brightness command output:", this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: console.log("Brightness command error:", this.text)
        }
    }

    Process {
        id: volumeProcess
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "50%"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: console.log("Volume command output:", this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: console.log("Volume command error:", this.text)
        }
    }
}
