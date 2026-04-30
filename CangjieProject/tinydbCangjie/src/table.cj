package tinydb

import std.collection.*
import std.convert.*

// 文档：包含数据和文档 ID
public open class Document {
    var data: HashMap<String, Any>
    public var docId: Int64

    public init(data: HashMap<String, Any>, docId: Int64) {
        this.data = data
        this.docId = docId
    }

    public func get(key: String): ?Any {
        data.get(key)
    }

    public func set(key: String, value: Any): Unit {
        data[key] = value
    }

    public func contains(key: String): Bool {
        data.contains(key)
    }

    public func keys(): Array<String> {
        let result = ArrayList<String>()
        for ((k, _) in data) {
            result.add(k)
        }
        return result.toArray()
    }

    public func toMap(): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        for ((k, v) in data) {
            result[k] = v
        }
        return result
    }

    public func toString(): String {
        "Document(docId=${docId})"
    }
}

// 表：核心数据操作类
public open class Table {
    var _storage: Storage
    var _name: String
    var _queryCache: LRUCache<QueryInstance, Array<Document>>
    var _nextId: ?Int64 = None<Int64>

    public static let defaultQueryCacheCapacity: Int64 = 10

    public init(storage: Storage, name: String, cacheSize!: Int64 = defaultQueryCacheCapacity, persistEmpty!: Bool = false) {
        this._storage = storage
        this._name = name
        this._queryCache = LRUCache<QueryInstance, Array<Document>>(capacity: cacheSize)
        if (persistEmpty) {
            // 在构造函数中不能调用实例方法，直接操作存储
            var tablesOpt = _storage.read()
            if (let None <- tablesOpt) {
                tablesOpt = HashMap<String, HashMap<String, HashMap<String, Any>>>()
            }
            if (let Some(tables) <- tablesOpt) {
                if (!tables.contains(name)) {
                    tables[name] = HashMap<String, HashMap<String, Any>>()
                }
                _storage.write(tables)
            }
        }
    }

    public prop name: String {
        get() { _name }
    }

    public prop storage: Storage {
        get() { _storage }
    }

