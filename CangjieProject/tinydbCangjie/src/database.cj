package tinydb

import std.collection.*

// TinyDB 主类：文档数据库入口
public open class TinyDB {
    var _storage: Storage
    var _opened: Bool = true
    var _tables: HashMap<String, Table> = HashMap<String, Table>()

    public static let defaultTableName: String = "_default"

    public init(storage: Storage) {
        this._storage = storage
    }

    // 便捷构造：使用 JSONStorage 并指定文件路径
    public init(path: String, createDirs!: Bool = false, accessMode!: String = "r+") {
        this._storage = JSONStorage(path, createDirs: createDirs, accessMode: accessMode)
    }

    // 获取或创建表
    public func table(name: String, cacheSize!: Int64 = Table.defaultQueryCacheCapacity, persistEmpty!: Bool = false): Table {
        if (_tables.contains(name)) {
            return _tables[name]
        }

        let t = Table(_storage, name, cacheSize: cacheSize, persistEmpty: persistEmpty)
        _tables[name] = t
        return t
    }

    // 获取所有表名
    public func tables(): HashSet<String> {
        let result = HashSet<String>()
        if (let Some(data) <- _storage.read()) {
            for ((name, _) in data) {
                result.add(name)
            }
        }
        return result
    }

    // 删除所有表
    public func dropTables(): Unit {
        _storage.write(HashMap<String, HashMap<String, HashMap<String, Any>>>())
        _tables.clear()
    }

    // 删除指定表
    public func dropTable(name: String): Unit {
        if (_tables.contains(name)) {
            _tables.remove(name)
        }

        if (let Some(data) <- _storage.read()) {
            if (data.contains(name)) {
                data.remove(name)
                _storage.write(data)
            }
        }
    }

    // 获取存储实例
    public prop storage: Storage {
        get() { _storage }
    }

    // 关闭数据库
    public func close(): Unit {
        _opened = false
        _storage.close()
    }

    // 迭代器支持
    public func iterator(): Iterator<Document> {
        table(defaultTableName).iterator()
    }

    public func toString(): String {
        "TinyDB(tables=${tables().size})"
    }

    // 获取默认表的文档数量
    public func len(): Int64 {
        table(defaultTableName).len()
    }

    // 以下方法转发到默认表

    public func insert(document: HashMap<String, Any>): Int64 {
        table(defaultTableName).insert(document)
    }

    public func insertDoc(document: Document): Int64 {
        table(defaultTableName).insertDoc(document)
    }

    public func insertMultiple(documents: Array<HashMap<String, Any>>): Array<Int64> {
        table(defaultTableName).insertMultiple(documents)
    }

    public func all(): Array<Document> {
        table(defaultTableName).all()
    }

    public func search(cond: QueryInstance): Array<Document> {
        table(defaultTableName).search(cond)
    }

    public func get(cond!: ?QueryInstance, docId!: ?Int64, docIds!: ?Array<Int64>): ?Any {
        table(defaultTableName).get(cond: cond, docId: docId, docIds: docIds)
    }

    public func contains(cond!: ?QueryInstance, docId!: ?Int64): Bool {
        table(defaultTableName).contains(cond: cond, docId: docId)
    }

    public func update(
        fields: Any,
        cond!: ?QueryInstance,
        docIds!: ?Array<Int64>
    ): Array<Int64> {
        table(defaultTableName).update(fields, cond: cond, docIds: docIds)
    }

    public func upsert(document: HashMap<String, Any>, cond!: ?QueryInstance): Array<Int64> {
        table(defaultTableName).upsert(document, cond: cond)
    }

    public func remove(cond!: ?QueryInstance, docIds!: ?Array<Int64>): Array<Int64> {
        table(defaultTableName).remove(cond: cond, docIds: docIds)
    }

    public func truncate(): Unit {
        table(defaultTableName).truncate()
    }

    public func count(cond: QueryInstance): Int64 {
        table(defaultTableName).count(cond)
    }

    public func clearCache(): Unit {
        table(defaultTableName).clearCache()
    }
}
