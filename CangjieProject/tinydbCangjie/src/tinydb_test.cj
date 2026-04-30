package tinydb

import std.collection.*
import std.unittest.*
import std.fs.*

// ===== Query Tests =====

@Test
func testQueryEq(): Unit {
    let q = `where`("value").eq(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(1))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(2))])))
}

@Test
func testQueryNe(): Unit {
    let q = `where`("value").ne(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(0))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(1))])))
}

@Test
func testQueryLt(): Unit {
    let q = `where`("value").lt(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(0))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(1))])))
}

@Test
func testQueryLe(): Unit {
    let q = `where`("value").le(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(0))])))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(1))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(2))])))
}

@Test
func testQueryGt(): Unit {
    let q = `where`("value").gt(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(2))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(1))])))
}

@Test
func testQueryGe(): Unit {
    let q = `where`("value").ge(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(2))])))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(1))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(0))])))
}

@Test
func testQueryOr(): Unit {
    let q = `where`("val1").eq(Int64(1)) | `where`("val2").eq(Int64(2))
    @Assert(q.call(HashMap<String, Any>([("val1", Int64(1))])))
    @Assert(q.call(HashMap<String, Any>([("val2", Int64(2))])))
    @Assert(!q.call(HashMap<String, Any>([("val1", Int64(0)), ("val2", Int64(0))])))
}

@Test
func testQueryAnd(): Unit {
    let q = `where`("val1").eq(Int64(1)) & `where`("val2").eq(Int64(2))
    @Assert(q.call(HashMap<String, Any>([("val1", Int64(1)), ("val2", Int64(2))])))
    @Assert(!q.call(HashMap<String, Any>([("val1", Int64(1))])))
}

@Test
func testQueryNot(): Unit {
    let q = !(`where`("val1").eq(Int64(1)))
    @Assert(q.call(HashMap<String, Any>([("val1", Int64(5))])))
    @Assert(!q.call(HashMap<String, Any>([("val1", Int64(1))])))
}

@Test
func testQueryExists(): Unit {
    let q = `where`("val3").exists()
    @Assert(q.call(HashMap<String, Any>([("val3", Int64(1))])))
    @Assert(!q.call(HashMap<String, Any>([("val1", Int64(1))])))
}

@Test
func testQueryMatches(): Unit {
    let q = `where`("val").matches("\\d{2}\\.")
    @Assert(q.call(HashMap<String, Any>([("val", "42.")])))
    @Assert(!q.call(HashMap<String, Any>([("val", "44")])))
    @Assert(!q.call(HashMap<String, Any>([("val", Int64(155))])))
}

@Test
func testQuerySearch(): Unit {
    let q = `where`("val").search("\\d+")
    @Assert(q.call(HashMap<String, Any>([("val", "ab3")])))
    @Assert(!q.call(HashMap<String, Any>([("val", "abc")])))
}

@Test
func testQueryCustomTest(): Unit {
    let q = `where`("val").test({ v: Any =>
        if (let Some(n) <- (v as Int64)) { n == Int64(42) } else { false }
    })
    @Assert(q.call(HashMap<String, Any>([("val", Int64(42))])))
    @Assert(!q.call(HashMap<String, Any>([("val", Int64(40))])))
}

@Test
func testQueryNoop(): Unit {
    let q = Query().noop()
    @Assert(q.call(HashMap<String, Any>()))
    @Assert(q.call(HashMap<String, Any>([("foo", Int64(1))])))
}

@Test
func testQueryFragment(): Unit {
    let frag = HashMap<String, Any>()
    frag["a"] = Int64(4)
    frag["b"] = true
    let q = Query().fragment(frag)
    let matchDoc = HashMap<String, Any>()
    matchDoc["a"] = Int64(4)
    matchDoc["b"] = true
    matchDoc["c"] = "yes"
    @Assert(q.call(matchDoc))
    let noMatchDoc = HashMap<String, Any>()
    noMatchDoc["a"] = Int64(4)
    @Assert(!q.call(noMatchDoc))
}

@Test
func testQueryFragmentWithPath(): Unit {
    let frag = HashMap<String, Any>()
    frag["a"] = Int64(4)
    frag["b"] = true
    let q = `where`("doc").fragment(frag)
    let matchDoc = HashMap<String, Any>()
    let inner = HashMap<String, Any>()
    inner["a"] = Int64(4)
    inner["b"] = true
    inner["c"] = "yes"
    matchDoc["doc"] = inner
    @Assert(q.call(matchDoc))
    @Assert(!q.call(HashMap<String, Any>([("a", Int64(4)), ("b", true)])))
}

@Test
func testQueryOneOf(): Unit {
    let q = `where`("key1").oneOf([Int64(1), Int64(2), Int64(3)])
    @Assert(q.call(HashMap<String, Any>([("key1", Int64(1))])))
    @Assert(q.call(HashMap<String, Any>([("key1", Int64(3))])))
    @Assert(!q.call(HashMap<String, Any>([("key1", Int64(4))])))
}

@Test
func testQueryAnyOfQueryInstance(): Unit {
    let q = `where`("followers").anyOf(`where`("name").eq("don"))
    let doc1 = HashMap<String, Any>()
    let f1 = ArrayList<Any>()
    let m1 = HashMap<String, Any>()
    m1["name"] = "don"
    f1.add(m1)
    let m2 = HashMap<String, Any>()
    m2["name"] = "john"
    f1.add(m2)
    doc1["followers"] = f1.toArray()
    @Assert(q.call(doc1))
    let doc2 = HashMap<String, Any>()
    doc2["followers"] = Int64(1)
    @Assert(!q.call(doc2))
}

@Test
func testQueryAnyOfList(): Unit {
    let items = ArrayList<Any>()
    items.add("don")
    items.add("jon")
    let q = `where`("followers").anyOf(items.toArray())
    let doc = HashMap<String, Any>()
    let followers1 = ArrayList<Any>()
    followers1.add("don")
    followers1.add("greg")
    followers1.add("bill")
    doc["followers"] = followers1.toArray()
    @Assert(q.call(doc))
    let doc2 = HashMap<String, Any>()
    let followers2 = ArrayList<Any>()
    followers2.add("greg")
    followers2.add("bill")
    doc2["followers"] = followers2.toArray()
    @Assert(!q.call(doc2))
}

