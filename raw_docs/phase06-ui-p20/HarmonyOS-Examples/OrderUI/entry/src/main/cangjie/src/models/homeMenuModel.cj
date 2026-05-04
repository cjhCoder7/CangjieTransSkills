/**
 * Created on 2024/8/11
 */
package ohos_app_cangjie_entry.models

import ohos.base.CJResource

public class HomeMenuModel {
    private let icon: CJResource
    private let title: String
    public HomeMenuModel(icon: CJResource, title: String) {
        this.icon = icon
        this.title = title
    }

    public func getTitle(): String {
        return this.title
    }

    public func getIcon(): CJResource {
        return this.icon
    }
}
