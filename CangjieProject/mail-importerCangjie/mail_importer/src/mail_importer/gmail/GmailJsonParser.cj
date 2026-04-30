package mail_importer.gmail

import std.collection.ArrayList
import std.collection.HashMap

// 针对性解析 Gmail API JSON 响应（非通用 JSON 解析器）。

// 常用字节常量
let BYTE_COLON: UInt8 = 58      // ':'
let BYTE_QUOTE: UInt8 = 34      // '"'
let BYTE_BACKSLASH: UInt8 = 92  // '\\'
let BYTE_LBRACKET: UInt8 = 91   // '['
let BYTE_RBRACKET: UInt8 = 93   // ']'
let BYTE_LBRACE: UInt8 = 123    // '{'
let BYTE_RBRACE: UInt8 = 125    // '}'
let BYTE_COMMA: UInt8 = 44      // ','
let BYTE_SPACE: UInt8 = 32      // ' '
let BYTE_TAB: UInt8 = 9         // '\t'
let BYTE_NEWLINE: UInt8 = 10    // '\n'
let BYTE_CR: UInt8 = 13         // '\r'
let BYTE_N: UInt8 = 110         // 'n'
let BYTE_T: UInt8 = 116         // 't'
let BYTE_R: UInt8 = 114         // 'r'
let BYTE_SLASH: UInt8 = 47      // '/'

// 解析 listLabels 响应
public func parseListLabelsResponse(json: String): GmailListLabelsResponse {
    let labels = ArrayList<GmailLabelResponse>()
    if (let Some(labelsStart) <- json.indexOf("\"labels\"")) {
        let arrStart = findByteAfter(json, labelsStart, BYTE_LBRACKET)
        if (arrStart >= 0) {
            let arrEnd = findMatchingBracket(json, arrStart)
            if (arrEnd > arrStart) {
                parseLabelArray(json[arrStart + 1..arrEnd], labels)
            }
        }
    }
    GmailListLabelsResponse(labels)
}

// 解析 listMessages 响应
public func parseListMessagesResponse(json: String): GmailListMessagesResponse {
    let messages = ArrayList<GmailMessageRef>()
    if (let Some(msgsStart) <- json.indexOf("\"messages\"")) {
        let arrStart = findByteAfter(json, msgsStart, BYTE_LBRACKET)
        if (arrStart >= 0) {
            let arrEnd = findMatchingBracket(json, arrStart)
            if (arrEnd > arrStart) {
                parseMessageRefArray(json[arrStart + 1..arrEnd], messages)
            }
        }
    }
    GmailListMessagesResponse(messages)
}

// 解析 message 响应
public func parseMessageResponse(json: String): GmailMessageResponse {
    let id = extractStringValue(json, "id")
    let msg = GmailMessageResponse(id)

    if (let Some(labelsStart) <- json.indexOf("\"labelIds\"")) {
        let arrStart = findByteAfter(json, labelsStart, BYTE_LBRACKET)
        if (arrStart >= 0) {
            let arrEnd = findMatchingBracket(json, arrStart)
            if (arrEnd > arrStart) {
                parseStringArray(json[arrStart + 1..arrEnd], msg.labelIds)
            }
        }
    }

    msg.threadId = extractStringValue(json, "threadId")
    msg
}

// 解析 label 响应
public func parseLabelResponse(json: String): GmailLabelResponse {
    GmailLabelResponse(extractStringValue(json, "id"), extractStringValue(json, "name"))
}

// === 内部辅助 ===

// 提取 JSON 字符串值: "key": "value"
func extractStringValue(json: String, key: String): String {
    let searchKey = "\"${key}\""
    if (let Some(keyPos) <- json.indexOf(searchKey)) {
        var pos = keyPos + searchKey.size
        // 找到冒号
        while (pos < json.size && json[pos] != BYTE_COLON) {
            pos++
        }
        if (pos >= json.size) {
            return ""
        }
        pos++  // 跳过冒号
        // 跳过空白
        while (pos < json.size && isWhitespace(json[pos])) {
            pos++
        }
        // 期望引号
        if (pos < json.size && json[pos] == BYTE_QUOTE) {
            pos++
            let start = pos
            while (pos < json.size && json[pos] != BYTE_QUOTE) {
                if (json[pos] == BYTE_BACKSLASH && pos + 1 < json.size) {
                    pos += 2
                } else {
                    pos++
                }
            }
            return unescapeJsonString(json[start..pos])
        }
    }
    ""
}

