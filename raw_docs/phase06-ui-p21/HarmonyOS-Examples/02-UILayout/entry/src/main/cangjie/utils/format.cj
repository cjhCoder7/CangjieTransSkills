/**
 * Created on 2025/8/4
 */
package ohos_app_cangjie_entry.utils

import std.convert.*


public func formatFloat64(num: Float64) {
    let numStr: String = "${num}"
    let pointLoc = numStr.indexOf(".")
    var runeArray: Array<Rune> = numStr.toRuneArray()
    runeArray = runeArray.slice(0,pointLoc.getOrDefault({ => 0}) + 3)
    return String(runeArray)
}