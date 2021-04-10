import AppKit

//------------------------------
class Item: CustomStringConvertible
{
    var description: String { title }
    var title: String
    var children: [Item] = []
    
    //------------------------------
    init(_ title: String) { self.title = title }
    convenience init(_ id: Int) { self.init("Item \(id)") }
    
    //------------------------------
    func addChild() {
        children.append(Item("\(title).\(children.count + 1)"))
    }
    
    //------------------------------
    func parentAndChildIndex(forChildTitled title: String) -> (Item?, Int)?
    {
        for i in children.indices
        {
            let child = children[i]
            if child.title == title { return (self, i) }
            if let found = child.parentAndChildIndex(forChildTitled: title){
                return found
            }
        }
        return nil
    }
}


//------------------------------
@objc class OVDataSource: NSObject, NSOutlineViewDataSource
{
    //------------------------------
    // Just creating some items programmatically for testing
    var items: [Item] =
    {
        trace()
        let items = (1...4).map { Item($0) }
        items[2].addChild()
        items[2].addChild()
        return items
    }()
    
    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        pasteboardWriterForItem item: Any) -> NSPasteboardWriting?
    {
        trace()
        guard let item = item as? Item else { return nil }
        return item.title as NSString
    }
    
    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        numberOfChildrenOfItem item: Any?) -> Int
    {
        trace()
        if let item = item {
            return (item as? Item)?.children.count ?? 0
        }
        return items.count
    }
    
    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        child index: Int,
        ofItem item: Any?) -> Any
    {
        trace()
        if let item = item as? Item {
            return item.children[index]
        }
        return items[index]
    }
    
    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        isItemExpandable item: Any) -> Bool
    {
        trace()
        if let item = item as? Item {
            return item.children.count > 0
        }
        return false
    }

    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        validateDrop info: NSDraggingInfo,
        proposedItem item: Any?,
        proposedChildIndex index: Int) -> NSDragOperation
    {
        trace("item = \(String(describing: item)), index = \(index)")
        guard info.draggingSource as? NSOutlineView === outlineView else {
            return []
        }
        
        outlineView.draggingDestinationFeedbackStyle = .gap

        if item == nil, index < 0 {
            return []
        }
        return .move
    }
    
    //------------------------------
    func outlineView(
        _ outlineView: NSOutlineView,
        acceptDrop info: NSDraggingInfo,
        item: Any?,
        childIndex index: Int) -> Bool
    {
        assert(item == nil || item is Item)
        
        trace("item = \(String(describing: item)), index = \(index)")
        guard let sourceTitle = info.draggingPasteboard.string(forType: .string),
              let source = parentAndChildIndex(forItemTitled: sourceTitle)
        else { return false }
        
        let debuggedIndex = translateIndexForGapBug(
            outlineView,
            item: item,
            index: index,
            for: info
        )
        moveItem(from: source, to: (item as? Item, debuggedIndex))
        outlineView.reloadData()

        return true
    }
    
    //------------------------------
    func translateIndexForGapBug(
        _ outlineView: NSOutlineView,
        item: Any?,
        index: Int,
        for info: NSDraggingInfo) -> Int
    {
        guard outlineView.draggingDestinationFeedbackStyle == .gap,
              items.count > 0,
              item == nil,
              index == 0
        else { return index }
        
        let point = outlineView.convert(info.draggingLocation, from: nil)
        let firstCellFrame = outlineView.frameOfCell(atColumn: 0, row: 0)
        return outlineView.isFlipped
            ? (point.y < firstCellFrame.maxY ? index : items.count)
            : (point.y >= firstCellFrame.minY ? index : items.count)
    }
    
    //------------------------------
    func parentAndChildIndex(forItemTitled title: String) -> (parent: Item?, index: Int)?
    {
        trace("Finding parent and child for item: \"\(title)\"")
        for i in items.indices
        {
            let item = items[i]
            if item.title == title { return (nil, i) }
            if let found = item.parentAndChildIndex(forChildTitled: title) {
                return found
            }
        }
        
        return nil
    }
    
    //------------------------------
    func moveItem(
        from src: (parent: Item?, index: Int),
        to dst: (parent: Item?, index: Int))
    {
        trace("src = \(src), dst = \(dst)")
        
        let item: Item = src.parent?.children[src.index]
            ?? items[src.index]
        
        if src.parent === dst.parent  // Moving item in same level?
        {
            if let commonParent = src.parent
            {
                moveItem(
                    item,
                    from: src.index,
                    to: dst.index,
                    in: &commonParent.children
                )
                return
            }
            
            moveItem(item, from: src.index, to: dst.index, in: &items)
            return
        }
        
        // Moving between levels
        if let srcParent = src.parent {
            srcParent.children.remove(at: src.index)
        }
        else { items.remove(at: src.index) }
        
        if let dstParent = dst.parent {
            insertItem(item, into: &dstParent.children, at: dst.index)
        }
        else { insertItem(item, into: &items, at: dst.index) }
    }
    
    //------------------------------
    // Move an item within the same level
    func moveItem(
        _ item: Item,
        from srcIndex: Int,
        to dstIndex: Int,
        in items: inout [Item])
    {
        if srcIndex < dstIndex
        {
            insertItem(item, into: &items, at: dstIndex)
            items.remove(at: srcIndex)
            return
        }
        
        items.remove(at: srcIndex)
        insertItem(item, into: &items, at: dstIndex)
    }
            
    func insertItem(_ item: Item, into items: inout [Item], at index: Int)
    {
        if index < 0
        {
            items.append(item)
            return
        }
        items.insert(item, at: index)
    }
}
