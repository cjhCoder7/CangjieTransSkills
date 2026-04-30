package tinydb

import std.collection.*
import std.sort.*

// LRU 缓存，固定容量，超出时淘汰最久未访问的条目
public open class LRUCache<K, V> where K <: Equatable<K> {
    var capacity: ?Int64
    var cache = ArrayList<(K, V)>()

    public init(capacity!: ?Int64 = None<Int64>) {
        this.capacity = capacity
    }

    public func lru(): Array<K> {
        let result = ArrayList<K>()
        for ((k, _) in cache) {
            result.add(k)
        }
        return result.toArray()
    }

    public func length(): Int64 {
        cache.size
    }

    public func clear(): Unit {
        cache.clear()
    }

    public func contains(key: K): Bool {
        for ((k, _) in cache) {
            if (k == key) {
                return true
            }
        }
        return false
    }

    public func get(key: K): ?V {
        var idx: Int64 = -1
        var i: Int64 = 0
        for ((k, v) in cache) {
            if (k == key) {
                idx = i
                break
            }
            i++
        }
        if (idx >= 0) {
            let entry = cache[Int64(idx)]
            cache.remove(at: Int64(idx))
            cache.add(entry)
            return entry[1]
        }
        return None<V>
    }

    public func set(key: K, value: V): Unit {
        var idx: Int64 = -1
        var i: Int64 = 0
        for ((k, _) in cache) {
            if (k == key) {
                idx = i
                break
            }
            i++
        }
        if (idx >= 0) {
            cache.remove(at: Int64(idx))
            cache.add((key, value))
        } else {
            cache.add((key, value))
            if (let Some(cap) <- capacity) {
                if (cache.size > cap) {
                    cache.remove(at: 0)
                }
            }
        }
    }

    public func remove(key: K): ?V {
        var idx: Int64 = -1
        var i: Int64 = 0
        for ((k, v) in cache) {
            if (k == key) {
                idx = i
                break
            }
            i++
        }
        if (idx >= 0) {
            let entry = cache[Int64(idx)]
            cache.remove(at: Int64(idx))
            return entry[1]
        }
        return None<V>
    }

    public func iterator(): Iterator<(K, V)> {
        cache.iterator()
    }
}

// 不可变字典：创建后不可修改，可用于哈希
public class FrozenDict {
    var _data: HashMap<String, Any>
    var _hash: Int64

    public init(data: HashMap<String, Any>) {
        this._data = HashMap<String, Any>()
        for ((k, v) in data) {
            this._data[k] = v
        }
        // 排序键以保证哈希与键顺序无关（Python 使用 frozenset）
        let sortedKeys = ArrayList<String>()
        for (k in this._data.keys()) {
            sortedKeys.add(k)
        }
        sort(sortedKeys)
        var h: Int64 = 0
        for (k in sortedKeys) {
            h = h ^ k.hashCode()
            if (let Some(v) <- this._data.get(k)) {
                if (let Some(s) <- (v as String)) {
                    h = h ^ s.hashCode()
                } else if (let Some(n) <- (v as Int64)) {
                    h = h ^ n
                } else if (let Some(f) <- (v as Float64)) {
                    h = h ^ f.hashCode()
                } else if (let Some(b) <- (v as Bool)) {
                    h = h ^ (if (b) { 1 } else { 0 })
                }
            }
        }
        this._hash = h
    }

    public func toMap(): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        for ((k, v) in _data) {
            result[k] = v
        }
        return result
    }

    public func get(key: String): ?Any {
        _data.get(key)
    }

    public func contains(key: String): Bool {
        _data.contains(key)
    }

    public func size(): Int64 {
        _data.size
    }

    public func hashCode(): Int64 {
        _hash
    }

    public func equals(other: FrozenDict): Bool {
        _hash == other._hash
    }
}

// 递归冻结对象，使其不可变从而可哈希
public func freeze(obj: Any): Any {
    if (let Some(m) <- (obj as HashMap<String, Any>)) {
        return FrozenDict(m)
    }
    if (let Some(arr) <- (obj as Array<Any>)) {
        // 仓颉没有 tuple，冻结数组时返回原数组
        return arr
    }
    return obj
}
