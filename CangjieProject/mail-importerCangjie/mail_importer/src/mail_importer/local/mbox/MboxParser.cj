package mail_importer.local.mbox

import std.collection.ArrayList
import std.collection.HashMap

// RFC 4155 mbox 格式解析器
// 按 "From " 行分割消息，解析 MIME 头部（含折叠行）
public class MboxParser {

    public init() {}

    // 解析 mbox 格式字节数组为原始消息列表
    public func parseBytes(content: Array<UInt8>): ArrayList<MboxRawMessage> {
        let messages = ArrayList<MboxRawMessage>()
        if (content.size == 0) {
            return messages
        }

        // 找到所有 "From " 行的起始位置
        let fromPositions = findFromLines(content)

        // 按位置分割消息
        var i = 0
        while (i < fromPositions.size) {
            let start = fromPositions[i]
            let end = if (i + 1 < fromPositions.size) { fromPositions[i + 1] } else { content.size }
            let messageBytes = sliceArray(content, start, end)
            let rawMsg = parseSingleMessage(messageBytes, Int64(i + 1))
            messages.add(rawMsg)
            i++
        }

        messages
    }

    // 查找所有 mbox "From " 信封行的起始位置
    // "From " 必须在行首（文件开头或 \n 之后）
    func findFromLines(content: Array<UInt8>): ArrayList<Int64> {
        let positions = ArrayList<Int64>()
        let fromBytes = toByteArray([70, 114, 111, 109, 32])  // "From "

        if (content.size >= 5 && matchAt(content, 0, fromBytes)) {
            positions.add(0)
        }

        var i = 1
        while (i < content.size - 4) {
            if (content[i] == 10) {  // '\n'
                if (matchAt(content, i + 1, fromBytes)) {
                    positions.add(Int64(i + 1))
                    i = i + 6  // 跳过 "From "
                } else {
                    i++
                }
            } else {
                i++
            }
        }

        positions
    }

    // 检查 content 从 pos 开始是否匹配 pattern
    func matchAt(content: Array<UInt8>, pos: Int64, pattern: Array<UInt8>): Bool {
        if (pos + pattern.size > content.size) {
            return false
        }
        var i = 0
        while (i < pattern.size) {
            if (content[pos + i] != pattern[i]) {
                return false
            }
            i++
        }
        true
    }

    // 切片数组
    func sliceArray(arr: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
        let size = end - start
        let result = ArrayList<UInt8>()
        var i = start
        while (i < end) {
            result.add(arr[i])
            i++
        }
        result.toArray()
    }

    // 解析单条消息
    func parseSingleMessage(bytes: Array<UInt8>, messageNumber: Int64): MboxRawMessage {
        // 跳过 "From " 信封行
        let bodyStart = findLineEnd(bytes, 0)
        let envelopeSender = extractEnvelopeSender(bytes, 0, bodyStart)

        // 解析头部和正文
        let headerEnd = findHeaderEnd(bytes, bodyStart)
        let headers = parseHeaders(bytes, bodyStart, headerEnd)

        // unescape ">From " 行
        let rawBytes = unescapeFromLines(bytes, bodyStart)

        MboxRawMessage(rawBytes, headers, messageNumber, envelopeSender)
    }

    // 找到从 pos 开始到行尾的位置（不包含 \n）
    func findLineEnd(bytes: Array<UInt8>, pos: Int64): Int64 {
        var i = pos
        while (i < bytes.size) {
            if (bytes[i] == 10) {  // '\n'
                return i
            }
            i++
        }
        bytes.size
    }

    // 提取信封行的发送者（"From sender@domain date" 中的 sender@domain）
    func extractEnvelopeSender(bytes: Array<UInt8>, start: Int64, lineEnd: Int64): String {
        // "From " 后面到下一个空格
        let fromPrefix = 5  // "From ".size
        var senderEnd = start + fromPrefix
        while (senderEnd < lineEnd && bytes[senderEnd] != 32) {  // 空格
            senderEnd++
        }
        if (senderEnd <= start + fromPrefix) {
            return ""
        }
        bytesToString(bytes, start + fromPrefix, senderEnd)
    }

