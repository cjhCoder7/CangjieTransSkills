package tinydb

import std.collection.*
import std.regex.*

// 查询协议接口
public interface QueryLike {
    func call(value: HashMap<String, Any>): Bool
}

// 查询实例：承载具体的查询条件和逻辑组合
public open class QueryInstance <: QueryLike & Equatable<QueryInstance> & Hashable {
    var _test: (HashMap<String, Any>) -> Bool
    var _hash: ?Int64

    public init(test: (HashMap<String, Any>) -> Bool, hashval!: ?Int64 = None<Int64>) {
        this._test = test
        this._hash = hashval
    }

    public func isCacheable(): Bool {
        _hash != None<Int64>
    }

    public func call(value: HashMap<String, Any>): Bool {
        _test(value)
    }

    public func hashCode(): Int64 {
        match (_hash) {
            case Some(h) => h
            case None => 0
        }
    }

    public operator func ==(rhs: QueryInstance): Bool {
        _hash == rhs._hash
    }

    public operator func !=(rhs: QueryInstance): Bool {
        !(_hash == rhs._hash)
    }

    public open func toString(): String {
        "QueryInstance(hash=${hashCode()})"
    }

    // AND 组合
    public operator func &(other: QueryInstance): QueryInstance {
        var hashval: ?Int64 = None<Int64>
        if (isCacheable() && other.isCacheable()) {
            let h1 = _safeHash(hashCode())
            let h2 = _safeHash(other.hashCode())
            // 使用 min/max 确保交换律
            let lo = if (h1 < h2) { h1 } else { h2 }
            let hi = if (h1 < h2) { h2 } else { h1 }
            hashval = _safeHash(lo) ^ hi ^ "and".hashCode()
        }
        return QueryInstance(
            { value: HashMap<String, Any> => call(value) && other.call(value) },
            hashval: hashval
        )
    }

    // OR 组合
    public operator func |(other: QueryInstance): QueryInstance {
        var hashval: ?Int64 = None<Int64>
        if (isCacheable() && other.isCacheable()) {
            let h1 = _safeHash(hashCode())
            let h2 = _safeHash(other.hashCode())
            let lo = if (h1 < h2) { h1 } else { h2 }
            let hi = if (h1 < h2) { h2 } else { h1 }
            hashval = _safeHash(lo) ^ hi ^ "or".hashCode()
        }
        return QueryInstance(
            { value: HashMap<String, Any> => call(value) || other.call(value) },
            hashval: hashval
        )
    }

    // NOT 取反
    public operator func !(): QueryInstance {
        var hashval: ?Int64 = None<Int64>
        if (isCacheable()) {
            hashval = hashCode() ^ (-1)
        }
        return QueryInstance(
            { value: HashMap<String, Any> => !call(value) },
            hashval: hashval
        )
    }
}

// 查询构建器
public open class Query <: QueryInstance {
    var _path: ArrayList<Any> = ArrayList<Any>()

    public init() {
        super(
            { _: HashMap<String, Any> => throw Exception("Empty query was evaluated") },
            hashval: 0
        )
    }

    public func toString(): String {
        let parts = ArrayList<String>()
        for (p in _path) {
            if (let Some(s) <- (p as String)) {
                parts.add(s)
            } else {
                parts.add("<fn>")
            }
        }
        "Query(path=[${parts.toArray()}])"
    }

    // 通过字段名创建子查询
    public func field(name: String): Query {
        let q = Query()
        for (p in _path) {
            q._path.add(p)
        }
        q._path.add(name)
        var hashval: ?Int64 = None<Int64>
        if (isCacheable()) {
            var h = hashCode()
            h = _safeHash(h) ^ name.hashCode()
            hashval = h
        }
        q._hash = hashval
        return q
    }

    // 解析路径并提取值
    func _resolvePath(value: HashMap<String, Any>): ?Any {
        var current: Any = value
        for (part in _path) {
            if (let Some(key) <- (part as String)) {
                if (let Some(m) <- (current as HashMap<String, Any>)) {
                    if (m.contains(key)) {
                        current = m.get(key).getOrThrow()
                    } else {
                        return None<Any>
                    }
                } else {
                    return None<Any>
                }
            } else if (let Some(fn) <- (part as (Any) -> Any)) {
                try {
                    current = fn(current)
                } catch (_: Exception) {
                    return None<Any>
                }
            } else {
                return None<Any>
            }
        }
        return current
    }

