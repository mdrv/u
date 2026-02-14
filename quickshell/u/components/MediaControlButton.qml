import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.u // For Theme
Rectangle {
	id: root
	property bool isActive: false
	signal clicked
	implicitWidth: 32
	implicitHeight: 32
	radius: Theme.cornerMedium
	color: Theme.buttonBackground
	opacity: 0.2
	Text {
		text: "⚙️"
		anchors.centerIn: parent
		font.pointSize: 10
		color: Theme.buttonText
	}
	MouseArea {
		anchors.fill: parent
		onClicked: root.clicked()
	}
}
