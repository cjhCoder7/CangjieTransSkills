/**
 * Created on 2024/8/10
 */
package ohos_app_cangjie_entry.models
internal import ohos.base.CJResource
//@Observed
public class TabBar {
    private let icon: CJResource
    private let selectIcon: CJResource
    private let title: String
    private let name: String

    public TabBar(icon: CJResource, selectIcon: CJResource, title: String, name: String) {
        this.icon = icon
        this.selectIcon = selectIcon
        this.title = title
        this.name = name
    }

    public func getIcon(): CJResource {
        return this.icon
    }

    public func getSelectIcon(): CJResource {
        return this.selectIcon
    }

    public func getTitle(): String {
        return this.title
    }

    public func getName(): String {
        return this.name
    }
}