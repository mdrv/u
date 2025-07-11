import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {

	Variants {
		// Create the panel once on each monitor.
		model: Quickshell.screens

		PanelWindow {
			id: toplevel

			property var modelData
			screen: modelData

			anchors {
				// right: true
				bottom: true
			}

			margins {
				// right: 20
				bottom: 20
			}

			color: "transparent"
			PopupWindow {
				id: popup
				anchor.window: toplevel
				// anchor.rect.x: parentWindow.width / 2 - width / 2
				// anchor.rect.y: parentWindow.height
				implicitWidth: 40
				implicitHeight: 40
				visible: true

				color: "transparent"

				Rectangle {
					anchors.fill: parent
					radius: 20
					color: "#aa000000"
					opacity: 0.8
					Text {
						id: workspace

						Process {
							command: ["nu", "-c", "hyprctl activeworkspace -j | from json | get id"]
							running: true

							stdout: StdioCollector {
								onStreamFinished: workspace.text = this.text
							}
						}

						Timer {
							id: timer
							interval: 250
							running: false
							onTriggered: popup.visible = false
						}

						Socket {
							// Create and connect a Socket to the hyprland event socket.
							// https://wiki.hyprland.org/IPC/
							path: `${Quickshell.env("XDG_RUNTIME_DIR")}/hypr/${Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")}/.socket2.sock`
							connected: true

							parser: SplitParser {
								// Regex that will return the newly focused monitor when it changes.
								property var regex: new RegExp("^workspace>>(.+)");

								// Sent for every line read from the socket
								onRead: msg => {
									const match = regex.exec(msg);

									if (match != null) {
										// Filter out the right screen from the list and update the panel.
										// match[1] will always be the monitor name captured by the regex.
										// panel.screen = Quickshell.screens.filter(screen => screen.name == match[1])[0];
										popup.visible = true
										workspace.text = match[1]
										timer.running = true
									}
								}
							}
						}
						anchors.centerIn: parent
						color: "#aaffffff"
						font.pointSize: 18
						font.weight: 700
					}
				}
			}

			implicitWidth: popup.width
			implicitHeight: popup.height

			// Give the window an empty click mask so all clicks pass through it.
			mask: Region {}

			// Use the wlroots specific layer property to ensure it displays over
			// fullscreen windows.
			WlrLayershell.layer: WlrLayer.Overlay

		}
	}
}

