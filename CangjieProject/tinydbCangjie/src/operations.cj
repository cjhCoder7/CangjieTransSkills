package tinydb

import std.collection.*

// 删除文档中指定字段
public func delete(field: String): (HashMap<String, Any>) -> Unit {
    return { doc: HashMap<String, Any> =>
        doc.remove(field)
    }
}

// 字段值加 n（支持 Int64、Float64、String）
public func add(field: String, n: Any): (HashMap<String, Any>) -> Unit {
    return { doc: HashMap<String, Any> =>
        if (let Some(val) <- doc.get(field)) {
            if (let Some(num) <- (val as Int64)) {
                if (let Some(addN) <- (n as Int64)) {
                    doc[field] = num + addN
                }
            } else if (let Some(num) <- (val as Float64)) {
                if (let Some(addN) <- (n as Float64)) {
                    doc[field] = num + addN
                }
            } else if (let Some(s) <- (val as String)) {
                if (let Some(addS) <- (n as String)) {
                    doc[field] = s + addS
                }
            }
        }
    }
}

// 字段值减 n（支持 Int64、Float64）
public func subtract(field: String, n: Any): (HashMap<String, Any>) -> Unit {
    return { doc: HashMap<String, Any> =>
        if (let Some(val) <- doc.get(field)) {
            if (let Some(num) <- (val as Int64)) {
                if (let Some(subN) <- (n as Int64)) {
                    doc[field] = num - subN
                }
            } else if (let Some(num) <- (val as Float64)) {
                if (let Some(subN) <- (n as Float64)) {
                    doc[field] = num - subN
                }
            }
        }
    }
}

// 设置字段值
public func set(field: String, val: Any): (HashMap<String, Any>) -> Unit {
    return { doc: HashMap<String, Any> =>
        doc[field] = val
    }
}

// 字段值自增 1（支持 Int64、Float64）
public func increment(field: String): (HashMap<String, Any>) -> Unit {
    return { doc: HashMap<String, Any> =>
        if (let Some(val) <- doc.get(field)) {
            if (let Some(num) <- (val as Int64)) {
                doc[field] = num + 1
            } else if (let Some(num) <- (val as Float64)) {
                doc[field] = num + 1.0
            }
        }
    }
}

// 字段值自减 1（支持 Int64、Float64）
public func decrement(field: String): (HashMap<String, Any>) -> Unit {
    return { doc: HashMap<String, Any> =>
        if (let Some(val) <- doc.get(field)) {
            if (let Some(num) <- (val as Int64)) {
                doc[field] = num - 1
            } else if (let Some(num) <- (val as Float64)) {
                doc[field] = num - 1.0
            }
        }
    }
}
