/**
 * Created on 2025/8/12
 */
package ohos_app_cangjie_entry.components.ScrollLayout

import ohos.base.CJResource
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import ohos.state_macro_manage.Builder


public class House {
    public let title: String
    public let price: Int64
    public let imgSrc: CJResource

    public init(title: String, price: Int64, imgSrc: CJResource) {
        this.title = title
        this.price = price
        this.imgSrc = imgSrc
    }
}

