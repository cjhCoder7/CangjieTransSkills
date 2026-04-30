package splash_lib

/// 定义语法高亮中可能的标记类型
public enum TokenType {
    | keyword
    | string
    | `type`
    | call
    | number
    | comment
    | property
    | dotAccess
    | preprocessing
    | custom(String)

    public operator func !=(right: TokenType): Bool {
        !(this == right)
    }

    public operator func ==(right: TokenType): Bool {
        match (this) {
            case custom(t1) =>
                match (right) {
                    case custom(t2) => t1 == t2
                    case _ => false
                }
            case keyword =>
                match (right) {
                    case keyword => true
                    case _ => false
                }
            case string =>
                match (right) {
                    case string => true
                    case _ => false
                }
            case `type` =>
                match (right) {
                    case `type` => true
                    case _ => false
                }
            case call =>
                match (right) {
                    case call => true
                    case _ => false
                }
            case number =>
                match (right) {
                    case number => true
                    case _ => false
                }
            case comment =>
                match (right) {
                    case comment => true
                    case _ => false
                }
            case property =>
                match (right) {
                    case property => true
                    case _ => false
                }
            case dotAccess =>
                match (right) {
                    case dotAccess => true
                    case _ => false
                }
            case preprocessing =>
                match (right) {
                    case preprocessing => true
                    case _ => false
                }
        }
    }

    public func getString(): String {
        match (this) {
            case custom(t) => t
            case keyword => "keyword"
            case string => "string"
            case `type` => "type"
            case call => "call"
            case number => "number"
            case comment => "comment"
            case property => "property"
            case dotAccess => "dotAccess"
            case preprocessing => "preprocessing"
        }
    }
}
