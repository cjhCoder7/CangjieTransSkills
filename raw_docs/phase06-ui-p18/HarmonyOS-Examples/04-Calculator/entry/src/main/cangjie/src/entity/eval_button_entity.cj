/**
 * Created on 2025/7/21
 */
package ohos_app_cangjie_entry.entity

import ohos_app_cangjie_entry.service.DynamicParam
import ohos.base.Color

public class EvalButtonEntity <: ButtonEntity {
    public init(text: String) {
        super(text)
        bgColor = Color(0xFF4281F4)
        textColor = Color(0xFFFFFF)
    }

    public open func onPress(dynamicParam: DynamicParam) {
        dynamicParam.resetSize(smallSize, bigSize)
    }
}