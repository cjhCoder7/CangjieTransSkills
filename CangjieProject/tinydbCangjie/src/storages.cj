package tinydb

import std.collection.*
import std.convert.*
import std.fs.*

// 存储抽象接口
// 数据模型：tableName → (docId → (fieldName → fieldValue))
public interface Storage {
    func read(): ?HashMap<String, HashMap<String, HashMap<String, Any>>>
    func write(data: HashMap<String, HashMap<String, HashMap<String, Any>>>): Unit
    func close(): Unit
}

// JSON 文件存储
public class JSONStorage <: Storage {
    var path: String
    var createDirs: Bool
    var accessMode: String
    var cache: ?HashMap<String, HashMap<String, HashMap<String, Any>>> = None<HashMap<String, HashMap<String, HashMap<String, Any>>>>
    var modified: Bool = false

    public init(path: String, createDirs!: Bool = false, accessMode!: String = "r+") {
        this.path = path
        this.createDirs = createDirs
        this.accessMode = accessMode

        if (accessMode != "r" && accessMode != "r+") {
            println("Warning: Using access_mode other than 'r' or 'r+' can cause data loss or corruption")
        }

        if (accessMode.contains("+") || accessMode.contains("w") || accessMode.contains("a")) {
            _touchFile(path, createDirs)
        }

        if (exists(path)) {
            try {
                let bytes = File.readFrom(path)
                if (bytes.size > 0) {
                    let content = String.fromUtf8(bytes)
                    if (content.size > 2) {
                        cache = _parseJson(content)
                    }
                }
            } catch (_: Exception) {}
        }
    }

    public func read(): ?HashMap<String, HashMap<String, HashMap<String, Any>>> {
        cache
    }

    public func write(data: HashMap<String, HashMap<String, HashMap<String, Any>>>): Unit {
        cache = data
        modified = true
        _flush()
    }

    public func close(): Unit {
        if (modified) {
            _flush()
        }
    }

    func _flush(): Unit {
        let jsonStr = if (let Some(data) <- cache) {
            _serializeToJson(data)
        } else {
            "{}"
        }
        try {
            let file = File(path, OpenMode.Write)
            try {
                file.write(jsonStr.toArray())
                file.flush()
                // 截断可能残留的旧数据（写入内容比之前短时）
                file.setLength(Int64(jsonStr.toArray().size))
            } finally {
                file.close()
            }
            modified = false
        } catch (_: Exception) {}
    }

    func _parseJson(content: String): ?HashMap<String, HashMap<String, HashMap<String, Any>>> {
        let parser = _JsonParser(content)
        let result = parser.parseValue()
        if (let Some(topMap) <- (result as HashMap<String, Any>)) {
            let tables = HashMap<String, HashMap<String, HashMap<String, Any>>>()
            for ((tableName, tableVal) in topMap) {
                if (let Some(tableMap) <- (tableVal as HashMap<String, Any>)) {
                    let docs = HashMap<String, HashMap<String, Any>>()
                    for ((docIdStr, docVal) in tableMap) {
                        if (let Some(docMap) <- (docVal as HashMap<String, Any>)) {
                            docs[docIdStr] = docMap
                        }
                    }
                    tables[tableName] = docs
                }
            }
            return tables
        }
        return None<HashMap<String, HashMap<String, HashMap<String, Any>>>>
    }

    func _serializeToJson(data: HashMap<String, HashMap<String, HashMap<String, Any>>>): String {
        let sb = StringBuilder()
        sb.append("{")
        var first = true
        for ((tableName, tableData) in data) {
            if (!first) {
                sb.append(",")
            }
            first = false
            sb.append("\"")
            sb.append(_escapeString(tableName))
            sb.append("\":{")
            var firstDoc = true
            for ((docId, document) in tableData) {
                if (!firstDoc) {
                    sb.append(",")
                }
                firstDoc = false
                sb.append("\"")
                sb.append(_escapeString(docId))
                sb.append("\":")
                sb.append(_serializeMap(document))
            }
            sb.append("}")
        }
        sb.append("}")
        return sb.toString()
    }

