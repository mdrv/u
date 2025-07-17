import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets

Scope {
	Process {
		command: ["nu", "-n", "-c", "hyprctl activeworkspace -j | from json | get id"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: workspace_num = this.text
		}
	}

	Process {
		id: generateHelp
		command: ["nu", "-n", `${Quickshell.env("HOME")}/.config/nushell/u/hypr-utils.nu`, "generatehelp"]
		running: true
	}
	FileView {
		path: `${Quickshell.env("HOME")}/.config/hypr/hyprland.conf`
		watchChanges: true
		onFileChanged: generateHelp.running = true
	}

	FileView {
		id: jsonFile
		path: `${Quickshell.env("HOME")}/.config/hypr/.u.help.json`
		watchChanges: true
		onFileChanged: this.reload()
	}
	readonly property var help: JSON.parse(jsonFile.text())

	property string submap_mode: ""
	property string workspace_num
	property bool is_workspace_shown
	property bool is_submap_shown: false

	Socket {
		// Create and connect a Socket to the hyprland event socket.
		// https://wiki.hyprland.org/IPC/
		path: `${Quickshell.env("XDG_RUNTIME_DIR")}/hypr/${Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")}/.socket2.sock`
		connected: true

		parser: SplitParser {
			// Regex that will return the newly focused monitor when it changes.
			property var regex: new RegExp("^(workspace|submap)>>(.*)");

			// Sent for every line read from the socket
			onRead: msg => {
				const match = regex.exec(msg);

				if (match == null) {
				} else if (match[1] == "workspace") {
					// Filter out the right screen from the list and update the panel.
					// match[1] will always be the monitor name captured by the regex.
					// panel.screen = Quickshell.screens.filter(screen => screen.name == match[1])[0];
					workspace_num = match[2]
					is_workspace_shown = true
					workspace_timer.running = true
				} else if (match[1] == "submap") {
					if (match[2].length == 0) {
						is_submap_shown = false
						submap_mode = ""
					} else {
						submap_mode = match[2]
						is_submap_shown = true
					}
				}

			}
		}
	}

	Timer {
		id: workspace_timer
		interval: 250
		running: false
		onTriggered: is_workspace_shown = false
	}

	Variants {
		// Create the panel once on each monitor.
		model: Quickshell.screens

		LazyLoader {
			id: submap_loader
			active: is_submap_shown
			property var modelData

			PanelWindow {
				id: toplevel

				screen: modelData
                exclusionMode: ExclusionMode.Ignore

				anchors {
					top: true
				}
				margins {
					top: 40
				}

				implicitWidth: screen.width
				implicitHeight: screen.height

				// Give the window an empty click mask so all clicks pass through it.
				mask: Region {}

				// Use the wlroots specific layer property to ensure it displays over
				// fullscreen windows.
				WlrLayershell.layer: WlrLayer.Overlay

				color: "transparent"
				PopupWindow {
					id: popup
					anchor.window: toplevel
					anchor.rect.x: parentWindow.width / 2 - width / 2
					anchor.rect.y: parentWindow.height
					implicitWidth: Math.max(textitem.implicitWidth, 1)
					implicitHeight: Math.max(textitem.implicitHeight, 1)
					mask: Region {}

					color: "#aa000000"
					visible: is_submap_shown

					Text {
						id: textitem
						text: help.submap?.[submap_mode] ?? ""
						padding: 20
						textFormat: Text.MarkdownText
						anchors.fill: parent
						horizontalAlignment: Text.AlignHCenter

						color: "#ffffff"
						font.pointSize: 12
						font.weight: 500
						renderType: Text.CurveRendering
					}
				}
			}
		}
	}

	Variants {
		// Create the panel once on each monitor.
		model: Quickshell.screens

		LazyLoader {
			id: workspace_loader
			active: is_workspace_shown

			PanelWindow {
				id: toplevel

				property var modelData
				screen: modelData
                exclusionMode: ExclusionMode.Ignore

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

					color: "transparent"
					visible: is_workspace_shown

					Rectangle {
						anchors.fill: parent
						radius: 20
						color: "#aa000000"
						opacity: 0.8
						Text {
							text: workspace_num

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
}