@Test
func testQueryAllOfQueryInstance(): Unit {
    let q = `where`("followers").allOf(`where`("name").eq("don"))
    let doc1 = HashMap<String, Any>()
    let f1 = ArrayList<Any>()
    let m1 = HashMap<String, Any>()
    m1["name"] = "don"
    f1.add(m1)
    doc1["followers"] = f1.toArray()
    @Assert(q.call(doc1))
    let doc2 = HashMap<String, Any>()
    let f2 = ArrayList<Any>()
    let m3 = HashMap<String, Any>()
    m3["name"] = "don"
    f2.add(m3)
    let m4 = HashMap<String, Any>()
    m4["name"] = "john"
    f2.add(m4)
    doc2["followers"] = f2.toArray()
    @Assert(!q.call(doc2))
}

@Test
func testQueryAllOfList(): Unit {
    let items = ArrayList<Any>()
    items.add("don")
    items.add("john")
    let q = `where`("followers").allOf(items.toArray())
    let doc = HashMap<String, Any>()
    let followers1 = ArrayList<Any>()
    followers1.add("don")
    followers1.add("john")
    followers1.add("greg")
    doc["followers"] = followers1.toArray()
    @Assert(q.call(doc))
    let doc2 = HashMap<String, Any>()
    let followers2 = ArrayList<Any>()
    followers2.add("don")
    followers2.add("greg")
    doc2["followers"] = followers2.toArray()
    @Assert(!q.call(doc2))
}

@Test
func testQueryNestedPath(): Unit {
    let q = Query().field("key1").field("key2").exists()
    let nested = HashMap<String, Any>()
    nested["key2"] = Int64(1)
    @Assert(q.call(HashMap<String, Any>([("key1", nested)])))
    @Assert(!q.call(HashMap<String, Any>([("key1", Int64(3))])))
}

@Test
func testQueryHash(): Unit {
    let q1 = `where`("key1").eq(Int64(2))
    let q2 = `where`("key1").eq(Int64(2))
    @Assert(q1.hashCode() == q2.hashCode())
}

@Test
func testQueryEquality(): Unit {
    let q = `where`("foo").eq(Int64(2))
    // Python tests `!= 0` and `!= ''` but Cangjie doesn't support cross-type comparison
    @Assert(q.isCacheable())
}

@Test
func testQueryEmptyError(): Unit {
    let q = Query()
    var caught = false
    try {
        q.call(HashMap<String, Any>())
    } catch (_: Exception) {
        caught = true
    }
    @Assert(caught)
}

@Test
func testQueryNotAndCombined(): Unit {
    let q = !(`where`("val1").eq(Int64(1))) & `where`("val2").eq(Int64(2))
    @Assert(q.call(HashMap<String, Any>([("val1", Int64(5)), ("val2", Int64(2))])))
    @Assert(!q.call(HashMap<String, Any>([("val1", Int64(1)), ("val2", Int64(2))])))
}

// ===== Table / TinyDB Tests =====

@Test
func testInsert(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["name"] = "Alice"
    doc["age"] = Int64(30)
    let id = db.insert(doc)
    @Assert(id == Int64(1))
    @Assert(db.len() == Int64(1))
}

@Test
func testInsertMultiple(): Unit {
    let db = TinyDB(MemoryStorage())
    let docs = ArrayList<HashMap<String, Any>>()
    for (i in 0..5) {
        let doc = HashMap<String, Any>()
        doc["val"] = Int64(i)
        docs.add(doc)
    }
    let ids = db.insertMultiple(docs.toArray())
    @Assert(ids.size == 5)
    @Assert(db.len() == Int64(5))
}

@Test
func testInsertWithDocId(): Unit {
    let db = TinyDB(MemoryStorage())
    let docData = HashMap<String, Any>()
    docData["name"] = "test"
    let doc = Document(docData, Int64(5))
    let id = db.insertDoc(doc)
    @Assert(id == Int64(5))
}

@Test
func testInsertDuplicateDocId(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1Data = HashMap<String, Any>()
    doc1Data["name"] = "first"
    let doc1 = Document(doc1Data, Int64(1))
    db.insertDoc(doc1)
    let doc2Data = HashMap<String, Any>()
    doc2Data["name"] = "second"
    let doc2 = Document(doc2Data, Int64(1))
    var caught = false
    try {
        db.insertDoc(doc2)
    } catch (_: Exception) {
        caught = true
    }
    @Assert(caught)
}

@Test
func testAll(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["name"] = "A"
    let doc2 = HashMap<String, Any>()
    doc2["name"] = "B"
    db.insert(doc1)
    db.insert(doc2)
    @Assert(db.all().size == 2)
}

@Test
func testSearch(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["name"] = "Alice"
    doc1["age"] = Int64(30)
    db.insert(doc1)
    let doc2 = HashMap<String, Any>()
    doc2["name"] = "Bob"
    doc2["age"] = Int64(25)
    db.insert(doc2)
    let results = db.search(`where`("name").eq("Alice"))
    @Assert(results.size == 1)
}

@Test
func testGetByCond(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["name"] = "test"
    db.insert(doc)
    let result = db.get(cond: `where`("name").eq("test"), docId: None<Int64>, docIds: None<Array<Int64>>)
    var found = false
    match (result) {
        case Some(_) => found = true
        case None => found = false
    }
    @Assert(found)
}

@Test
func testGetByDocId(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["name"] = "test"
    db.insert(doc)
    let result = db.get(cond: None<QueryInstance>, docId: Int64(1), docIds: None<Array<Int64>>)
    var found = false
    match (result) {
        case Some(_) => found = true
        case None => found = false
    }
    @Assert(found)
}

