enum StorageValue {
    | StringValue(String)
    | BoolValue(Bool)
    | IntValue(Int64)
    | DoubleValue(Float64)
}

interface KeyValueStorage {
    func has(key: String): Bool
    func get(key: String, defaultValue: StorageValue): StorageValue
    func put(key: String, value: StorageValue): Unit
    func remove(key: String): Unit
    func flush(): Unit
}

func readStringValue(value: StorageValue, fallback: String): String {
    match (value) {
        case StorageValue.StringValue(text) => text
        case _ => fallback
    }
}

func readBoolValue(value: StorageValue, fallback: Bool): Bool {
    match (value) {
        case StorageValue.BoolValue(enabled) => enabled
        case _ => fallback
    }
}

func readIntValue(value: StorageValue, fallback: Int64): Int64 {
    match (value) {
        case StorageValue.IntValue(number) => number
        case _ => fallback
    }
}

func readDoubleValue(value: StorageValue, fallback: Float64): Float64 {
    match (value) {
        case StorageValue.DoubleValue(number) => number
        case _ => fallback
    }
}
