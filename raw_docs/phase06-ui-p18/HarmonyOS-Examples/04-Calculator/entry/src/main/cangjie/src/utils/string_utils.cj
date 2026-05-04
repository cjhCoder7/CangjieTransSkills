/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.utils

public class StringUtils {
    public static func floatToString(f: Float64) {
        let array = f.toString().split('.')
        let part1 = array[0]
        let part2 = trimEnd(array[1], r'0')
        if (part2.size == 0) {
            part1
        } else {
            "${part1}.${part2}"
        }
    }

    public static func trimEnd(s: String, c: Rune) {
        var sb: StringBuilder = StringBuilder()
        var end = s.size - 1
        while (end >= 0 && Rune(s[end]) == c) { end-- }
        for (i in 0..end+1) {
            sb.append(Rune(s[i]))
        }
        return sb.toString()
    }

    public static func isDigit(c: UInt8) {
        (c >= b'0' && c <= b'9') || c == b'.'
    }

    public static func stringToFloat(s: String) {
        var result: Float64 = 0.0
        var splits = s.split(".")
        var part1 = splits[0]
        var part2 = if (splits.size < 2) { "" } else { splits[1] }

        for (c in part1) {
            result = result * 10.0 + Float64(c - b'0')
        }

        var fraction = 10.0
        for (c in part2) {
            result = result + Float64(c - b'0') / fraction
            fraction *= 10.0
        }
        result
    }
}