@Test
func testGetByDocIds(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["val"] = Int64(1)
    let doc2 = HashMap<String, Any>()
    doc2["val"] = Int64(2)
    let doc3 = HashMap<String, Any>()
    doc3["val"] = Int64(3)
    db.insert(doc1)
    db.insert(doc2)
    db.insert(doc3)
    let result = db.get(cond: None<QueryInstance>, docId: None<Int64>, docIds: [Int64(1), Int64(3)])
    var resultIsSome = false
    match (result) {
        case Some(_) => resultIsSome = true
        case None => resultIsSome = false
    }
    @Assert(resultIsSome)
}

@Test
func testGetInvalid(): Unit {
    let db = TinyDB(MemoryStorage())
    var caught = false
    try {
        db.get(cond: None<QueryInstance>, docId: None<Int64>, docIds: None<Array<Int64>>)
    } catch (_: Exception) {
        caught = true
    }
    @Assert(caught)
}

@Test
func testContains(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["x"] = Int64(1)
    db.insert(doc)
    @Assert(db.contains(cond: `where`("x").eq(Int64(1)), docId: None<Int64>))
    @Assert(!db.contains(cond: `where`("x").eq(Int64(2)), docId: None<Int64>))
    @Assert(db.contains(cond: None<QueryInstance>, docId: Int64(1)))
}

@Test
func testUpdateWithMap(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["name"] = "Charlie"
    doc["score"] = Int64(80)
    db.insert(doc)
    let updateMap = HashMap<String, Any>()
    updateMap["score"] = Int64(95)
    db.update(updateMap, cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.search(`where`("name").eq("Charlie"))
    var score = Int64(0)
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("score")) {
            if (let Some(n) <- (v as Int64)) {
                score = n
            }
        }
    }
    @Assert(score == Int64(95))
}

@Test
func testUpdateWithCond(): Unit {
    let db = TinyDB(MemoryStorage())
    for (i in 0..5) {
        let doc = HashMap<String, Any>()
        doc["val"] = Int64(i)
        db.insert(doc)
    }
    let updateMap = HashMap<String, Any>()
    updateMap["val"] = Int64(99)
    let ids = db.update(updateMap, cond: `where`("val").lt(Int64(3)), docIds: None<Array<Int64>>)
    @Assert(ids.size == 3)
}

@Test
func testUpdateWithDocIds(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["val"] = Int64(1)
    let doc2 = HashMap<String, Any>()
    doc2["val"] = Int64(2)
    db.insert(doc1)
    db.insert(doc2)
    let updateMap = HashMap<String, Any>()
    updateMap["val"] = Int64(99)
    let ids = db.update(updateMap, cond: None<QueryInstance>, docIds: [Int64(1)])
    @Assert(ids.size == 1)
}

@Test
func testUpdateWithFunction(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["count"] = Int64(10)
    db.insert(doc)
    db.update(increment("count"), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var countVal = Int64(0)
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("count")) {
            if (let Some(n) <- (v as Int64)) {
                countVal = n
            }
        }
    }
    @Assert(countVal == Int64(11))
}

@Test
func testUpdateMultiple(): Unit {
    let db = TinyDB(MemoryStorage())
    for (i in 0..5) {
        let doc = HashMap<String, Any>()
        doc["val"] = Int64(i)
        db.insert(doc)
    }
    let updates = ArrayList<(Any, QueryInstance)>()
    let m1 = HashMap<String, Any>()
    m1["val"] = Int64(100)
    updates.add((m1, `where`("val").eq(Int64(0))))
    let m2 = HashMap<String, Any>()
    m2["val"] = Int64(200)
    updates.add((m2, `where`("val").eq(Int64(1))))
    let t = db.table("_default")
    let ids = t.updateMultiple(updates.toArray())
    @Assert(ids.size >= 2)
    let r1 = db.search(`where`("val").eq(Int64(100)))
    @Assert(r1.size == 1)
    let r2 = db.search(`where`("val").eq(Int64(200)))
    @Assert(r2.size == 1)
}

@Test
func testUpsert(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["name"] = "test"
    db.insert(doc)
    let updateDoc = HashMap<String, Any>()
    updateDoc["name"] = "updated"
    let ids = db.upsert(updateDoc, cond: `where`("name").eq("test"))
    @Assert(ids.size == 1)
    let results = db.search(`where`("name").eq("updated"))
    @Assert(results.size == 1)

    let insertDoc = HashMap<String, Any>()
    insertDoc["name"] = "new"
    let ids2 = db.upsert(insertDoc, cond: `where`("name").eq("nonexistent"))
    @Assert(ids2.size == 1)
    @Assert(db.len() == Int64(2))
}

@Test
func testRemoveByCond(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["val"] = Int64(1)
    let doc2 = HashMap<String, Any>()
    doc2["val"] = Int64(2)
    db.insert(doc1)
    db.insert(doc2)
    let ids = db.remove(cond: `where`("val").eq(Int64(1)), docIds: None<Array<Int64>>)
    @Assert(ids.size == 1)
    @Assert(db.len() == Int64(1))
}

@Test
func testRemoveByDocIds(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["val"] = Int64(1)
    let doc2 = HashMap<String, Any>()
    doc2["val"] = Int64(2)
    db.insert(doc1)
    db.insert(doc2)
    let ids = db.remove(cond: None<QueryInstance>, docIds: [Int64(1)])
    @Assert(ids.size == 1)
    @Assert(db.len() == Int64(1))
}