    // 找到头部结束位置（空行：\r\n\r\n 或 \n\n）
    func findHeaderEnd(bytes: Array<UInt8>, start: Int64): Int64 {
        var i = start
        while (i < bytes.size - 1) {
            if (bytes[i] == 10 && bytes[i + 1] == 10) {  // \n\n
                return i
            }
            if (i < bytes.size - 3 && bytes[i] == 13 && bytes[i + 1] == 10 &&
                bytes[i + 2] == 13 && bytes[i + 3] == 10) {  // \r\n\r\n
                return i
            }
            i++
        }
        bytes.size
    }

    // 解析 MIME 头部为 HashMap
    // 处理折叠行（续行以空白字符开头）
    func parseHeaders(bytes: Array<UInt8>, start: Int64, headerEnd: Int64): HashMap<String, Array<String>> {
        let headers = HashMap<String, Array<String>>()
        var pos = start
        var currentName = ""
        var currentValue = ""

        while (pos < headerEnd) {
            let lineEnd = findLineEnd(bytes, pos)
            // 检查是否是折叠行（以空格或制表符开头）
            if (pos < bytes.size && (bytes[pos] == 32 || bytes[pos] == 9)) {
                // 折叠行，追加到当前值
                currentValue = currentValue + " " + bytesToString(bytes, pos, lineEnd).trimAscii()
            } else {
                // 新头部行
                if (!currentName.isEmpty()) {
                    addHeader(headers, currentName, currentValue)
                }
                let line = bytesToString(bytes, pos, lineEnd)
                if (let Some(colonPos) <- line.indexOf(":")) {
                    currentName = line[0..colonPos].trimAscii()
                    currentValue = line[colonPos + 1..].trimAscii()
                } else {
                    currentName = ""
                    currentValue = ""
                }
            }
            pos = lineEnd + 1
        }

        // 最后一个头部
        if (!currentName.isEmpty()) {
            addHeader(headers, currentName, currentValue)
        }

        headers
    }

    // 添加头部到 map（头部名不区分大小写，统一转小写存储）
    func addHeader(headers: HashMap<String, Array<String>>, name: String, value: String): Unit {
        let key = name.toAsciiLower()
        if (let Some(existing) <- headers.get(key)) {
            let newArr = ArrayList<String>()
            for (v in existing) { newArr.add(v) }
            newArr.add(value)
            headers[key] = newArr.toArray()
        } else {
            headers[key] = [value]
        }
    }

    // 将字节数组片段转为 String
    func bytesToString(bytes: Array<UInt8>, start: Int64, end: Int64): String {
        let arr = ArrayList<UInt8>()
        var i = start
        while (i < end && i < bytes.size) {
            arr.add(bytes[i])
            i++
        }
        String.fromUtf8(arr.toArray())
    }

    // 取消 ">From " 转义：mbox 格式中正文里的 "From " 行前面会被加上 ">"
    func unescapeFromLines(bytes: Array<UInt8>, start: Int64): Array<UInt8> {
        let result = ArrayList<UInt8>()
        var i = start
        while (i < bytes.size) {
            // 检查 ">From " 模式（行首的 ">From "）
            if (bytes[i] == 62) {  // '>'
                if (i + 5 < bytes.size &&
                    bytes[i + 1] == 70 && bytes[i + 2] == 114 &&
                    bytes[i + 3] == 111 && bytes[i + 4] == 109 &&
                    bytes[i + 5] == 32) {  // "From "
                    // 检查是否在行首（i == start 或前面是 \n）
                    if (i == start || (i > 0 && bytes[i - 1] == 10)) {
                        // 跳过 ">", 保留 "From "
                        i++
                        continue
                    }
                }
            }
            result.add(bytes[i])
            i++
        }
        result.toArray()
    }
}

// 将 Int64 数组转为 UInt8 数组
func toByteArray(values: Array<Int64>): Array<UInt8> {
    let result = ArrayList<UInt8>()
    for (v in values) {
        result.add(UInt8(v))
    }
    result.toArray()
}