func isWhitespace(ch: UInt8): Bool {
    ch == BYTE_SPACE || ch == BYTE_TAB || ch == BYTE_NEWLINE || ch == BYTE_CR
}

// 在指定位置之后查找特定字节
func findByteAfter(json: String, startPos: Int64, target: UInt8): Int64 {
    var i = startPos
    while (i < json.size) {
        if (json[i] == target) {
            return i
        }
        i++
    }
    -1
}

// 找到匹配的右括号
func findMatchingBracket(json: String, startPos: Int64): Int64 {
    if (startPos >= json.size || json[startPos] != BYTE_LBRACKET) {
        return -1
    }
    var depth = 1
    var i = startPos + 1
    var inString = false
    while (i < json.size && depth > 0) {
        if (inString) {
            if (json[i] == BYTE_BACKSLASH && i + 1 < json.size) {
                i += 2
                continue
            }
            if (json[i] == BYTE_QUOTE) {
                inString = false
            }
        } else {
            if (json[i] == BYTE_QUOTE) {
                inString = true
            } else if (json[i] == BYTE_LBRACKET) {
                depth++
            } else if (json[i] == BYTE_RBRACKET) {
                depth--
            }
        }
        i++
    }
    if (depth == 0) { i - 1 } else { -1 }
}

// 解析标签对象数组
func parseLabelArray(json: String, labels: ArrayList<GmailLabelResponse>): Unit {
    for (obj in splitTopLevelObjects(json)) {
        let id = extractStringValue(obj, "id")
        let name = extractStringValue(obj, "name")
        if (!id.isEmpty()) {
            labels.add(GmailLabelResponse(id, name))
        }
    }
}

// 解析消息引用数组
func parseMessageRefArray(json: String, messages: ArrayList<GmailMessageRef>): Unit {
    for (obj in splitTopLevelObjects(json)) {
        let id = extractStringValue(obj, "id")
        if (!id.isEmpty()) {
            messages.add(GmailMessageRef(id))
        }
    }
}

// 解析字符串数组
func parseStringArray(json: String, result: ArrayList<String>): Unit {
    var i = 0
    while (i < json.size) {
        while (i < json.size && (isWhitespace(json[i]) || json[i] == BYTE_COMMA)) {
            i++
        }
        if (i >= json.size) {
            break
        }
        if (json[i] == BYTE_QUOTE) {
            i++
            let start = i
            while (i < json.size && json[i] != BYTE_QUOTE) {
                if (json[i] == BYTE_BACKSLASH && i + 1 < json.size) {
                    i += 2
                } else {
                    i++
                }
            }
            result.add(unescapeJsonString(json[start..i]))
            i++
        } else {
            i++
        }
    }
}

// 分割顶层 JSON 对象
func splitTopLevelObjects(json: String): ArrayList<String> {
    let objects = ArrayList<String>()
    var i = 0
    while (i < json.size) {
        while (i < json.size && (isWhitespace(json[i]) || json[i] == BYTE_COMMA)) {
            i++
        }
        if (i >= json.size) {
            break
        }
        if (json[i] == BYTE_LBRACE) {
            let start = i
            var depth = 1
            i++
            var inString = false
            while (i < json.size && depth > 0) {
                if (inString) {
                    if (json[i] == BYTE_BACKSLASH && i + 1 < json.size) {
                        i += 2
                        continue
                    }
                    if (json[i] == BYTE_QUOTE) {
                        inString = false
                    }
                } else {
                    if (json[i] == BYTE_QUOTE) {
                        inString = true
                    } else if (json[i] == BYTE_LBRACE) {
                        depth++
                    } else if (json[i] == BYTE_RBRACE) {
                        depth--
                    }
                }
                i++
            }
            objects.add(json[start..i])
        } else {
            i++
        }
    }
    objects
}

// 处理 JSON 字符串转义序列
func unescapeJsonString(s: String): String {
    let result = StringBuilder()
    var i = 0
    while (i < s.size) {
        if (s[i] == BYTE_BACKSLASH && i + 1 < s.size) {
            i++
            if (s[i] == BYTE_N) {
                result.append("\n")
            } else if (s[i] == BYTE_T) {
                result.append("\t")
            } else if (s[i] == BYTE_R) {
                result.append("\r")
            } else if (s[i] == BYTE_QUOTE) {
                result.append("\"")
            } else if (s[i] == BYTE_BACKSLASH) {
                result.append("\\")
            } else if (s[i] == BYTE_SLASH) {
                result.append("/")
            } else {
                result.append(s[i])
            }
        } else {
            result.append(s[i])
        }
        i++
    }
    result.toString()
}