    func _serializeMap(map: HashMap<String, Any>): String {
        let sb = StringBuilder()
        sb.append("{")
        var first = true
        for ((key, val) in map) {
            if (!first) {
                sb.append(",")
            }
            first = false
            sb.append("\"")
            sb.append(_escapeString(key))
            sb.append("\":")
            sb.append(_serializeValue(val))
        }
        sb.append("}")
        return sb.toString()
    }

    func _serializeValue(val: Any): String {
        if (let Some(s) <- (val as String)) {
            return "\"${_escapeString(s)}\""
        }
        if (let Some(n) <- (val as Int64)) {
            return "${n}"
        }
        if (let Some(f) <- (val as Float64)) {
            return "${f}"
        }
        if (let Some(b) <- (val as Bool)) {
            return if (b) { "true" } else { "false" }
        }
        if (let Some(m) <- (val as HashMap<String, Any>)) {
            return _serializeMap(m)
        }
        if (let Some(arr) <- (val as Array<Any>)) {
            let sb = StringBuilder()
            sb.append("[")
            for (i in 0..arr.size) {
                if (i > 0) {
                    sb.append(",")
                }
                sb.append(_serializeValue(arr[Int64(i)]))
            }
            sb.append("]")
            return sb.toString()
        }
        return "null"
    }

    func _escapeString(s: String): String {
        var result = ""
        var i: Int64 = 0
        let bytes = s.toArray()
        while (i < bytes.size) {
            let b = bytes[Int64(i)]
            if (b == 34) {
                result = result + "\\\""
                i += 1
            } else if (b == 92) {
                result = result + "\\\\"
                i += 1
            } else if (b == 10) {
                result = result + "\\n"
                i += 1
            } else if (b == 13) {
                result = result + "\\r"
                i += 1
            } else if (b == 9) {
                result = result + "\\t"
                i += 1
            } else {
                result = result + String.fromUtf8([b])
                i += 1
            }
        }
        return result
    }
}

// 内存存储
public class MemoryStorage <: Storage {
    var memory: ?HashMap<String, HashMap<String, HashMap<String, Any>>> = None<HashMap<String, HashMap<String, HashMap<String, Any>>>>

    public init() {}

    public func read(): ?HashMap<String, HashMap<String, HashMap<String, Any>>> {
        memory
    }

    public func write(data: HashMap<String, HashMap<String, HashMap<String, Any>>>): Unit {
        memory = data
    }

    public func close(): Unit {}
}

func _touchFile(path: String, createDirs: Bool): Unit {
    if (createDirs) {
        if (let Some(idx) <- path.lastIndexOf('/')) {
            if (idx > 0) {
                let dirPath = path[0..idx]
                if (!exists(dirPath)) {
                    Directory.create(dirPath, recursive: true)
                }
            }
        }
    }
    if (!exists(path)) {
        try {
            let f = File(path, OpenMode.Write)
            f.close()
        } catch (_: Exception) {}
    }
}

// 简易 JSON 解析器
class _JsonParser {
    var src: String
    var bytes: Array<UInt8>
    var pos: Int64 = 0

    init(src: String) {
        this.src = src
        this.bytes = src.toArray()
    }

    func parseValue(): Any {
        skipWhitespace()
        if (pos >= bytes.size) {
            return ""
        }
        let b = bytes[pos]
        if (b == 123u8) { // '{'
            return parseObject()
        } else if (b == 91u8) { // '['
            return parseArray()
        } else if (b == 34u8) { // '"'
            return parseString()
        } else if (b == 116u8 || b == 102u8) { // 't' or 'f'
            return parseBool()
        } else if (b == 110u8) { // 'n'
            parseNull()
            return ""
        } else {
            return parseNumber()
        }
    }

