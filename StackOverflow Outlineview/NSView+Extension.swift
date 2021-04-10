import AppKit

//------------------------------
extension NSView
{
    //------------------------------
    func firstSubview(where condition: (NSView) -> Bool) -> NSView?
    {
        if let found = subviews.first(where: condition) { return found }
        
        for view in subviews
        {
            if let found = view.firstSubview(where: condition) {
                return found
            }
        }
        
        return nil
    }
}