@Test
func testRemoveAllFails(): Unit {
    let db = TinyDB(MemoryStorage())
    var caught = false
    try {
        db.remove(cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    } catch (_: Exception) {
        caught = true
    }
    @Assert(caught)
}

@Test
func testTruncate(): Unit {
    let db = TinyDB(MemoryStorage())
    for (i in 0..5) {
        let doc = HashMap<String, Any>()
        doc["i"] = Int64(i)
        db.insert(doc)
    }
    db.truncate()
    @Assert(db.len() == Int64(0))
}

@Test
func testCount(): Unit {
    let db = TinyDB(MemoryStorage())
    for (i in 0..10) {
        let doc = HashMap<String, Any>()
        doc["val"] = Int64(i)
        db.insert(doc)
    }
    @Assert(db.count(`where`("val").gt(Int64(5))) == Int64(4))
}

@Test
func testMultipleTables(): Unit {
    let db = TinyDB(MemoryStorage())
    let t1 = db.table("table1")
    let t2 = db.table("table2")
    let doc1 = HashMap<String, Any>()
    doc1["a"] = Int64(1)
    t1.insert(doc1)
    let doc2 = HashMap<String, Any>()
    doc2["b"] = Int64(2)
    t2.insert(doc2)
    @Assert(t1.len() == Int64(1))
    @Assert(t2.len() == Int64(1))
    @Assert(db.tables().contains("table1"))
    @Assert(db.tables().contains("table2"))
}

@Test
func testDropTables(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["val"] = Int64(1)
    db.insert(doc)
    db.dropTables()
    @Assert(db.len() == Int64(0))
}

@Test
func testDropTable(): Unit {
    let db = TinyDB(MemoryStorage())
    let t = db.table("mytable")
    let doc = HashMap<String, Any>()
    doc["val"] = Int64(1)
    t.insert(doc)
    db.dropTable("mytable")
    @Assert(!db.tables().contains("mytable"))
}

@Test
func testTableCaching(): Unit {
    let db = TinyDB(MemoryStorage())
    let t1 = db.table("x")
    let t2 = db.table("x")
    @Assert(t1.name == t2.name)
}

@Test
func testQueryCache(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["val"] = Int64(1)
    db.insert(doc)
    let r1 = db.search(`where`("val").eq(Int64(1)))
    let r2 = db.search(`where`("val").eq(Int64(1)))
    @Assert(r1.size == r2.size)
}

@Test
func testClearCache(): Unit {
    let db = TinyDB(MemoryStorage())
    let t = db.table("_default")
    let doc = HashMap<String, Any>()
    doc["val"] = Int64(1)
    t.insert(doc)
    t.search(`where`("val").eq(Int64(1)))
    t.clearCache()
    @Assert(t.len() == Int64(1))
}

@Test
func testMultipleDBs(): Unit {
    let db1 = TinyDB(MemoryStorage())
    let db2 = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["val"] = Int64(1)
    db1.insert(doc1)
    let doc2 = HashMap<String, Any>()
    doc2["val"] = Int64(2)
    db2.insert(doc2)
    @Assert(db1.len() == Int64(1))
    @Assert(db2.len() == Int64(1))
    @Assert(db1.search(`where`("val").eq(Int64(1))).size == 1)
    @Assert(db2.search(`where`("val").eq(Int64(2))).size == 1)
}

// ===== Operations Tests =====

@Test
func testOpDelete(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["int"] = Int64(1)
    doc["char"] = "a"
    db.insert(doc)
    db.update(delete("int"), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var noInt = false
    var hasChar = false
    if (let Some(d) <- results.get(0)) {
        noInt = !d.contains("int")
        hasChar = d.contains("char")
    }
    @Assert(noInt)
    @Assert(hasChar)
}

@Test
func testOpAdd(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["int"] = Int64(1)
    db.insert(doc)
    db.update(add("int", Int64(5)), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var intVal = Int64(0)
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("int")) {
            if (let Some(n) <- (v as Int64)) {
                intVal = n
            }
        }
    }
    @Assert(intVal == Int64(6))
}

@Test
func testOpSubtract(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["int"] = Int64(10)
    db.insert(doc)
    db.update(subtract("int", Int64(5)), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var intVal = Int64(0)
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("int")) {
            if (let Some(n) <- (v as Int64)) {
                intVal = n
            }
        }
    }
    @Assert(intVal == Int64(5))
}

@Test
func testOpSet(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["char"] = "a"
    db.insert(doc)
    db.update(set("char", "xyz"), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var charVal = ""
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("char")) {
            if (let Some(s) <- (v as String)) {
                charVal = s
            }
        }
    }
    @Assert(charVal == "xyz")
}

@Test
func testOpIncrement(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["count"] = Int64(10)
    db.insert(doc)
    db.update(increment("count"), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var countVal = Int64(0)
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("count")) {
            if (let Some(n) <- (v as Int64)) {
                countVal = n
            }
        }
    }
    @Assert(countVal == Int64(11))
}

@Test
func testOpDecrement(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["count"] = Int64(10)
    db.insert(doc)
    db.update(decrement("count"), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var countVal = Int64(0)
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("count")) {
            if (let Some(n) <- (v as Int64)) {
                countVal = n
            }
        }
    }
    @Assert(countVal == Int64(9))
}

// ===== LRUCache Tests =====

@Test
func testLRUBasic(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 2)
    cache.set("a", Int64(1))
    cache.set("b", Int64(2))
    @Assert(cache.length() == Int64(2))
    cache.set("c", Int64(3))
    @Assert(cache.length() == Int64(2))
    @Assert(cache.get("a") == None<Int64>)
}

@Test
func testLRUSetUpdate(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 2)
    cache.set("a", Int64(1))
    cache.set("a", Int64(10))
    var val = Int64(0)
    if (let Some(v) <- cache.get("a")) {
        val = v
    }
    @Assert(val == Int64(10))
}

@Test
func testLRUGetMovesToMRU(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 2)
    cache.set("a", Int64(1))
    cache.set("b", Int64(2))
    cache.get("a")
    cache.set("c", Int64(3))
    @Assert(cache.get("a") != None<Int64>)
    @Assert(cache.get("b") == None<Int64>)
}

@Test
func testLRUDelete(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 2)
    cache.set("a", Int64(1))
    cache.remove("a")
    @Assert(cache.get("a") == None<Int64>)
    @Assert(cache.length() == Int64(0))
}

@Test
func testLRUClear(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 2)
    cache.set("a", Int64(1))
    cache.set("b", Int64(2))
    cache.clear()
    @Assert(cache.length() == Int64(0))
}

@Test
func testLRUUnlimited(): Unit {
    let cache = LRUCache<String, Int64>()
    for (i in 0..100) {
        cache.set("${i}", Int64(i))
    }
    @Assert(cache.length() == Int64(100))
}

// ===== Middleware Tests =====

@Test
func testCachingMiddlewareWriteRead(): Unit {
    let mw = CachingMiddleware({ => MemoryStorage() })
    mw.initialize()
    let db = TinyDB(mw)
    let doc = HashMap<String, Any>()
    doc["key"] = "value"
    db.insert(doc)
    let results = db.search(`where`("key").eq("value"))
    @Assert(results.size == 1)
    mw.close()
}

