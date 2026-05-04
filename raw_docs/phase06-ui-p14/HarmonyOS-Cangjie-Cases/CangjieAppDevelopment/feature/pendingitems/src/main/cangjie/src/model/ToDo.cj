/**
 * Created on 2024/10/22
 */
package pendingitems.model

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import std.random.*

let random = Random(123)

@Observed
public class ToDo {
    public let key: String = random.next(64).toString() //TODO：仓颉缺少生成随机UUID的接口。 util.generateRandomUUID(true) // 生成随机uuid
    @Publish public var name: String = ""    // 待办事项名称
    @Publish public var isFinished: Bool = false;
}