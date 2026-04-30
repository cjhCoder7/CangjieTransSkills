package tinydb

import std.collection.*

// 中间件基类：拦截存储的读写操作
public open class Middleware <: Storage {
    var _storageCls: () -> Storage
    var _innerStorage: ?Storage = None<Storage>

    public init(storageCls: () -> Storage) {
        this._storageCls = storageCls
    }

    public func initialize(): Unit {
        _innerStorage = _storageCls()
    }

    // 创建并返回内部存储实例（等同于 Python 的 __call__）
    public func createStorage(): Storage {
        let s = _storageCls()
        _innerStorage = s
        return s
    }

    public func innerStorage(): ?Storage {
        _innerStorage
    }

    public open func read(): ?HashMap<String, HashMap<String, HashMap<String, Any>>> {
        if (let Some(s) <- _innerStorage) {
            return s.read()
        }
        return None<HashMap<String, HashMap<String, HashMap<String, Any>>>>
    }

    public open func write(data: HashMap<String, HashMap<String, HashMap<String, Any>>>): Unit {
        if (let Some(s) <- _innerStorage) {
            s.write(data)
        }
    }

    public open func close(): Unit {
        if (let Some(s) <- _innerStorage) {
            s.close()
        }
    }
}

// 缓存中间件：减少磁盘写入频率
public class CachingMiddleware <: Middleware {
    static let WRITE_CACHE_SIZE: Int64 = 1000

    var cache: ?HashMap<String, HashMap<String, HashMap<String, Any>>> = None<HashMap<String, HashMap<String, HashMap<String, Any>>>>
    var _cacheModifiedCount: Int64 = 0

    public init(storageCls: () -> Storage) {
        super(storageCls)
    }

    public func read(): ?HashMap<String, HashMap<String, HashMap<String, Any>>> {
        if (let None <- cache) {
            if (let Some(s) <- _innerStorage) {
                cache = s.read()
            }
        }
        return cache
    }

    public func write(data: HashMap<String, HashMap<String, HashMap<String, Any>>>): Unit {
        cache = data
        _cacheModifiedCount += 1

        if (_cacheModifiedCount >= CachingMiddleware.WRITE_CACHE_SIZE) {
            flush()
        }
    }

    public func flush(): Unit {
        if (_cacheModifiedCount > 0) {
            if (let Some(s) <- _innerStorage) {
                if (let Some(c) <- cache) {
                    s.write(c)
                }
            }
            _cacheModifiedCount = 0
        }
    }

    public func close(): Unit {
        flush()
        if (let Some(s) <- _innerStorage) {
            s.close()
        }
    }
}
