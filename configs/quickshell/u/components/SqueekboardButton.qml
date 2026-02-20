import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.u // For Theme
Rectangle {
	id: root
	property string icon: "⌨️"
	property int padding: 8
	property bool isActive: false
	signal clicked
	implicitWidth: 32
	implicitHeight: 32
	radius: 30
	color: Theme.buttonBackground
	opacity: 0.2
	Text {
		text: root.icon
		anchors.centerIn: parent
		font.pointSize: 10
		color: Theme.buttonText
	}
	MouseArea {
		anchors.fill: parent
		onClicked: root.clicked()
	}
}
