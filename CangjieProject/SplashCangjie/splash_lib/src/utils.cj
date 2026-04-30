package splash_lib

/// HTML 实体转义
public func escapingHTMLEntities(s: String): String {
    var result = StringBuilder()
    for (ch in s.runes()) {
        if (ch == r'&') {
            result.append("&amp;")
        } else if (ch == r'<') {
            result.append("&lt;")
        } else if (ch == r'>') {
            result.append("&gt;")
        } else {
            result.append(ch)
        }
    }
    result.toString()
}

/// 判断字符串是否全部为数字
public func isNumber(s: String): Bool {
    if (s.isEmpty()) {
        return false
    }
    for (ch in s.runes()) {
        if (ch < r'0' || ch > r'9') {
            return false
        }
    }
    true
}

/// 判断字符串首字母是否大写
public func isCapitalized(s: String): Bool {
    let runes = s.toRuneArray()
    if (runes.size == 0) {
        return false
    }
    runes[0] >= r'A' && runes[0] <= r'Z'
}

/// 判断字符串是否以字母开头
public func startsWithLetter(s: String): Bool {
    let runes = s.toRuneArray()
    if (runes.size == 0) {
        return false
    }
    (runes[0] >= r'a' && runes[0] <= r'z') || (runes[0] >= r'A' && runes[0] <= r'Z')
}

/// 移除子字符串
public func removing(s: String, substring: String): String {
    s.replace(substring, "")
}

/// 判断整数是否为偶数
public func isEven(n: Int64): Bool {
    n % 2 == 0
}

/// 判断值是否匹配候选列表中任一项
public func isAnyOf(value: String, candidates: Array<String>): Bool {
    for (c in candidates) {
        if (value == c) {
            return true
        }
    }
    false
}

/// 判断数组是否包含候选列表中任一项
public func containsAnyOf(seq: Array<String>, candidates: Array<String>): Bool {
    for (c in candidates) {
        if (seq.contains(c)) {
            return true
        }
    }
    false
}

/// 统计元素出现次数
public func countOccurrences(seq: Array<String>, target: String): Int64 {
    var count: Int64 = 0
    for (elem in seq) {
        if (elem == target) {
            count += 1
        }
    }
    count
}

/// 判断字符是否为字母
public func isLetter(ch: Rune): Bool {
    (ch >= r'a' && ch <= r'z') || (ch >= r'A' && ch <= r'Z')
}

/// 统计字符在字符串中出现的次数
public func countCharInString(s: String, target: Rune): Int64 {
    var count: Int64 = 0
    for (ch in s.runes()) {
        if (ch == target) { count += 1 }
    }
    count
}

/// 获取字符串指定位置的 Rune
public func runeAt(s: String, index: Int64): ?Rune {
    let runes = s.toRuneArray()
    if (index < 0 || index >= runes.size) { return None }
    runes[index]
}

/// 分隔符字符集
public class DelimiterSet {
    public func contains(ch: Rune): Bool {
        if (isLetter(ch)) { return false }
        if (ch >= r'0' && ch <= r'9') { return false }
        if (ch == r'_') { return false }
        if (ch == r'"') { return false }
        if (ch == r'#') { return false }
        if (ch == r'@') { return false }
        if (ch == r'$') { return false }
        true
    }
}

/// 数组末尾 n 个元素
public func arraySuffix(arr: Array<String>, n: Int64): Array<String> {
    if (n <= 0) { return Array<String>() }
    if (n >= arr.size) { return arr }
    arr.slice(arr.size - n, n)
}

/// 数组反转
public func arrayReversed(arr: Array<String>): Array<String> {
    var copy = arr.clone()
    copy.reverse()
    copy
}

/// 用分隔符连接字符串数组并按分隔符拆分（模拟 Array.split）
public func splitJoinedArray(arr: Array<String>, delimiter: String): Array<String> {
    let joined = String.join(arr, delimiter: delimiter)
    joined.split(delimiter)
}