    // 生成测试函数
    func _generateTest(
        test: (Any) -> Bool,
        hashval: Int64,
        allowEmptyPath!: Bool = false
    ): QueryInstance {
        if (_path.size == 0 && !allowEmptyPath) {
            throw Exception("Query has no path")
        }

        let currentHash = if (isCacheable()) { hashval } else { 0 }

        return QueryInstance(
            { value: HashMap<String, Any> =>
                if (let Some(resolved) <- _resolvePath(value)) {
                    test(resolved)
                } else {
                    false
                }
            },
            hashval: if (isCacheable()) { currentHash } else { None<Int64> }
        )
    }

    // 等于
    public func eq(rhs: Any): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "eq".hashCode()
        if (let Some(s) <- (rhs as String)) {
            hashval = _safeHash(hashval) ^ s.hashCode()
        } else if (let Some(n) <- (rhs as Int64)) {
            hashval = hashval ^ n
        }
        return _generateTest(
            { value: Any => _valueEquals(value, rhs) },
            hashval
        )
    }

    // 不等于
    public func ne(rhs: Any): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "ne".hashCode()
        return _generateTest(
            { value: Any => !_valueEquals(value, rhs) },
            hashval
        )
    }

    // 小于
    public func lt(rhs: Any): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "lt".hashCode()
        return _generateTest(
            { value: Any => _valueCompare(value, rhs) < 0 },
            hashval
        )
    }

    // 小于等于
    public func le(rhs: Any): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "le".hashCode()
        return _generateTest(
            { value: Any => _valueCompare(value, rhs) <= 0 },
            hashval
        )
    }

    // 大于
    public func gt(rhs: Any): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "gt".hashCode()
        return _generateTest(
            { value: Any => _valueCompare(value, rhs) > 0 },
            hashval
        )
    }

    // 大于等于
    public func ge(rhs: Any): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "ge".hashCode()
        return _generateTest(
            { value: Any => _valueCompare(value, rhs) >= 0 },
            hashval
        )
    }

    // 字段存在
    public func exists(): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "exists".hashCode()
        return _generateTest(
            { _: Any => true },
            hashval
        )
    }

    // 正则全匹配
    public func matches(regex: String): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "matches".hashCode() ^ regex.hashCode()
        return _generateTest(
            { value: Any =>
                if (let Some(s) <- (value as String)) {
                    let r = Regex(regex)
                    r.matches(s)
                } else {
                    false
                }
            },
            hashval
        )
    }

    // 正则子串匹配
    public func search(regex: String): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "search".hashCode() ^ regex.hashCode()
        return _generateTest(
            { value: Any =>
                if (let Some(s) <- (value as String)) {
                    let r = Regex(regex)
                    match (r.find(s)) {
                        case Some(_) => true
                        case None => false
                    }
                } else {
                    false
                }
            },
            hashval
        )
    }

    // 用户自定义测试函数
    public func test(fn: (Any) -> Bool): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "test".hashCode()
        return _generateTest(
            { value: Any => fn(value) },
            hashval
        )
    }

    // 列表中任一元素满足条件（QueryInstance 版）
    public func anyOf(cond: QueryInstance): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "anyOf".hashCode()
        return _generateTest(
            { value: Any =>
                if (let Some(arr) <- (value as Array<Any>)) {
                    _anyOfArr(arr, cond)
                } else {
                    false
                }
            },
            hashval
        )
    }

    // 列表中任一元素在给定列表中（Array 版）
    public func anyOf(items: Array<Any>): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "anyOf".hashCode()
        return _generateTest(
            { value: Any =>
                if (let Some(arr) <- (value as Array<Any>)) {
                    _anyOfList(arr, items)
                } else {
                    false
                }
            },
            hashval
        )
    }

    // 列表中所有元素满足条件（QueryInstance 版）
    public func allOf(cond: QueryInstance): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "allOf".hashCode()
        return _generateTest(
            { value: Any =>
                if (let Some(arr) <- (value as Array<Any>)) {
                    _allOfArr(arr, cond)
                } else {
                    false
                }
            },
            hashval
        )
    }

    // 列表中包含给定列表的所有元素（Array 版）
    public func allOf(items: Array<Any>): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "allOf".hashCode()
        return _generateTest(
            { value: Any =>
                if (let Some(arr) <- (value as Array<Any>)) {
                    _allOfList(arr, items)
                } else {
                    false
                }
            },
            hashval
        )
    }

    // 值在给定列表中
    public func oneOf(items: Array<Any>): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "oneOf".hashCode()
        return _generateTest(
            { value: Any =>
                _oneOfCheck(value, items)
            },
            hashval
        )
    }

    // 文档包含指定片段
    public func fragment(document: HashMap<String, Any>): QueryInstance {
        var hashval = _safeHash(hashCode()) ^ "fragment".hashCode()
        return _generateTest(
            { value: Any => _fragmentCheck(value, document) },
            hashval,
            allowEmptyPath: true
        )
    }

    // 永真查询
    public func noop(): QueryInstance {
        QueryInstance(
            { _: HashMap<String, Any> => true },
            hashval: 1
        )
    }

    // 对路径中的值应用转换函数
    public func map(fn: (Any) -> Any): Query {
        let q = Query()
        for (p in _path) {
            q._path.add(p)
        }
        q._path.add(fn)
        q._hash = None<Int64>
        return q
    }
}

