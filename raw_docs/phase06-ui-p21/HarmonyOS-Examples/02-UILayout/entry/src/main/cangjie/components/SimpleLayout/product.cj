/**
 * Created on 2025/8/4
 */
package ohos_app_cangjie_entry.components.SimpleLayout

import ohos_app_cangjie_entry.utils.{formatFloat64}


public class Product {
    let name: String  // 商品名称
    let description: String  // 商品细节描述
    let price: Float64  // 单价
    let num: Int64  // 数量

    public init(name: String, description: String, price: Float64, num: Int64) {
        this.name = name
        this.description = description
        this.price = price
        this.num = num
    }
}


public let defaultProductList: Array<Product> = [
    Product("Nike Court Borough Low Prem", "低帮 板鞋 黑灰", 349.00, 1),
    Product("NATIONAL GEOGRAPHIC X Vans SK8 Reissue 138", "高帮 板鞋 黑", 649.00, 1),
    Product("Converse Chuck 70", "高帮 帆布鞋 复古黑", 323.00, 1),
    Product("Puma Speedcat", "赛车鞋 薄鞋底 低帮 极影黑", 399.00, 1),
    Product("Jordan Air Jordan 1 Panda熊猫", "低帮 复古篮球鞋 黑白", 478.00, 1)
]


public let defaultTotalCost: String = { =>
        var total: Float64 = 0.0
        for (p in defaultProductList) {
            total += p.price * Float64(p.num)
        }
        formatFloat64(total)
}()  // 立即调用函数