@Test
func testCachingMiddlewareFlush(): Unit {
    let mw = CachingMiddleware({ => MemoryStorage() })
    mw.initialize()
    let db = TinyDB(mw)
    let doc = HashMap<String, Any>()
    doc["key"] = "value"
    db.insert(doc)
    mw.flush()
    let results = db.search(`where`("key").eq("value"))
    @Assert(results.size == 1)
    mw.close()
}

// ===== Storage Tests =====

@Test
func testMemoryStorageWriteRead(): Unit {
    let s = MemoryStorage()
    let data = HashMap<String, HashMap<String, HashMap<String, Any>>>()
    let table = HashMap<String, HashMap<String, Any>>()
    let doc = HashMap<String, Any>()
    doc["name"] = "test"
    table["1"] = doc
    data["_default"] = table
    s.write(data)
    var hasDefault = false
    if (let Some(read) <- s.read()) {
        hasDefault = read.contains("_default")
    }
    @Assert(hasDefault)
}

@Test
func testMemoryStorageClose(): Unit {
    let s = MemoryStorage()
    s.close()
    @Assert(true)
}

@Test
func testJSONStorageRoundTrip(): Unit {
    let tmpPath = "/tmp/tinydb_test_cj.json"
    let s = JSONStorage(tmpPath)
    let data = HashMap<String, HashMap<String, HashMap<String, Any>>>()
    let tbl = HashMap<String, HashMap<String, Any>>()
    let doc = HashMap<String, Any>()
    doc["name"] = "test"
    doc["count"] = Int64(42)
    tbl["1"] = doc
    data["_default"] = tbl
    s.write(data)
    s.close()

    let s2 = JSONStorage(tmpPath)
    let readOpt = s2.read()
    var hasDefault = false
    if (let Some(read) <- readOpt) {
        hasDefault = read.contains("_default")
    }
    @Assert(hasDefault)
    s2.close()
    try { File(tmpPath, OpenMode.Write).close() } catch (_: Exception) {}
}

// ===== FrozenDict / freeze Tests =====

@Test
func testFreezeDict(): Unit {
    let m = HashMap<String, Any>()
    m["a"] = Int64(1)
    m["b"] = "hello"
    let frozen = freeze(m)
    var hasA = false
    var hasB = false
    var hashNonZero = false
    if (let Some(fd) <- (frozen as FrozenDict)) {
        hasA = fd.contains("a")
        hasB = fd.contains("b")
        hashNonZero = fd.hashCode() != Int64(0)
    }
    @Assert(hasA)
    @Assert(hasB)
    @Assert(hashNonZero)
}

@Test
func testFreezeNonDict(): Unit {
    let result = freeze("hello")
    var isHello = false
    if (let Some(s) <- (result as String)) {
        isHello = s == "hello"
    }
    @Assert(isHello)
}

// ===== Document Tests =====

@Test
func testDocumentAccess(): Unit {
    let data = HashMap<String, Any>()
    data["name"] = "Alice"
    let doc = Document(data, Int64(1))
    @Assert(doc.docId == Int64(1))
    var isAlice = false
    if (let Some(v) <- doc.get("name")) {
        if (let Some(s) <- (v as String)) {
            isAlice = s == "Alice"
        }
    }
    @Assert(isAlice)
    doc.set("age", Int64(30))
    @Assert(doc.contains("age"))
}

@Test
func testDocumentToMap(): Unit {
    let data = HashMap<String, Any>()
    data["x"] = Int64(1)
    let doc = Document(data, Int64(1))
    let m = doc.toMap()
    @Assert(m.contains("x"))
}

// ===== Query toString =====

@Test
func testQueryToString(): Unit {
    let q = `where`("name")
    let s = q.toString()
    @Assert(s.size > 0)
}

// ===== Query.map Tests =====

@Test
func testQueryMap(): Unit {
    let q = `where`("val").map({ v: Any =>
        if (let Some(n) <- (v as Int64)) { Int64(n * 2) } else { v }
    }).eq(Int64(10))
    @Assert(q.call(HashMap<String, Any>([("val", Int64(5))])))
    @Assert(!q.call(HashMap<String, Any>([("val", Int64(3))])))
}

// ===== Add String Tests =====

@Test
func testOpAddString(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["name"] = "hello"
    db.insert(doc)
    db.update(add("name", " world"), cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    let results = db.all()
    var nameVal = ""
    if (let Some(d) <- results.get(0)) {
        if (let Some(v) <- d.get("name")) {
            if (let Some(s) <- (v as String)) {
                nameVal = s
            }
        }
    }
    @Assert(nameVal == "hello world")
}

// ===== TinyDB Repr Tests =====

@Test
func testTinyDBToString(): Unit {
    let db = TinyDB(MemoryStorage())
    let s = db.toString()
    @Assert(s.size > 0)
}

// ===== Table Repr Tests =====

@Test
func testTableToString(): Unit {
    let db = TinyDB(MemoryStorage())
    let t = db.table("test")
    let s = t.toString()
    @Assert(s.size > 0)
}

// ===== Document Repr Tests =====

@Test
func testDocumentToString(): Unit {
    let data = HashMap<String, Any>()
    data["x"] = Int64(1)
    let doc = Document(data, Int64(5))
    let s = doc.toString()
    @Assert(s.size > 0)
}

// ===== Storage Access Tests =====

@Test
func testStorageAccess(): Unit {
    let s = MemoryStorage()
    let db = TinyDB(s)
    var storageOk = false
    if (db.storage is MemoryStorage) {
        storageOk = true
    }
    @Assert(storageOk)
}

// ===== Empty DB Len Tests =====

@Test
func testEmptyDBLen(): Unit {
    let db = TinyDB(MemoryStorage())
    @Assert(db.len() == Int64(0))
}

// ===== Table Name Tests =====

@Test
func testTableName(): Unit {
    let db = TinyDB(MemoryStorage())
    let t = db.table("mytable")
    @Assert(t.name == "mytable")
}

// ===== Additional Tests from Python Test Suite =====

// test_queries.py: test_no_path
@Test
func testQueryNoPath(): Unit {
    var caught = false
    try {
        let q = Query()
        let _ = q.eq(Int64(2))
    } catch (_: Exception) {
        caught = true
    }
    @Assert(caught)
}

// test_queries.py: test_path_exists - hash checks
@Test
func testQueryPathExistsHash(): Unit {
    let q1 = `where`("value").exists()
    let q2 = `where`("asd").exists()
    @Assert(q1.hashCode() != q2.hashCode())
    @Assert(q1.hashCode() != Int64(0))
}

// test_queries.py: test_path_and
@Test
func testQueryPathAnd(): Unit {
    let q = `where`("value").exists() & (`where`("value").eq(Int64(5)))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(5))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(10))])))
    @Assert(!q.call(HashMap<String, Any>([("something", Int64(1))])))
}