// anyOf 辅助：数组中任一元素满足 QueryInstance 条件
func _anyOfArr(arr: Array<Any>, cond: QueryInstance): Bool {
    for (item in arr) {
        if (let Some(m) <- (item as HashMap<String, Any>)) {
            if (cond.call(m)) {
                return true
            }
        }
    }
    return false
}

// anyOf 辅助：数组中任一元素在给定列表中
func _anyOfList(arr: Array<Any>, items: Array<Any>): Bool {
    for (elem in arr) {
        if (_oneOfCheck(elem, items)) {
            return true
        }
    }
    return false
}

// allOf 辅助：数组中所有元素满足 QueryInstance 条件
func _allOfArr(arr: Array<Any>, cond: QueryInstance): Bool {
    for (item in arr) {
        if (let Some(m) <- (item as HashMap<String, Any>)) {
            if (!cond.call(m)) {
                return false
            }
        }
    }
    return true
}

// allOf 辅助：给定列表中所有元素都在数组中
func _allOfList(arr: Array<Any>, items: Array<Any>): Bool {
    for (item in items) {
        if (!_oneOfCheck(item, arr)) {
            return false
        }
    }
    return true
}

func _oneOfCheck(value: Any, items: Array<Any>): Bool {
    for (item in items) {
        if (_valueEquals(value, item)) {
            return true
        }
    }
    return false
}

func _fragmentCheck(value: Any, document: HashMap<String, Any>): Bool {
    if (let Some(m) <- (value as HashMap<String, Any>)) {
        for ((key, val) in document) {
            if (!m.contains(key)) {
                return false
            }
            if (!_valueEquals(m.get(key).getOrThrow(), val)) {
                return false
            }
        }
        return true
    } else {
        return false
    }
}

// 便捷函数：通过字段名创建查询
public func `where`(key: String): Query {
    Query().field(key)
}

// 值比较辅助函数
func _valueEquals(a: Any, b: Any): Bool {
    if (let Some(sa) <- (a as String)) {
        if (let Some(sb) <- (b as String)) {
            return sa == sb
        }
        return false
    }
    if (let Some(na) <- (a as Int64)) {
        if (let Some(nb) <- (b as Int64)) {
            return na == nb
        }
        return false
    }
    if (let Some(fa) <- (a as Float64)) {
        if (let Some(fb) <- (b as Float64)) {
            return fa == fb
        }
        return false
    }
    if (let Some(ba) <- (a as Bool)) {
        if (let Some(bb) <- (b as Bool)) {
            return ba == bb
        }
        return false
    }
    return false
}

func _valueCompare(a: Any, b: Any): Int64 {
    if (let Some(na) <- (a as Int64)) {
        if (let Some(nb) <- (b as Int64)) {
            if (na < nb) { return -1 }
            if (na > nb) { return 1 }
            return 0
        }
    }
    if (let Some(fa) <- (a as Float64)) {
        if (let Some(fb) <- (b as Float64)) {
            if (fa < fb) { return -1 }
            if (fa > fb) { return 1 }
            return 0
        }
    }
    if (let Some(sa) <- (a as String)) {
        if (let Some(sb) <- (b as String)) {
            if (sa < sb) { return -1 }
            if (sa > sb) { return 1 }
            return 0
        }
    }
    return 0
}

func _safeHash(h: Int64): Int64 {
    (h ^ (h >> 33)) & 0x7FFFFFFFFFFFFFFF
}
