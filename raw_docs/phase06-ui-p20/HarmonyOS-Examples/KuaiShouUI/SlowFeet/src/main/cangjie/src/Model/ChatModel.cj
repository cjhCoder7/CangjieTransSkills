/**
 * Created on 2024/8/24
 */
package ohos_app_cangjie_SlowFeet.Model

public class ChatModel {
    public init(message: String, from!: Bool = true)
    {
        this.message = message
        this.from = from
    }
    public var message: String
    public var from: Bool
}