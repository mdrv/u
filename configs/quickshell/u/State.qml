pragma Singleton

import QtQuick
import Quickshell

Singleton {
	id: root

	// Workspace state
	readonly property int workspaceId: 1
	readonly property bool workspaceVisible: false

	// Submap state
	readonly property string submapMode: ""
	readonly property bool submapVisible: false

	// UI state
	readonly property bool squeekboardVisible: false

	// Methods to update state
	function setWorkspace(id, visible) {
		workspaceId = id
		workspaceVisible = visible
	}

	function setSubmap(mode, visible) {
		submapMode = mode
		submapVisible = visible
	}

	function toggleSqueekboard() {
		squeekboardVisible = !squeekboardVisible
	}
}
