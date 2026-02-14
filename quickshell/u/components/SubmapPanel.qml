import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.u

PanelWindow {
  id: root
  property string submapMode: ""
  property bool visible: false
  property var helpText: ""
  
  exclusionMode: ExclusionMode.Ignore
  
  anchors {
    top: true
  }
  
  margins {
    top: Theme.spacingLarge
  }
  
  implicitWidth: screen.width
  implicitHeight: screen.height
  
  mask: Region {}
  WlrLayershell.layer: WlrLayer.Overlay
  
  color: "transparent"
  
  PopupWindow {
    id: popup
    anchor.window: root
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.rect.x: root.width / 2 - width / 2
    anchor.rect.y: root.height
    
    implicitWidth: Math.max(textitem.implicitWidth, 1)
    implicitHeight: Math.max(textitem.implicitHeight, 1)
    
    mask: Region {}
    color: Theme.overlayBackground
    visible: root.visible
    
    Text {
      id: textitem
      text: helpText
      padding: Theme.spacingSmall
      textFormat: Text.MarkdownText
      anchors.fill: parent
      horizontalAlignment: Text.AlignHCenter
      color: Theme.overlayText
      font.pointSize: 12
      font.weight: 500
      renderType: Text.CurveRendering
    }
  }
}
