/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.entity

import ohos_app_cangjie_entry.service.DynamicParam
import ohos.base.Color

public class OperationButtonEntity <:ButtonEntity {
    public init(text: String) {
        super(text)
        bgColor = Color(0xFFF5F5F5)
        textColor = Color(0xFF4281F4)
    }

    public func afterPush(dynamicParam: DynamicParam) {
        dynamicParam.resetSize(bigSize, smallSize)
    }
}