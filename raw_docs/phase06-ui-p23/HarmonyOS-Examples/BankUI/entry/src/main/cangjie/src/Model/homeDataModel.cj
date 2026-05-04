/**
 * Created on 2024/8/28
 */
package ohos_app_cangjie_entry.Model

internal import ohos.base.*
import std.collection.ArrayList
import ohos.state_macro_manage.*
import cj_res_entry.app

public class iconItem{

    private let title: String;

    private let image: CJResource;

    public iconItem(title: String, image: CJResource){
        this.title = title
        this.image = image
    }

    public func getTitle(): String{
        return this.title
    }

    public func getImage(): CJResource{
        return this.image
    }
}

public class itemsValue{

    private let title: String;

    private let value: Float32;

    public itemsValue(title: String, value: Float32){
        this.title = title
        this.value = value
    }

    public func getTitle(): String{
        return this.title
    }

    public func getValue(): Float32{
        return this.value
    }
}

public class recommendSubItem{

    private let title: String;

    private let sub_title: String;

    private let description: String;

    private let sub_description: String;

    public recommendSubItem(title: String, sub_title: String, description: String, sub_description: String){
        this.title = title
        this.sub_title = sub_title
        this.description = description
        this.sub_description = sub_description
    }

    public func getTitle(): String{
        return this.title
    }

    public func getSubTitle(): String{
        return this.sub_title
    }

    public func getDescription(): String{
        return this.description
    }

    public func getSubDescription(): String{
        return this.sub_description
    }
}

public let BannerList: ArrayList<iconItem> = ArrayList<iconItem>(
    iconItem("扫一扫", @r(app.media.ic_home_scan)),
    iconItem('收付款', @r(app.media.ic_home_pay)),
    iconItem('转账', @r(app.media.ic_home_transfer)),
    iconItem('账户管理', @r(app.media.ic_home_account))
)

public let HeaderIconList: ArrayList<iconItem> = ArrayList<iconItem>(
    iconItem("客服", @r(app.media.ic_home_service)),
    iconItem('消息', @r(app.media.ic_home_news))
)

public let SwiperList: ArrayList<CJResource> = ArrayList<CJResource>(
    @r(app.media.ic_public_swiper1),
    @r(app.media.ic_public_swiper2)
)

public let EntranceList: ArrayList<iconItem> = ArrayList<iconItem>(
    iconItem("外汇", @r(app.media.ic_sub_exchange)),
    iconItem('生活缴费', @r(app.media.ic_sub_life_bill)),
    iconItem('权益', @r(app.media.ic_sub_vip)),
    iconItem('话费充值', @r(app.media.ic_sub_phone_bill)),
    iconItem("财富", @r(app.media.ic_sub_wealth)),
    iconItem('保险', @r(app.media.ic_sub_insure)),
    iconItem('我的理财', @r(app.media.ic_sub_bill_manage)),
    iconItem('贷款', @r(app.media.ic_sub_loan)),
    iconItem("热门活动", @r(app.media.ic_sub_activity)),
    iconItem('更多', @r(app.media.ic_sub_more))
)

public let advertisementItems: ArrayList<iconItem> = ArrayList<iconItem>(
    iconItem("焕新开启",@r(app.media.activity_advertisement1)),
    iconItem("分享有礼",@r(app.media.activity_advertisement2))
)

public let recommendList: ArrayList<itemsValue> = ArrayList<itemsValue>(
    itemsValue("美元(USD)", 726.28),
    itemsValue("黄金(AU)", 542.4),
    itemsValue("上证指数", 3035.56)
)

public let recommendSubList: ArrayList<recommendSubItem> = ArrayList<recommendSubItem>(
    recommendSubItem("新发基金","为您精选","理财推荐","潜力股"),
    recommendSubItem("稳健策略","财富臻选","债券推荐","潜力股")
)

public let profileItems: ArrayList<iconItem> = ArrayList<iconItem>(
    iconItem("我的账户",@r(app.media.ic_profile_account)),
    iconItem("我的权益",@r(app.media.ic_profile_service)),
    iconItem("我的积分",@r(app.media.ic_profile_tokens)),
    iconItem("我的活动",@r(app.media.ic_sub_activity))
)

