pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property color overlayBackground: "#aa000000"
	readonly property color overlayText: "#aaffffff"
	readonly property color buttonBackground: "#88000000"
	readonly property color buttonText: "#ffffff"

	readonly property int spacingSmall: 12
	readonly property int spacingMedium: 20
	readonly property int spacingLarge: 40

	readonly property int cornerSmall: 20
	readonly property int cornerMedium: 30
}