    func parseObject(): HashMap<String, Any> {
        pos += 1 // skip '{'
        skipWhitespace()
        let result = HashMap<String, Any>()
        if (pos < bytes.size && bytes[pos] == 125u8) { // '}'
            pos += 1
            return result
        }
        while (pos < bytes.size) {
            skipWhitespace()
            if (bytes[pos] != 34u8) { // '"'
                break
            }
            let key = parseString()
            skipWhitespace()
            if (pos < bytes.size && bytes[pos] == 58u8) { // ':'
                pos += 1
            }
            let val = parseValue()
            result[key] = val
            skipWhitespace()
            if (pos < bytes.size && bytes[pos] == 44u8) { // ','
                pos += 1
            } else {
                break
            }
        }
        if (pos < bytes.size && bytes[pos] == 125u8) { // '}'
            pos += 1
        }
        return result
    }

    func parseArray(): Array<Any> {
        pos += 1 // skip '['
        skipWhitespace()
        let result = ArrayList<Any>()
        if (pos < bytes.size && bytes[pos] == 93u8) { // ']'
            pos += 1
            return result.toArray()
        }
        while (pos < bytes.size) {
            skipWhitespace()
            let val = parseValue()
            result.add(val)
            skipWhitespace()
            if (pos < bytes.size && bytes[pos] == 44u8) { // ','
                pos += 1
            } else {
                break
            }
        }
        if (pos < bytes.size && bytes[pos] == 93u8) { // ']'
            pos += 1
        }
        return result.toArray()
    }

    func parseString(): String {
        pos += 1 // skip opening '"'
        var result = ""
        while (pos < bytes.size) {
            let b = bytes[pos]
            if (b == 34u8) { // '"'
                pos += 1
                return result
            } else if (b == 92u8) { // '\'
                pos += 1
                if (pos < bytes.size) {
                    let esc = bytes[pos]
                    if (esc == 34u8) {
                        result = result + "\""
                    } else if (esc == 92u8) {
                        result = result + "\\"
                    } else if (esc == 110u8) { // 'n'
                        result = result + "\n"
                    } else if (esc == 114u8) { // 'r'
                        result = result + "\r"
                    } else if (esc == 116u8) { // 't'
                        result = result + "\t"
                    } else if (esc == 47u8) { // '/'
                        result = result + "/"
                    } else if (esc == 117u8) { // 'u'
                        pos += 4
                        result = result + "?"
                    } else {
                        result = result + String.fromUtf8([esc])
                    }
                }
                pos += 1
            } else {
                result = result + String.fromUtf8([b])
                pos += 1
            }
        }
        return result
    }

    func parseNumber(): Any {
        var numStr = ""
        var isFloat = false
        while (pos < bytes.size) {
            let b = bytes[pos]
            if ((b >= 48u8 && b <= 57u8) || b == 45u8 || b == 43u8 || b == 101u8 || b == 69u8 || b == 46u8) {
                if (b == 46u8 || b == 101u8 || b == 69u8) {
                    isFloat = true
                }
                numStr = numStr + String.fromUtf8([b])
                pos += 1
            } else {
                break
            }
        }
        if (isFloat) {
            if (let Some(f) <- Float64.tryParse(numStr)) {
                return f
            }
            return Float64(0.0)
        } else {
            if (let Some(n) <- Int64.tryParse(numStr)) {
                return n
            }
            return Int64(0)
        }
    }

    func parseBool(): Bool {
        if (bytes[pos] == 116u8) { // 't'
            pos += 4 // skip "true"
            return true
        } else {
            pos += 5 // skip "false"
            return false
        }
    }

    func parseNull(): Unit {
        pos += 4 // skip "null"
    }

    func skipWhitespace(): Unit {
        while (pos < bytes.size) {
            let b = bytes[pos]
            if (b == 32u8 || b == 9u8 || b == 10u8 || b == 13u8) { // space, tab, \n, \r
                pos += 1
            } else {
                break
            }
        }
    }
}