    // 插入文档
    public func insert(document: HashMap<String, Any>): Int64 {
        let docId = _getNextId()
        let capturedDocId = docId
        _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
            if (table.contains("${capturedDocId}")) {
                throw Exception("Document with ID ${capturedDocId} already exists")
            }
            let docCopy = HashMap<String, Any>()
            for ((k, v) in document) {
                docCopy[k] = v
            }
            table["${capturedDocId}"] = docCopy
        })
        return docId
    }

    // 插入 Document 对象
    public func insertDoc(document: Document): Int64 {
        let docId = document.docId
        _nextId = None<Int64>
        _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
            if (table.contains("${docId}")) {
                throw Exception("Document with ID ${docId} already exists")
            }
            let docCopy = HashMap<String, Any>()
            for ((k, v) in document.data) {
                docCopy[k] = v
            }
            table["${docId}"] = docCopy
        })
        return docId
    }

    // 批量插入
    public func insertMultiple(documents: Array<HashMap<String, Any>>): Array<Int64> {
        let docIds = ArrayList<Int64>()
        _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
            for (document in documents) {
                let docId = _getNextId()
                docIds.add(docId)
                let docCopy = HashMap<String, Any>()
                for ((k, v) in document) {
                    docCopy[k] = v
                }
                table["${docId}"] = docCopy
            }
        })
        return docIds.toArray()
    }

    // 获取所有文档
    public func all(): Array<Document> {
        let result = ArrayList<Document>()
        let table = _readTable()
        for ((docIdStr, doc) in table) {
            if (let Some(docId) <- Int64.tryParse(docIdStr)) {
                result.add(Document(_copyMap(doc), docId))
            }
        }
        return result.toArray()
    }

    // 搜索文档
    public func search(cond: QueryInstance): Array<Document> {
        if (let Some(cached) <- _queryCache.get(cond)) {
            let result = ArrayList<Document>()
            for (doc in cached) {
                result.add(doc)
            }
            return result.toArray()
        }

        let docs = ArrayList<Document>()
        let table = _readTable()
        for ((docIdStr, doc) in table) {
            if (cond.call(doc)) {
                if (let Some(docId) <- Int64.tryParse(docIdStr)) {
                    docs.add(Document(_copyMap(doc), docId))
                }
            }
        }

        let result = docs.toArray()
        if (cond.isCacheable()) {
            _queryCache.set(cond, result)
        }
        return result
    }

    // 获取单个文档
    public func get(cond!: ?QueryInstance, docId!: ?Int64, docIds!: ?Array<Int64>): ?Any {
        let table = _readTable()

        if (let Some(id) <- docId) {
            if (let Some(doc) <- table.get("${id}")) {
                return Document(_copyMap(doc), id)
            }
            return None<Any>
        }

        if (let Some(ids) <- docIds) {
            let idsSet = HashSet<String>()
            for (id in ids) {
                idsSet.add("${id}")
            }
            let result = ArrayList<Document>()
            for ((docIdStr, doc) in table) {
                if (idsSet.contains(docIdStr)) {
                    if (let Some(did) <- Int64.tryParse(docIdStr)) {
                        result.add(Document(_copyMap(doc), did))
                    }
                }
            }
            return result.toArray()
        }

        if (let Some(c) <- cond) {
            for ((docIdStr, doc) in table) {
                if (c.call(doc)) {
                    if (let Some(did) <- Int64.tryParse(docIdStr)) {
                        return Document(_copyMap(doc), did)
                    }
                }
            }
            return None<Any>
        }

        throw Exception("You have to pass either cond or docId or docIds")
    }

    // 检查是否包含
    public func contains(cond!: ?QueryInstance, docId!: ?Int64): Bool {
        if (let Some(id) <- docId) {
            let result = get(cond: None<QueryInstance>, docId: id, docIds: None<Array<Int64>>)
            if (let Some(_) <- result) { return true } else { return false }
        }

        if (let Some(c) <- cond) {
            let result = get(cond: c, docId: None<Int64>, docIds: None<Array<Int64>>)
            if (let Some(_) <- result) { return true } else { return false }
        }

        throw Exception("You have to pass either cond or docId")
    }

    // 更新文档
    public func update(
        fields: Any,
        cond!: ?QueryInstance,
        docIds!: ?Array<Int64>
    ): Array<Int64> {
        let updatedIds = ArrayList<Int64>()

        if (let Some(ids) <- docIds) {
            for (id in ids) {
                updatedIds.add(id)
            }
            let capturedIds = updatedIds.toArray()
            let capturedFields = fields

            _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
                for (docId in capturedIds) {
                    _performUpdate(capturedFields, table, "${docId}")
                }
            })
            return capturedIds
        }

        if (let Some(c) <- cond) {
            _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
                let keys = ArrayList<String>()
                for ((k, _) in table) {
                    keys.add(k)
                }
                for (docIdStr in keys) {
                    if (table.contains(docIdStr)) {
                        if (let Some(doc) <- table.get(docIdStr)) {
                            if (c.call(doc)) {
                                if (let Some(id) <- Int64.tryParse(docIdStr)) {
                                    updatedIds.add(id)
                                }
                                _performUpdate(fields, table, docIdStr)
                            }
                        }
                    }
                }
            })
            return updatedIds.toArray()
        }

        // 更新所有文档
        _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
            let keys = ArrayList<String>()
            for ((k, _) in table) {
                keys.add(k)
            }
            for (docIdStr in keys) {
                if (let Some(id) <- Int64.tryParse(docIdStr)) {
                    updatedIds.add(id)
                }
                _performUpdate(fields, table, docIdStr)
            }
        })
        return updatedIds.toArray()
    }

    // upsert：存在则更新，否则插入
    public func upsert(document: HashMap<String, Any>, cond!: ?QueryInstance): Array<Int64> {
        var docIds: ?Array<Int64> = None<Array<Int64>>

        if (let Some(d) <- (document as Document)) {
            docIds = [d.docId]
        }

        if (docIds == None<Array<Int64>> && cond == None<QueryInstance>) {
            throw Exception("If you don't specify a search query, you must specify a doc_id")
        }

        try {
            let updated = update(document, cond: cond, docIds: docIds)
            if (updated.size > 0) {
                return updated
            }
        } catch (_: Exception) {}

        return [insert(document)]
    }

    // 删除文档
    public func remove(cond!: ?QueryInstance, docIds!: ?Array<Int64>): Array<Int64> {
        if (let Some(ids) <- docIds) {
            let removedIds = ArrayList<Int64>()
            for (id in ids) {
                removedIds.add(id)
            }
            let capturedIds = removedIds.toArray()
            _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
                for (docId in capturedIds) {
                    table.remove("${docId}")
                }
            })
            return capturedIds
        }

        if (let Some(c) <- cond) {
            let removedIds = ArrayList<Int64>()
            _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
                let keys = ArrayList<String>()
                for ((k, _) in table) {
                    keys.add(k)
                }
                for (docIdStr in keys) {
                    if (table.contains(docIdStr)) {
                        if (let Some(doc) <- table.get(docIdStr)) {
                            if (c.call(doc)) {
                                if (let Some(id) <- Int64.tryParse(docIdStr)) {
                                    removedIds.add(id)
                                }
                                table.remove(docIdStr)
                            }
                        }
                    }
                }
            })
            return removedIds.toArray()
        }

        throw Exception("Use truncate() to remove all documents")
    }

    // 批量多条件更新
    public func updateMultiple(updates: Array<(Any, QueryInstance)>): Array<Int64> {
        let updatedIds = ArrayList<Int64>()
        _updateTable({ table: HashMap<String, HashMap<String, Any>> =>
            let keys = ArrayList<String>()
            for ((k, _) in table) {
                keys.add(k)
            }
            for (docIdStr in keys) {
                if (table.contains(docIdStr)) {
                    if (let Some(doc) <- table.get(docIdStr)) {
                        for ((fields, cond) in updates) {
                            if (cond.call(doc)) {
                                if (let Some(id) <- Int64.tryParse(docIdStr)) {
                                    updatedIds.add(id)
                                }
                                _performUpdate(fields, table, docIdStr)
                            }
                        }
                    }
                }
            }
        })
        return updatedIds.toArray()
    }

    // 清空表
    public func truncate(): Unit {
        _updateTable({ table: HashMap<String, HashMap<String, Any>> => table.clear() })
        _nextId = None<Int64>
    }

    // 计数
    public func count(cond: QueryInstance): Int64 {
        Int64(search(cond).size)
    }

    // 清除查询缓存
    public func clearCache(): Unit {
        _queryCache.clear()
    }

    // 获取文档数量
    public func len(): Int64 {
        Int64(_readTable().size)
    }

    // 迭代器支持
    public func iterator(): Iterator<Document> {
        all().iterator()
    }

    public func toString(): String {
        "Table(name=${_name}, docs=${len()})"
    }

    // 获取下一个文档 ID
    func _getNextId(): Int64 {
        if (let Some(nid) <- _nextId) {
            _nextId = nid + 1
            return nid
        }

        let table = _readTable()
        if (table.size == 0) {
            let nextId: Int64 = 1
            _nextId = nextId + 1
            return nextId
        }

        var maxId: Int64 = 0
        for (docIdStr in table.keys()) {
            if (let Some(id) <- Int64.tryParse(docIdStr)) {
                if (id > maxId) {
                    maxId = id
                }
            }
        }
        let nextId = maxId + 1
        _nextId = nextId + 1
        return nextId
    }

    // 读取表数据
    func _readTable(): HashMap<String, HashMap<String, Any>> {
        if (let Some(tables) <- _storage.read()) {
            if (tables.contains(_name)) {
                return tables[_name]
            }
        }
        return HashMap<String, HashMap<String, Any>>()
    }

    // 更新表数据
    func _updateTable(updater: (HashMap<String, HashMap<String, Any>>) -> Unit): Unit {
        var tablesOpt = _storage.read()
        if (let None <- tablesOpt) {
            tablesOpt = HashMap<String, HashMap<String, HashMap<String, Any>>>()
        }

        if (let Some(tables) <- tablesOpt) {
            var table = HashMap<String, HashMap<String, Any>>()
            if (tables.contains(_name)) {
                table = tables[_name]
            }

            updater(table)

            tables[_name] = table
            _storage.write(tables)
        }

        clearCache()
    }

    // 执行更新操作
    func _performUpdate(fields: Any, table: HashMap<String, HashMap<String, Any>>, docIdStr: String): Unit {
        if (let Some(updateMap) <- (fields as HashMap<String, Any>)) {
            if (let Some(doc) <- table.get(docIdStr)) {
                for ((k, v) in updateMap) {
                    doc[k] = v
                }
            }
        } else if (let Some(fn) <- (fields as (HashMap<String, Any>) -> Unit)) {
            if (let Some(doc) <- table.get(docIdStr)) {
                fn(doc)
            }
        }
    }

    func _copyMap(map: HashMap<String, Any>): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        for ((k, v) in map) {
            result[k] = v
        }
        return result
    }
}
