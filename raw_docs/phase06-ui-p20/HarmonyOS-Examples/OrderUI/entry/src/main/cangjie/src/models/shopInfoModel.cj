/**
 * Created on 2024/8/12
 */
package ohos_app_cangjie_entry.models

import ohos.base.CJResource
import std.collection.ArrayList

public class ShopInfoModel {
    private let id: Int64
    // 商家图片
    private let icon: CJResource
    // 商家标题
    private let title: String
    // 商家分数
    private let score: String
    // 月销售数
    private let saleNumber: Int64
    // 推荐标签
    private let labels: ArrayList<String>
    // 首页需要使用的商品数据
    private var products: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>()

    public ShopInfoModel(id: Int64, icon: CJResource, title: String, score: String, saleNumber: Int64,
        labels: ArrayList<String>) {
        this.id = id
        this.icon = icon
        this.title = title
        this.score = score
        this.saleNumber = saleNumber
        this.labels = labels
    }

    public init(id: Int64, icon: CJResource, title: String, score: String, saleNumber: Int64,
        labels: ArrayList<String>, products: ArrayList<ProductInfoModel>) {
        this.id = id
        this.icon = icon
        this.title = title
        this.score = score
        this.saleNumber = saleNumber
        this.labels = labels
        this.products = products
    }

    public func getId(): Int64 {
        return this.id
    }

    public func getIcon(): CJResource {
        return this.icon
    }

    public func getTitle(): String {
        return this.title
    }

    public func getScore(): String {
        return this.score
    }

    public func getSaleNumber(): Int64 {
        return this.saleNumber
    }

    public func getLabels(): ArrayList<String> {
        return this.labels
    }

    public func getProducts(): ArrayList<ProductInfoModel> {
        return this.products
    }
}