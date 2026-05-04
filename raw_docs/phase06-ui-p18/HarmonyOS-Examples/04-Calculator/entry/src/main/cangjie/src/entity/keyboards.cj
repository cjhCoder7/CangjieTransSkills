/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.entity

public class Keyboards {

    public static let LeftBracketStr = "("
    public static let RightBracketStr = ")"
    public static let DotStr = "."

    public static let PlusStr = "+"
    public static let ReduceStr = "-"
    public static let MultiplyStr = "x"
    public static let DivideStr = "÷"

    public static let CalculatingStr = "="
    public static let PopStr = "←"
    public static let ClearStr = "AC"

    public static let Zero = NumberButtonEntity("0")
    public static let One = NumberButtonEntity("1")
    public static let Two = NumberButtonEntity("2")
    public static let Three = NumberButtonEntity("3")
    public static let Four = NumberButtonEntity("4")
    public static let Five = NumberButtonEntity("5")
    public static let Six = NumberButtonEntity("6")
    public static let Seven = NumberButtonEntity("7")
    public static let Eight = NumberButtonEntity("8")
    public static let Nine = NumberButtonEntity("9")

    public static let Dot = OperationButtonEntity(DotStr)

    public static let Plus = OperationButtonEntity(PlusStr)
    public static let Reduce = OperationButtonEntity(ReduceStr)
    public static let Multiply = OperationButtonEntity(MultiplyStr)
    public static let Divide = OperationButtonEntity(DivideStr)

    public static let LeftBracket = OperationButtonEntity(LeftBracketStr)
    public static let RightBracket = OperationButtonEntity(RightBracketStr)

    public static let Eval = EvalButtonEntity(CalculatingStr)
    public static let Pop = OperationButtonEntity(PopStr)
    public static let Clear = AcButtonEntity(ClearStr)
}