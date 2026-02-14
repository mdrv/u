pragma Singleton

import QtQuick
import Quickshell

Singleton {
	id: root

	// Workspace state
	readonly property var workspace: {
		id: 1,
		visible: false
	}

	// Submap state
	readonly property var submap: {
		mode: "",
		visible: false
	}

	// UI state
	readonly property var ui: {
		squeekboardVisible: false
	}

	// Methods to update state
	function setWorkspace(id, visible) {
		workspace.id = id
		workspace.visible = visible
	}

	function setSubmap(mode, visible) {
		submap.mode = mode
		submap.visible = visible
	}

	function toggleSqueekboard() {
		ui.squeekboardVisible = !ui.squeekboardVisible
	}
}
