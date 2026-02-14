import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.u // For Theme
Rectangle {
	id: root
	property bool isActive: false
	signal clicked
	implicitWidth: 24
	implicitHeight: 24
	radius: Theme.cornerMedium
	color: Theme.buttonBackground
	opacity: 0.2
	Text {
		text: "🔈"
		anchors.centerIn: parent
		font.pointSize: 10
		color: Theme.buttonText
	}
	MouseArea {
		anchors.fill: parent
		onClicked: root.clicked()
	}
}
