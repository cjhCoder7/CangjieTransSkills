/**
 * Created on 2024/8/13
 */
package ohos_app_cangjie_entry.models

import ohos.base.CJResource
import std.collection.ArrayList

public class ProductInfoModel {
    // 商品图片
    private let icon: CJResource
    // 商品标题
    private let title: String
    // 商品销售价格
    private let salePrice: Int64
    // 商品原价，划线价
    private let originalPrice: Int64

    public ProductInfoModel(icon: CJResource, title: String, salePrice: Int64, originalPrice: Int64) {
        this.icon = icon
        this.title = title
        this.salePrice = salePrice
        this.originalPrice = originalPrice
    }

    public func getIcon(): CJResource {
        return this.icon
    }

    public func getTitle(): String {
        return this.title
    }

    public func getSalePrice(): Int64 {
        return this.salePrice
    }

    public func getOriginalPrice(): Int64 {
        return this.originalPrice
    }
}