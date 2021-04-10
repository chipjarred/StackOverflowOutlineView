import AppKit

//------------------------------
class OVDelegate: NSObject, NSOutlineViewDelegate
{
    //------------------------------
    func enableDragAndDrop(for outlineView: NSOutlineView) {
        outlineView.registerForDraggedTypes([.string])
    }
    
    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        viewFor tableColumn: NSTableColumn?,
        item: Any) -> NSView?
    {
        trace()
        if let item = item as? Item  {
            return NSTextField(labelWithString: item.description)
        }
        return nil
    }
    
}
