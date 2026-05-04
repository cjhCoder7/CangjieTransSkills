/**
 * Created on 2024/8/11
 */

package ohos_app_cangjie_entry.constants
import std.collection.{ArrayList, HashMap}
import ohos.base.*
import ohos.state_macro_manage.r
import cj_res_entry.app
import ohos_app_cangjie_entry.models.{HomeMenuModel, ShopInfoModel, ProductInfoModel}
public class HomeConstants {
    public static let HOME_HEADER_HEIGNT: Int64  = 34

    public static let HOME_HEADER_TOP_PADDING: Int64 = 10


    public static let HOME_SEARCH_GUESS: ArrayList<String> = ArrayList<String>("麻辣烫", "火锅", "胡辣汤", "包子", "红烧鱼", "冒菜")

    public static let HOME_BANNER_TOP_MARGIN = 10
    public static let HOME_BANNER_HEIGHT: Int64 = 200
    public static let HOME_BANNER_LIST: ArrayList<CJResource> = ArrayList<CJResource>(@r(app.media.ic_banner_1),
        @r(app.media.ic_banner_2), @r(app.media.ic_banner_3), @r(app.media.ic_banner_4), @r(app.media.ic_banner_5))

    public static let HOME_MENU_TOP_MARGIN = 10
    public static let HOME_MENU_PADDING = 4
    public static let HOME_MENU_HEIGHT_SM = 200
    public static let HOME_MENU_HEIGHT_MD = 100
    public static let HOME_MENU_HEIGHT_LG = 100

    public static let HOME_MENU_LIST_SPACE_SM: Int64 = 0
    public static let HOME_MENU_LIST_SPACE_MD: Int64 = 36
    public static let HOME_MENU_LIST_SPACE_LG: Int64 = 72

    public static let HOME_MENU_ITEM_HEIGHT_SM: Int64 = 94
    public static let HOME_MENU_ITEM_HEIGHT_MD: Int64 = 100
    public static let HOME_MENU_ITEM_HEIGHT_LG: Int64 = 100

    public static let HOME_MENU_ITEM_WIDTH_SM: Length = Length(20, unitType: LengthType.percent)
    public static let HOME_MENU_ITEM_WIDTH_MD: Length = Length(94)
    public static let HOME_MENU_ITEM_WIDTH_LG: Length = Length(94)


    public static let HOME_MENU_LIST: ArrayList<HomeMenuModel> = ArrayList<HomeMenuModel>(
        HomeMenuModel(@r(app.media.menu_1), "精选早餐"),
        HomeMenuModel(@r(app.media.menu_6), "优惠券礼包"),
        HomeMenuModel(@r(app.media.menu_2), "优质午餐"),
        HomeMenuModel(@r(app.media.menu_7), "邀请有礼"),
        HomeMenuModel(@r(app.media.menu_3), "1元抢购"),
        HomeMenuModel(@r(app.media.menu_8), "分享助力"),
        HomeMenuModel(@r(app.media.menu_4), "必点套餐"),
        HomeMenuModel(@r(app.media.menu_9), "福利群"),
        HomeMenuModel(@r(app.media.menu_5), "今日推荐"),
        HomeMenuModel(@r(app.media.menu_10), "领取优惠券")
    )