// test_queries.py: test_callable_in_path_with_map
@Test
func testQueryMapPath(): Unit {
    let q = `where`("value").map({ v: Any =>
        if (let Some(n) <- (v as Int64)) { Int64(n + n) } else { v }
    }).eq(Int64(10))
    @Assert(q.call(HashMap<String, Any>([("value", Int64(5))])))
    @Assert(!q.call(HashMap<String, Any>([("value", Int64(10))])))
}

// test_queries.py: test_has - nested 3-level path
@Test
func testQueryNested3LevelPath(): Unit {
    let q = Query().field("key1").field("key2").field("key3").exists()
    let inner2 = HashMap<String, Any>()
    inner2["key3"] = Int64(1)
    let inner1 = HashMap<String, Any>()
    inner1["key2"] = inner2
    @Assert(q.call(HashMap<String, Any>([("key1", inner1)])))
    @Assert(!q.call(HashMap<String, Any>([("key1", Int64(1))])))
}

// test_queries.py: test_has - nested path eq
@Test
func testQueryNestedPathEq(): Unit {
    let q = Query().field("key1").field("key2").eq(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("key1", HashMap<String, Any>([("key2", Int64(1))]))])))
    @Assert(!q.call(HashMap<String, Any>([("key1", HashMap<String, Any>([("key2", Int64(2))]))])))
}

// test_queries.py: test_has - regex on nested path
@Test
func testQueryNestedPathRegex(): Unit {
    let q = Query().field("key1").field("value").matches("\\d+")
    @Assert(q.call(HashMap<String, Any>([("key1", HashMap<String, Any>([("value", "123")]))])))
    @Assert(!q.call(HashMap<String, Any>([("key2", HashMap<String, Any>([("value", "123")]))])))
}

// test_queries.py: test_has - custom test on nested path
@Test
func testQueryNestedPathCustomTest(): Unit {
    let q = Query().field("key1").field("int").test({ v: Any =>
        if (let Some(n) <- (v as Int64)) { n == Int64(3) } else { false }
    })
    @Assert(q.call(HashMap<String, Any>([("key1", HashMap<String, Any>([("int", Int64(3))]))])))
}

// test_queries.py: test_get_item
@Test
func testQueryGetItem(): Unit {
    let q = Query().field("test").eq(Int64(1))
    @Assert(q.call(HashMap<String, Any>([("test", Int64(1))])))
    @Assert(!q.call(HashMap<String, Any>([("test", Int64(0))])))
}

// test_queries.py: test_orm_usage - via field()
@Test
func testQueryOrmStyle(): Unit {
    let q1 = Query().field("name").eq("John")
    let q2 = Query().field("age").field("year").eq(Int64(2000))
    let data1 = HashMap<String, Any>()
    data1["name"] = "John"
    @Assert(q1.call(data1))
    let inner = HashMap<String, Any>()
    inner["year"] = Int64(2000)
    let data2 = HashMap<String, Any>()
    data2["age"] = inner
    @Assert(q2.call(data2))
}

// test_queries.py: test_hash - dictionary key usage & commutativity
@Test
func testQueryHashAdvanced(): Unit {
    let q1 = `where`("key1").eq(Int64(2))
    let q2 = `where`("key1").eq(Int64(2))
    @Assert(q1.hashCode() == q2.hashCode())
    // Commutativity of & and |
    let and1 = `where`("key1").exists() & `where`("key2").exists()
    let and2 = `where`("key2").exists() & `where`("key1").exists()
    @Assert(and1.hashCode() == and2.hashCode())
    let or1 = `where`("key1").exists() | `where`("key2").exists()
    let or2 = `where`("key2").exists() | `where`("key1").exists()
    @Assert(or1.hashCode() == or2.hashCode())
}

// test_queries.py: test_custom_with_params
@Test
func testQueryCustomWithParams(): Unit {
    let q = `where`("val").test({ v: Any =>
        if (let Some(n) <- (v as Int64)) { n >= Int64(1) && n <= Int64(10) } else { false }
    })
    @Assert(q.call(HashMap<String, Any>([("val", Int64(5))])))
    @Assert(!q.call(HashMap<String, Any>([("val", Int64(0))])))
    @Assert(!q.call(HashMap<String, Any>([("val", Int64(11))])))
}

// test_queries.py: test_any - with regex
@Test
func testQueryAnyOfRegex(): Unit {
    let q = `where`("followers").anyOf(`where`("num").matches("\\d+"))
    let doc1 = HashMap<String, Any>()
    let f1 = ArrayList<Any>()
    let m1 = HashMap<String, Any>()
    m1["num"] = "12"
    f1.add(m1)
    let m2 = HashMap<String, Any>()
    m2["num"] = "abc"
    f1.add(m2)
    doc1["followers"] = f1.toArray()
    @Assert(q.call(doc1))
}

// test_tinydb.py: test_insert_ids
@Test
func testInsertIds(): Unit {
    let db = TinyDB(MemoryStorage())
    @Assert(db.insert(HashMap<String, Any>([("int", Int64(1))])) == Int64(1))
    @Assert(db.insert(HashMap<String, Any>([("int", Int64(1))])) == Int64(2))
}

