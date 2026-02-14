import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.u // For Theme
Rectangle {
	id: root
	property string icon: "⌨️"
	property int padding: 12
	property bool isActive: false
	signal clicked
	implicitWidth: 24
	implicitHeight: 24
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