    public static let HOME_SHOP_RECOMMEND_HEIGHT = 120
    // 附近商家
    public static let NEARBY_SHOP_LIST: ArrayList<ShopInfoModel> = ArrayList<ShopInfoModel>(
        ShopInfoModel(1, @r(app.media.shop_logo_1), "河北饭店", "5.0", 300, ArrayList<String>("优选商家")),
        ShopInfoModel(2, @r(app.media.shop_logo_2), "山西饭店", "4.9", 400, ArrayList<String>("精品商家")),
        ShopInfoModel(3, @r(app.media.shop_logo_3), "辽宁饭店", "4.8", 500, ArrayList<String>("秒杀商家")),
        ShopInfoModel(4, @r(app.media.shop_logo_4), "吉林饭店", "5.0", 300, ArrayList<String>("优选商家")),
        ShopInfoModel(5, @r(app.media.shop_logo_5), "黑龙江饭店", "4.9", 400, ArrayList<String>("精品商家")),
        ShopInfoModel(6, @r(app.media.shop_logo_6), "江苏饭店", "4.8", 500, ArrayList<String>("秒杀商家"))
    )
    // 优惠商家
    public static let DISCOUNT_SHOP_LIST: ArrayList<ShopInfoModel> = ArrayList<ShopInfoModel>(
        ShopInfoModel(7, @r(app.media.shop_logo_7), "浙江饭店", "5.0", 300, ArrayList<String>("优选商家")),
        ShopInfoModel(8, @r(app.media.shop_logo_8), "安徽饭店", "4.9", 400, ArrayList<String>("精品商家")),
        ShopInfoModel(9, @r(app.media.shop_logo_9), "福建饭店", "4.8", 500, ArrayList<String>("秒杀商家")),
        ShopInfoModel(10, @r(app.media.shop_logo_10), "江西饭店", "5.0", 300, ArrayList<String>("优选商家"))
    )
    // 优惠商家
    public static let SECKILL_SHOP_LIST: ArrayList<ShopInfoModel> = ArrayList<ShopInfoModel>(
        ShopInfoModel(11, @r(app.media.shop_logo_11), "山东饭店", "5.0", 300, ArrayList<String>("优选商家")),
        ShopInfoModel(12, @r(app.media.shop_logo_12), "河南饭店", "4.9", 400, ArrayList<String>("精品商家")),
        ShopInfoModel(13, @r(app.media.shop_logo_13), "湖北饭店", "4.8", 500, ArrayList<String>("秒杀商家")),
        ShopInfoModel(14, @r(app.media.shop_logo_14), "湖南饭店", "5.0", 300, ArrayList<String>("优选商家"))
    )
    // 新品商家
    public static let NEW_SHOP_LIST: ArrayList<ShopInfoModel> = ArrayList<ShopInfoModel>(
        ShopInfoModel(15, @r(app.media.shop_logo_15), "广东饭店", "5.0", 300, ArrayList<String>("优选商家")),
        ShopInfoModel(16, @r(app.media.shop_logo_16), "海南饭店", "4.9", 400, ArrayList<String>("精品商家")),
        ShopInfoModel(17, @r(app.media.shop_logo_17), "四川饭店", "4.8", 500, ArrayList<String>("秒杀商家")),
        ShopInfoModel(18, @r(app.media.shop_logo_18), "贵州饭店", "5.0", 300, ArrayList<String>("优选商家")),
        ShopInfoModel(19, @r(app.media.shop_logo_19), "云南饭店", "4.9", 400, ArrayList<String>("精品商家")),
        ShopInfoModel(20, @r(app.media.shop_logo_20), "陕西饭店", "4.8", 500, ArrayList<String>("秒杀商家"))
    )
//    嗨吃汉堡 food_hamburg_
//    米面套餐 food_rice_
//    精选小菜 food_dish_
//    必填套餐 food_package_
//    营养粥品 food_congee_
//    水果拼盘 food_fruit_
//    精品糕点 food_cake_
    // 商家包含的商品信息，列表
    public static let FOOD_HAMBURG_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_hamburg_1), "嗨吃汉堡1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_hamburg_2), "嗨吃汉堡2", 230, 330),
        ProductInfoModel(@r(app.media.food_hamburg_3), "嗨吃汉堡3", 3230, 4330),
        ProductInfoModel(@r(app.media.food_hamburg_4), "嗨吃汉堡4", 230, 330),
        ProductInfoModel(@r(app.media.food_hamburg_5), "嗨吃汉堡5", 4230, 5330),
    )
    public static let FOOD_RICE_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_rice_1), "米面套餐1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_rice_2), "米面套餐2", 230, 330),
        ProductInfoModel(@r(app.media.food_rice_3), "米面套餐3", 3230, 4330),
        ProductInfoModel(@r(app.media.food_rice_4), "米面套餐4", 230, 330),
        ProductInfoModel(@r(app.media.food_rice_5), "米面套餐5", 4230, 5330),
        ProductInfoModel(@r(app.media.food_rice_6), "米面套餐6", 230, 330),
        ProductInfoModel(@r(app.media.food_rice_7), "米面套餐7", 5230, 6330),
    )
    public static let FOOD_DISH_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_dish_1), "精选小菜1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_dish_2), "精选小菜2", 230, 330),
        ProductInfoModel(@r(app.media.food_dish_3), "精选小菜3", 3230, 4330),
    )
    public static let FOOD_PACKAGE_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_package_1), "必填套餐1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_package_2), "必填套餐2", 230, 330),
        ProductInfoModel(@r(app.media.food_package_3), "必填套餐3", 3230, 4330),
        ProductInfoModel(@r(app.media.food_package_4), "必填套餐4", 230, 330),
        ProductInfoModel(@r(app.media.food_package_5), "必填套餐5", 4230, 5330),
        ProductInfoModel(@r(app.media.food_package_6), "必填套餐6", 230, 330),
        ProductInfoModel(@r(app.media.food_package_7), "必填套餐7", 5230, 6330),
        ProductInfoModel(@r(app.media.food_package_8), "必填套餐8", 230, 330),
        ProductInfoModel(@r(app.media.food_package_9), "必填套餐9", 230, 330)
    )
    public static let FOOD_CONGEE_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_congee_1), "营养粥品1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_congee_2), "营养粥品2", 230, 330)
    )
    public static let FOOD_FRUIT_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_fruit_1), "水果拼盘1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_fruit_2), "水果拼盘2", 230, 330),
        ProductInfoModel(@r(app.media.food_fruit_3), "水果拼盘3", 230, 330),
        ProductInfoModel(@r(app.media.food_fruit_4), "水果拼盘4", 230, 330),
        ProductInfoModel(@r(app.media.food_fruit_5), "水果拼盘5", 230, 330),
        ProductInfoModel(@r(app.media.food_fruit_6), "水果拼盘6", 230, 330)
    )
    public static let FOOD_CAKE_LIST: ArrayList<ProductInfoModel> = ArrayList<ProductInfoModel>(
        ProductInfoModel(@r(app.media.food_cake_1), "精品糕点1", 1230, 2330),
        ProductInfoModel(@r(app.media.food_cake_2), "精品糕点2", 230, 330),
        ProductInfoModel(@r(app.media.food_cake_3), "精品糕点3", 3230, 4330),
        ProductInfoModel(@r(app.media.food_cake_4), "精品糕点4", 230, 330),
        ProductInfoModel(@r(app.media.food_cake_5), "精品糕点5", 4230, 5330),
        ProductInfoModel(@r(app.media.food_cake_6), "精品糕点6", 230, 330),
        ProductInfoModel(@r(app.media.food_cake_7), "精品糕点7", 5230, 6330),
        ProductInfoModel(@r(app.media.food_cake_8), "精品糕点8", 230, 330)
    )

    // 商家信息，HashMap
    public static let SHOP_INFO_MAP: HashMap<Int64, ShopInfoModel> = HashMap<Int64, ShopInfoModel>([
        (1, ShopInfoModel(1,@r(app.media.shop_logo_1), "河北饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_CAKE_LIST)),
        (2, ShopInfoModel(2,@r(app.media.shop_logo_2), "山西饭店", "4.9", 400, ArrayList<String>("精品商家","优选商家"), HomeConstants.FOOD_HAMBURG_LIST)),
        (3, ShopInfoModel(3, @r(app.media.shop_logo_3), "辽宁饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_RICE_LIST)),
        (4, ShopInfoModel(4, @r(app.media.shop_logo_4), "吉林饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_DISH_LIST)),
        (5, ShopInfoModel(5, @r(app.media.shop_logo_5), "黑龙江饭店", "4.9", 400, ArrayList<String>("精品商家","优选商家"), HomeConstants.FOOD_PACKAGE_LIST)),
        (6, ShopInfoModel(6, @r(app.media.shop_logo_6), "江苏饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_CONGEE_LIST)),
        (7, ShopInfoModel(7, @r(app.media.shop_logo_7), "浙江饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_FRUIT_LIST)),
        (8, ShopInfoModel(8, @r(app.media.shop_logo_8), "安徽饭店", "4.9", 400, ArrayList<String>("精品商家"), HomeConstants.FOOD_CAKE_LIST)),
        (9, ShopInfoModel(9, @r(app.media.shop_logo_9), "福建饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_HAMBURG_LIST)),
        (10, ShopInfoModel(10, @r(app.media.shop_logo_10), "江西饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_RICE_LIST)),
        (11, ShopInfoModel(11, @r(app.media.shop_logo_11), "山东饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_DISH_LIST)),
        (12, ShopInfoModel(12, @r(app.media.shop_logo_12), "河南饭店", "4.9", 400, ArrayList<String>("精品商家"), HomeConstants.FOOD_PACKAGE_LIST)),
        (13, ShopInfoModel(13, @r(app.media.shop_logo_13), "湖北饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_CONGEE_LIST)),
        (14, ShopInfoModel(14, @r(app.media.shop_logo_14), "湖南饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_FRUIT_LIST)),
        (15, ShopInfoModel(15, @r(app.media.shop_logo_15), "广东饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_CAKE_LIST)),
        (16, ShopInfoModel(16, @r(app.media.shop_logo_16), "海南饭店", "4.9", 400, ArrayList<String>("精品商家","优选商家"), HomeConstants.FOOD_HAMBURG_LIST)),
        (17, ShopInfoModel(17, @r(app.media.shop_logo_17), "四川饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_RICE_LIST)),
        (18, ShopInfoModel(18, @r(app.media.shop_logo_18), "贵州饭店", "5.0", 300, ArrayList<String>("优选商家"), HomeConstants.FOOD_DISH_LIST)),
        (19, ShopInfoModel(19, @r(app.media.shop_logo_19), "云南饭店", "4.9", 400, ArrayList<String>("精品商家"), HomeConstants.FOOD_PACKAGE_LIST)),
        (20, ShopInfoModel(20, @r(app.media.shop_logo_20), "陕西饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_CONGEE_LIST)),
        (21, ShopInfoModel(21, @r(app.media.shop_logo_21), "甘肃饭店", "5.0", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_FRUIT_LIST)),
        (22, ShopInfoModel(22, @r(app.media.shop_logo_22), "青海饭店", "4.9", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_CAKE_LIST)),
        (23, ShopInfoModel(23, @r(app.media.shop_logo_23), "台湾饭店", "4.8", 500, ArrayList<String>("秒杀商家"), HomeConstants.FOOD_HAMBURG_LIST))
    ])


}