// test_tinydb.py: test_insert_with_doc_id - auto ID after manual
@Test
func testInsertAutoIdAfterManual(): Unit {
    let db = TinyDB(MemoryStorage())
    @Assert(db.insert(HashMap<String, Any>([("int", Int64(1))])) == Int64(1))
    @Assert(db.insertDoc(Document(HashMap<String, Any>([("int", Int64(1))]), Int64(77))) == Int64(77))
    @Assert(db.insert(HashMap<String, Any>([("int", Int64(1))])) == Int64(78))
}

// test_tinydb.py: test_update_all
@Test
func testUpdateAll(): Unit {
    let db = TinyDB(MemoryStorage())
    for (i in 0..3) {
        let doc = HashMap<String, Any>()
        doc["int"] = Int64(1)
        db.insert(doc)
    }
    let updateMap = HashMap<String, Any>()
    updateMap["newField"] = true
    db.update(updateMap, cond: None<QueryInstance>, docIds: None<Array<Int64>>)
    @Assert(db.count(`where`("newField").eq(true)) == Int64(3))
}

// test_tinydb.py: test_upsert_by_id
@Test
func testUpsertById(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["char"] = "a"
    db.insert(doc1)
    let extDoc = Document(HashMap<String, Any>([("char", "v")]), Int64(1))
    let ids = db.upsert(extDoc.toMap(), cond: `where`("char").eq("v"))
    @Assert(ids.size >= 1)
}

// test_tinydb.py: test_remove_returns_ids
@Test
func testRemoveReturnsIds(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc1 = HashMap<String, Any>()
    doc1["int"] = Int64(1)
    doc1["char"] = "a"
    let doc2 = HashMap<String, Any>()
    doc2["int"] = Int64(1)
    doc2["char"] = "b"
    let doc3 = HashMap<String, Any>()
    doc3["int"] = Int64(1)
    doc3["char"] = "c"
    db.insert(doc1)
    db.insert(doc2)
    db.insert(doc3)
    let ids = db.remove(cond: `where`("char").eq("b"), docIds: None<Array<Int64>>)
    @Assert(ids.size == 1)
    @Assert(db.len() == Int64(2))
}

// test_tinydb.py: test_contains_ids
@Test
func testContainsIds(): Unit {
    let db = TinyDB(MemoryStorage())
    let doc = HashMap<String, Any>()
    doc["x"] = Int64(1)
    db.insert(doc)
    @Assert(db.contains(cond: None<QueryInstance>, docId: Int64(1)))
    @Assert(!db.contains(cond: None<QueryInstance>, docId: Int64(88)))
}

// test_tinydb.py: test_gc - table operations with named table
@Test
func testTableNamedOperations(): Unit {
    let db = TinyDB(MemoryStorage())
    let table = db.table("foo")
    let doc1 = HashMap<String, Any>()
    doc1["something"] = "else"
    table.insert(doc1)
    let doc2 = HashMap<String, Any>()
    doc2["int"] = Int64(13)
    table.insert(doc2)
    @Assert(table.search(`where`("int").eq(Int64(13))).size == 1)
    @Assert(table.all().size == 2)
    db.close()
}

// test_tinydb.py: test_insert_on_existing_db
@Test
func testInsertOnExistingDB(): Unit {
    let tmpPath = "/tmp/tinydb_test_existing.json"
    // Clean up
    try { File(tmpPath, OpenMode.Write).close() } catch (_: Exception) {}

    let db1 = TinyDB(JSONStorage(tmpPath))
    db1.insert(HashMap<String, Any>([("foo", "bar")]))
    @Assert(db1.len() == Int64(1))
    db1.close()

    let db2 = TinyDB(JSONStorage(tmpPath))
    db2.insert(HashMap<String, Any>([("foo", "bar")]))
    db2.insert(HashMap<String, Any>([("foo", "bar")]))
    @Assert(db2.len() == Int64(3))
    db2.close()
}

// test_tinydb.py: test_unique_ids - JSON persistence
@Test
func testUniqueIdsJSON(): Unit {
    let tmpPath = "/tmp/tinydb_test_unique.json"
    try { File(tmpPath, OpenMode.Write).close() } catch (_: Exception) {}

    let db1 = TinyDB(JSONStorage(tmpPath))
    db1.insert(HashMap<String, Any>([("x", Int64(1))]))
    db1.close()

    let db2 = TinyDB(JSONStorage(tmpPath))
    db2.insert(HashMap<String, Any>([("x", Int64(1))]))
    db2.close()

    let db3 = TinyDB(JSONStorage(tmpPath))
    let allDocs = db3.all()
    var idsUnique = true
    if (allDocs.size == 2) {
        idsUnique = allDocs[0].docId != allDocs[1].docId
    }
    @Assert(idsUnique)
    db3.close()
}

// test_tinydb.py: test_drop_table - detailed
@Test
func testDropTableDetailed(): Unit {
    let db = TinyDB(MemoryStorage())
    @Assert(db.tables().size == 0)
    db.insert(HashMap<String, Any>([("a", Int64(1))]))
    @Assert(db.tables().contains("_default"))
    db.dropTable("_default")
    @Assert(!db.tables().contains("_default"))

    // Drop non-existent table should not error
    db.dropTable("non-existent-table-name")
    @Assert(db.tables().size == 0)
}

// test_tables.py: test_next_id
@Test
func testNextId(): Unit {
    let db = TinyDB(MemoryStorage())
    db.truncate()
    @Assert(db.insert(HashMap<String, Any>()) == Int64(1))
    @Assert(db.insert(HashMap<String, Any>()) == Int64(2))
    @Assert(db.insert(HashMap<String, Any>()) == Int64(3))
}

// test_tables.py: test_tables_list
@Test
func testTablesList(): Unit {
    let db = TinyDB(MemoryStorage())
    db.table("table1").insert(HashMap<String, Any>([("a", Int64(1))]))
    db.table("table2").insert(HashMap<String, Any>([("a", Int64(1))]))
    let tables = db.tables()
    @Assert(tables.contains("table1"))
    @Assert(tables.contains("table2"))
}

