/**
 * Created on 2025/7/16
 */
package ohos_app_cangjie_entry.dataModel
import ohos.component.ResourceType
import ohos.base.CJResource
import ohos.base.Color

public class CourseItem{
    public var name: CJResource
    public var backColor: Color

    public init(name: CJResource, backgroundColor: Color){
        this.name = name
        this.backColor = backgroundColor
    }
}