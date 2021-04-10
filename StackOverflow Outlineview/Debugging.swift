//------------------------------
func trace(
    _ message: @autoclosure () -> String = "",
    function: StaticString = #function,
    line: UInt = #line)
{
    #if DEBUG
    print("\(function):\(line): \(message())")
    #endif
}
