package ohos_app_cangjie_entry

import std.collection.*

class FakeKeyValueStorage <: KeyValueStorage {
    private let values = HashMap<String, StorageValue>()
    private let operations = ArrayList<String>()
    private var flushCounter: Int64 = 0

    public init() {}

    public func has(key: String): Bool {
        match (this.values.get(key)) {
            case Some(_) => true
            case _ => false
        }
    }

    public func get(key: String, defaultValue: StorageValue): StorageValue {
        match (this.values.get(key)) {
            case Some(value) => value
            case _ => defaultValue
        }
    }

    public func put(key: String, value: StorageValue): Unit {
        this.values.add(key, value)
        this.operations.append("put:${key}")
    }

    public func remove(key: String): Unit {
        if (this.has(key)) {
            this.values.remove(key)
            this.operations.append("remove:${key}")
        }
    }

    public func flush(): Unit {
        this.flushCounter = this.flushCounter + 1
        this.operations.append("flush")
    }

    public func flushCount(): Int64 {
        this.flushCounter
    }

    public func storedKeyCount(): Int64 {
        this.values.size
    }

    public func lastOperation(): String {
        if (this.operations.size == 0) {
            ""
        } else {
            this.operations[this.operations.size - 1]
        }
    }

    public func debugString(key: String, fallback: String): String {
        readStringValue(this.get(key, StorageValue.StringValue(fallback)), fallback)
    }

    public func debugBool(key: String, fallback: Bool): Bool {
        readBoolValue(this.get(key, StorageValue.BoolValue(fallback)), fallback)
    }
}
