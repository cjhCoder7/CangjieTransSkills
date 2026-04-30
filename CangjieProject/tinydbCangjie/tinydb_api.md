## 公共 API 清单

| 源签名 (Python) | 仓颉目标签名 | 备注 |
|--------|-------------|------|
| `TinyDB(storage, default_table)` | `TinyDB(storage: Storage)` | 无默认 storage 参数 |
| `TinyDB.table(name, cache_size)` | `TinyDB.table(name: String, cacheSize!: Int64)` | |
| `TinyDB.tables()` | `TinyDB.tables(): HashSet<String>` | 返回 HashSet |
| `TinyDB.drop_tables()` | `TinyDB.dropTables(): Unit` | |
| `TinyDB.drop_table(name)` | `TinyDB.dropTable(name: String): Unit` | |
| `TinyDB.close()` | `TinyDB.close(): Unit` | |
| `TinyDB.storage` | `TinyDB.storage: Storage` | prop |
| `TinyDB.insert(doc)` | `TinyDB.insert(document: HashMap<String, Any>): Int64` | |
| `TinyDB.insert_multiple(docs)` | `TinyDB.insertMultiple(documents: Array<HashMap<String, Any>>): Array<Int64>` | |
| `TinyDB.all()` | `TinyDB.all(): Array<Document>` | |
| `TinyDB.search(cond)` | `TinyDB.search(cond: QueryInstance): Array<Document>` | |
| `TinyDB.get(cond, doc_id, doc_ids)` | `TinyDB.get(cond: ?QueryInstance, docId: ?Int64, docIds: ?Array<Int64>): ?Any` | 无默认值，需显式传参 |
| `TinyDB.contains(cond, doc_id)` | `TinyDB.contains(cond: ?QueryInstance, docId: ?Int64): Bool` | |
| `TinyDB.update(fields, cond, doc_ids)` | `TinyDB.update(fields: Any, cond: ?QueryInstance, docIds: ?Array<Int64>): Array<Int64>` | fields 可传 HashMap 或函数 |
| `TinyDB.upsert(doc, cond)` | `TinyDB.upsert(document: HashMap<String, Any>, cond: ?QueryInstance): Array<Int64>` | |
| `TinyDB.remove(cond, doc_ids)` | `TinyDB.remove(cond: ?QueryInstance, docIds: ?Array<Int64>): Array<Int64>` | |
| `TinyDB.truncate()` | `TinyDB.truncate(): Unit` | |
| `TinyDB.count(cond)` | `TinyDB.count(cond: QueryInstance): Int64` | |
| `TinyDB.clear_cache()` | `TinyDB.clearCache(): Unit` | |
| `TinyDB.len()` | `TinyDB.len(): Int64` | |
| `Table(storage, name, cache_size)` | `Table(storage: Storage, name: String, cacheSize!: Int64)` | |
| `Table.insert(doc)` | `Table.insert(document: HashMap<String, Any>): Int64` | |
| `Table.insert(doc)` (Document) | `Table.insertDoc(document: Document): Int64` | |
| `Table.insert_multiple(docs)` | `Table.insertMultiple(documents: Array<HashMap<String, Any>>): Array<Int64>` | |
| `Table.all()` | `Table.all(): Array<Document>` | |
| `Table.search(cond)` | `Table.search(cond: QueryInstance): Array<Document>` | |
| `Table.get(cond, doc_id, doc_ids)` | `Table.get(cond!: ?QueryInstance, docId!: ?Int64, docIds!: ?Array<Int64>): ?Any` | |
| `Table.contains(cond, doc_id)` | `Table.contains(cond!: ?QueryInstance, docId!: ?Int64): Bool` | |
| `Table.update(fields, cond, doc_ids)` | `Table.update(fields: Any, cond!: ?QueryInstance, docIds!: ?Array<Int64>): Array<Int64>` | |
| `Table.upsert(doc, cond)` | `Table.upsert(document: HashMap<String, Any>, cond!: ?QueryInstance): Array<Int64>` | |
| `Table.remove(cond, doc_ids)` | `Table.remove(cond!: ?QueryInstance, docIds!: ?Array<Int64>): Array<Int64>` | |
| `Table.truncate()` | `Table.truncate(): Unit` | |
| `Table.count(cond)` | `Table.count(cond: QueryInstance): Int64` | |
| `Table.clear_cache()` | `Table.clearCache(): Unit` | |
| `Table.len()` | `Table.len(): Int64` | |
| `Document(data, doc_id)` | `Document(data: HashMap<String, Any>, docId: Int64)` | |
| `Document.get(key)` | `Document.get(key: String): ?Any` | |
| `Document.set(key, value)` | `Document.set(key: String, value: Any): Unit` | |
| `Document.contains(key)` | `Document.contains(key: String): Bool` | |
| `Document.keys()` | `Document.keys(): Array<String>` | |
| `Document.to_map()` | `Document.toMap(): HashMap<String, Any>` | |
| `Query()` | `Query()` | |
| `Query.field(name)` | `Query.field(name: String): Query` | |
| `Query.eq(rhs)` | `Query.eq(rhs: Any): QueryInstance` | |
| `Query.ne(rhs)` | `Query.ne(rhs: Any): QueryInstance` | |
| `Query.lt(rhs)` | `Query.lt(rhs: Any): QueryInstance` | |
| `Query.le(rhs)` | `Query.le(rhs: Any): QueryInstance` | |
| `Query.gt(rhs)` | `Query.gt(rhs: Any): QueryInstance` | |
| `Query.ge(rhs)` | `Query.ge(rhs: Any): QueryInstance` | |
| `Query.exists()` | `Query.exists(): QueryInstance` | |
| `Query.matches(regex)` | `Query.matches(regex: String): QueryInstance` | |
| `Query.search(regex)` | `Query.search(regex: String): QueryInstance` | |
| `Query.test(fn)` | `Query.test(fn: (Any) -> Bool): QueryInstance` | |
| `Query.any_of(cond)` | `Query.anyOf(cond: QueryInstance): QueryInstance` | |
| `Query.all_of(cond)` | `Query.allOf(cond: QueryInstance): QueryInstance` | |
| `Query.one_of(items)` | `Query.oneOf(items: Array<Any>): QueryInstance` | |
| `Query.fragment(doc)` | `Query.fragment(document: HashMap<String, Any>): QueryInstance` | |
| `Query.noop()` | `Query.noop(): QueryInstance` | |
| `Query.map(fn)` | `Query.map(_: (Any) -> Any): Query` | |
| `QueryInstance & other` | `QueryInstance.&(other: QueryInstance): QueryInstance` | AND |
| `QueryInstance \| other` | `QueryInstance.\|(other: QueryInstance): QueryInstance` | OR |
| `~QueryInstance` | `!QueryInstance: QueryInstance` | NOT, 仓颉用 `!` 运算符 |
| `where(key)` | `` `where`(key: String): Query `` | `where` 为保留字，需反引号 |
| `Storage` (ABC) | `Storage` (interface) | |
| `JSONStorage(path)` | `JSONStorage(path: String, createDirs!: Bool, accessMode!: String)` | JSON 解析暂未实现 |
| `MemoryStorage()` | `MemoryStorage()` | |
| `Middleware(storage_cls)` | `Middleware(storageCls: () -> Storage)` | |
| `CachingMiddleware(storage_cls)` | `CachingMiddleware(storageCls: () -> Storage)` | |
| `delete(field)` | `delete(field: String): (HashMap<String, Any>) -> Unit` | |
| `add(field, n)` | `add(field: String, n: Int64): (HashMap<String, Any>) -> Unit` | |
| `subtract(field, n)` | `subtract(field: String, n: Int64): (HashMap<String, Any>) -> Unit` | |
| `set(field, val)` | `set(field: String, val: Any): (HashMap<String, Any>) -> Unit` | |
| `increment(field)` | `increment(field: String): (HashMap<String, Any>) -> Unit` | |
| `decrement(field)` | `decrement(field: String): (HashMap<String, Any>) -> Unit` | |
| `LRUCache(capacity)` | `LRUCache<K, V>(capacity!: ?Int64)` | K 须 <: Equatable<K> |
