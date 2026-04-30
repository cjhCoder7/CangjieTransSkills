package ohos_app_cangjie_entry

import ohos.resource.AppResource

public func __GenerateResource__(bundleName: String, moduleName: String, abilityName: String, id: Int64, typeName: String, params: Array<String>, resType: Int64): AppResource {
    AppResource(bundleName, abilityName, UInt32(id))
}
