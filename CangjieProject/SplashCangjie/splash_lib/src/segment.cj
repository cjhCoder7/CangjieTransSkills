package splash_lib

import std.collection.*

/// 代码段的表示
public struct Segment {
    public var prefix: String = ""
    public var tokens: Tokens = Tokens()
    public var trailingWhitespace: ?String = None
    var currentTokenIsDelimiter: Bool = false
    var isLastOnLine: Bool = false
}

/// 段中包含的标记集合
public struct Tokens {
    public var all: Array<String> = Array<String>()
    public var counts: HashMap<String, Int64> = HashMap<String, Int64>()
    public var onSameLine: Array<String> = Array<String>()
    public var previous: ?String = None
    public var current: String = ""
    public var next: ?String = None

    /// 返回给定标记到目前被找到的次数
    public func count(token: String): Int64 {
        counts.get(token) ?? 0
    }
}
