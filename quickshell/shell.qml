import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland // for workspace/submap tracking
import Quickshell.Io
import Quickshell.Widgets
import qs.u
import qs.u.components

ShellRoot {
	readonly property bool debugMode: Quickshell.env("DEBUG") === "1"
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
	readonly property var help: {
		try {
			return jsonFile.text() ? JSON.parse(jsonFile.text()) : {}
		} catch (e) {
			console.log("JSON parse error:", e)
			return {}
		}
	}

	property string submap_mode: ""
	property string workspace_num
	property bool is_workspace_shown
	property bool is_submap_shown: false
	property bool is_squeekboard_visible: false

	// AI: 2025-02-02 - Log when squeekboard state changes
	onIs_squeekboard_visibleChanged: {
		if (debugMode) console.log(`🔄 is_squeekboard_visible changed to: ${is_squeekboard_visible}`)
	}

	// AI: 2025-02-02 - Logging for debugging squeekboard toggle
	Component.onCompleted: {
		if (debugMode) console.log("🔧 QuickShell loaded. is_squeekboard_visible:", is_squeekboard_visible)
	}

	// Track workspace changes
	Connections {
		target: Hyprland
		function onFocusedWorkspaceChanged() {
			workspace_num = Hyprland.focusedWorkspace?.id?.toString() || ""
			is_workspace_shown = true
			workspace_timer.running = true
			if (debugMode) console.log("Workspace changed to:", Hyprland.focusedWorkspace?.name)
		}
	}

	// Track submap changes via raw event (submap not built-in)
	Connections {
		target: Hyprland
		function onRawEvent(event) {
			if (event.name === "submap") {
				if (event.data.length === 0) {
					is_submap_shown = false
					submap_mode = ""
				} else {
					submap_mode = event.data
					is_submap_shown = true
				}
				if (debugMode) console.log("Submap changed to:", submap_mode)
			}
		}
	}

	Timer {
		id: workspace_timer
		interval: 250
		running: false
		onTriggered: is_workspace_shown = false

		Component.onDestruction: {
			running = false
		}
	}


		}
		stderr: StdioCollector {
			onStreamFinished: {
				if (debugMode) console.log(`❌ Error checking squeekboard.nu: ${this.text}`)
			}
		}
	}

	Process {
		id: squeekboardToggle
		command: ["nu", "-n", `${Quickshell.env("HOME")}/.config/nushell/u/squeekboard.nu`]

		// AI: 2025-02-02 - Logging for debugging
		onRunningChanged: {
			if (debugMode) console.log(`🔄 squeekboardToggle.running changed to: ${this.running}`)
		}

		stdout: StdioCollector {
			onStreamFinished: {
				if (debugMode) console.log(`📤 squeekboardToggle stdout: ${this.text}`)
			}
		}

		stderr: StdioCollector {
			onStreamFinished: {
				if (debugMode) console.log(`❌ squeekboardToggle stderr: ${this.text}`)
			}
		}

		onExited: (exitCode, exitStatus) => {
			if (debugMode) console.log(`🏁 squeekboardToggle exited with code: ${exitCode}, status: ${exitStatus}`)
		}
	}

	// AI: 2025-02-02 - Squeekboard toggle buttons on screen corners
	Variants {
		model: Quickshell.screens

		// Top-right corner toggle button
		PanelWindow {
			id: topright_button

			exclusionMode: ExclusionMode.Ignore

			anchors {
				top: true
				right: true
			}

			margins {
				top: Theme.spacingSmall
				right: Theme.spacingSmall
			}

			implicitWidth: 24
			implicitHeight: 24

			WlrLayershell.layer: WlrLayer.Overlay



			color: "transparent"
			SqueekboardButton {
				anchors.centerIn: parent
				isActive: is_squeekboard_visible
				onClicked: {
					if (debugMode) console.log("🔘 Squeekboard toggle button clicked. Current state:", is_squeekboard_visible)
					is_squeekboard_visible = !is_squeekboard_visible
					squeekboardToggle.running = true
				}
			}
			}
		}
	}

	Variants {
		// Create a panel once on each monitor.
		model: Quickshell.screens

		LazyLoader {
			id: submap_loader
			active: is_submap_shown

			SubmapPanel {
				screen: modelData
				submapMode: submap_mode
				visible: is_submap_shown
				helpText: help.submap[submap_mode] || "No help available for this submap."
			}
		}
	}

	Variants {
		// Create a panel once on each monitor.
		model: Quickshell.screens

		LazyLoader {
			id: workspace_loader
			active: is_workspace_shown

			WorkspaceIndicator {
				screen: modelData
				workspaceNum: workspace_num
				visible: is_workspace_shown
			}
		}

	}
}
