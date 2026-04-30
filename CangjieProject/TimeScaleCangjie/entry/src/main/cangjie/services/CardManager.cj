package ohos_app_cangjie_entry.services

import std.collection.*

public class CardManager {
    private static var instance: ?CardManager = None
    private var formIds: HashSet<String> = HashSet<String>()
    private var formDimensions: HashMap<String, Int64> = HashMap<String, Int64>()

    public init() {}

    public static func getInstance(): CardManager {
        if (let Some(inst) <- instance) {
            return inst
        }
        let inst = CardManager()
        instance = inst
        inst
    }

    public func registerForm(formId: String): Unit {
        formIds.add(formId)
    }

    public func unregisterForm(formId: String): Unit {
        formIds.remove(formId)
        formDimensions.remove(formId)
    }

    public func setFormDimension(formId: String, dimension: Int64): Unit {
        formDimensions.add(formId, dimension)
    }

    public func getFormDimension(formId: String): Int64 {
        formDimensions.get(formId) ?? 2
    }

    public func clearFormDimension(formId: String): Unit {
        formDimensions.remove(formId)
    }

    public func updateAllForms(context: Object): Unit {
        for (formId in formIds) {
            updateForm(formId, context)
        }
    }

    public func updateForm(formId: String, context: Object): Unit {
        // 后续接入 FormKit API
    }
}
