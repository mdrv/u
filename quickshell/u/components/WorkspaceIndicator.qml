import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.u
PanelWindow {
  id: root
  property string workspaceNum: ""
  property bool visible: false
  
  exclusionMode: ExclusionMode.Ignore
  
  anchors {
    bottom: true
  }
  
  margins {
    bottom: Theme.spacingMedium
  }
  
  color: "transparent"
  
  PopupWindow {
    id: popup
    anchor.window: root
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.rect.x: root.width / 2 - width / 2
    anchor.rect.y: root.height
    
    implicitWidth: 40
    implicitHeight: 40
    
    color: "transparent"
    visible: root.visible
    
    Rectangle {
      anchors.fill: parent
      radius: Theme.cornerSmall
      color: Theme.overlayBackground
      opacity: 0.8
      
      Text {
        text: root.workspaceNum
        anchors.centerIn: parent
        color: Theme.overlayText
        font.pointSize: 18
        font.weight: 700
      }
    }
  }
  
  implicitWidth: popup.width
  implicitHeight: popup.height
  
  mask: Region {}
  WlrLayershell.layer: WlrLayer.Overlay
}
