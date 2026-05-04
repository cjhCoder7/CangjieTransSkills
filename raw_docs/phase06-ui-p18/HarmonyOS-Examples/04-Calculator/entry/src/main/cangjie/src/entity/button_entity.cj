/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.entity

import ohos_app_cangjie_entry.service.DynamicParam
import ohos.component.Text
import ohos.base.Color


public open class ButtonEntity {

    public static let bigSize: Int64 = 48
    public static let smallSize: Int64 = 24

    public var bgColor: Color = Color(0)
    public var textColor: Color = Color(0)

    public ButtonEntity(public let text: String) {}

    public open func beforePush(dynamicParam: DynamicParam) {}

    public open func afterPush(dynamicParam: DynamicParam) {}

    public open func onPress(dynamicParam: DynamicParam) {
        beforePush(dynamicParam)
        dynamicParam.push(text)
        afterPush(dynamicParam)
    }
}