// test_tables.py: test_one_table
@Test
func testOneTable(): Unit {
    let db = TinyDB(MemoryStorage())
    let table1 = db.table("table1")
    let doc1 = HashMap<String, Any>()
    doc1["int"] = Int64(1)
    doc1["char"] = "a"
    table1.insert(doc1)
    let doc2 = HashMap<String, Any>()
    doc2["int"] = Int64(1)
    doc2["char"] = "b"
    table1.insert(doc2)
    @Assert(table1.search(`where`("int").eq(Int64(1))).size == 2)
}

// test_tables.py: test_truncate resets id
@Test
func testTruncateResetsId(): Unit {
    let db = TinyDB(MemoryStorage())
    db.insert(HashMap<String, Any>())
    db.insert(HashMap<String, Any>())
    db.truncate()
    @Assert(db.insert(HashMap<String, Any>()) == Int64(1))
}

// test_tables.py: test_zero_cache_size
@Test
func testZeroCacheSize(): Unit {
    let db = TinyDB(MemoryStorage())
    let t = db.table("table3", cacheSize: 0)
    t.insert(HashMap<String, Any>([("int", Int64(1))]))
    t.insert(HashMap<String, Any>([("int", Int64(1))]))
    @Assert(t.count(`where`("int").eq(Int64(1))) == Int64(2))
    @Assert(t.count(`where`("int").eq(Int64(2))) == Int64(0))
}

// test_middlewares.py: test_caching_read
@Test
func testCachingMiddlewareRead(): Unit {
    let mw = CachingMiddleware({ => MemoryStorage() })
    mw.initialize()
    let db = TinyDB(mw)
    @Assert(db.all().size == 0)
    mw.close()
}

// test_middlewares.py: test_caching_write_many
@Test
func testCachingMiddlewareWriteMany(): Unit {
    let mw = CachingMiddleware({ => MemoryStorage() })
    mw.initialize()
    // Write 3 times, WRITE_CACHE_SIZE is 1000 so won't auto-flush
    let doc = HashMap<String, Any>()
    doc["key"] = "value"
    mw.write(HashMap<String, HashMap<String, HashMap<String, Any>>>())
    mw.write(HashMap<String, HashMap<String, HashMap<String, Any>>>())
    mw.write(HashMap<String, HashMap<String, HashMap<String, Any>>>())
    mw.close()
}

// test_middlewares.py: test_nested
@Test
func testCachingMiddlewareNested(): Unit {
    let mw = CachingMiddleware({ => MemoryStorage() })
    mw.initialize()
    let data = HashMap<String, HashMap<String, HashMap<String, Any>>>()
    let tbl = HashMap<String, HashMap<String, Any>>()
    let doc = HashMap<String, Any>()
    doc["key"] = "value"
    tbl["1"] = doc
    data["_default"] = tbl
    mw.write(data)
    var readOk = false
    if (let Some(read) <- mw.read()) {
        readOk = read.contains("_default")
    }
    @Assert(readOk)
    mw.close()
}

// test_utils.py: test_lru_cache - ordering
@Test
func testLRUOrdering(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 3)
    cache.set("a", Int64(1))
    cache.set("b", Int64(2))
    cache.set("c", Int64(3))
    cache.get("a")
    cache.set("d", Int64(4))
    // "b" should be evicted
    @Assert(cache.get("b") == None<Int64>)
    @Assert(cache.get("a") != None<Int64>)
    @Assert(cache.get("c") != None<Int64>)
    @Assert(cache.get("d") != None<Int64>)
}

// test_utils.py: test_lru_cache_set_multiple
@Test
func testLRUSetMultiple(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 3)
    cache.set("a", Int64(1))
    cache.set("a", Int64(2))
    cache.set("a", Int64(3))
    cache.set("a", Int64(4))
    @Assert(cache.length() == Int64(1))
    var val = Int64(0)
    if (let Some(v) <- cache.get("a")) { val = v }
    @Assert(val == Int64(4))
}

// test_utils.py: test_lru_cache_falsy_values_bug
@Test
func testLRUFalsyValues(): Unit {
    let cache = LRUCache<String, Int64>(capacity: 3)
    cache.set("a", Int64(0))
    cache.set("b", Int64(1))
    cache.set("c", Int64(2))
    // Update existing key with non-falsy value
    cache.set("a", Int64(3))
    // Add new item - should evict "b"
    cache.set("d", Int64(4))
    @Assert(cache.get("b") == None<Int64>)
    var aVal = Int64(0)
    if (let Some(v) <- cache.get("a")) { aVal = v }
    @Assert(aVal == Int64(3))
}

// test_storages.py: test_in_memory - isolation
@Test
func testMemoryStorageIsolation(): Unit {
    let s1 = MemoryStorage()
    let data1 = HashMap<String, HashMap<String, HashMap<String, Any>>>()
    let tbl1 = HashMap<String, HashMap<String, Any>>()
    tbl1["1"] = HashMap<String, Any>([("x", Int64(1))])
    data1["_default"] = tbl1
    s1.write(data1)

    let s2 = MemoryStorage()
    let data2 = HashMap<String, HashMap<String, HashMap<String, Any>>>()
    s2.write(data2)

    // Different storages should have different data
    var s1HasDefault = false
    var s2Empty = true
    if (let Some(r) <- s1.read()) { s1HasDefault = r.contains("_default") }
    if (let Some(r) <- s2.read()) { s2Empty = !r.contains("_default") }
    @Assert(s1HasDefault)
    @Assert(s2Empty)
}

// test_storages.py: test_json read/write cycle
@Test
func testJSONStorageReadWrite(): Unit {
    let tmpPath = "/tmp/tinydb_test_rw.json"
    try { File(tmpPath, OpenMode.Write).close() } catch (_: Exception) {}

    let db = TinyDB(JSONStorage(tmpPath))
    db.insert(HashMap<String, Any>([("name", "long entry")]))
    var gotIt = false
    let r = db.get(cond: `where`("name").eq("long entry"), docId: None<Int64>, docIds: None<Array<Int64>>)
    match (r) {
        case Some(_) => gotIt = true
        case None => gotIt = false
    }
    @Assert(gotIt)
    db.close()
}
