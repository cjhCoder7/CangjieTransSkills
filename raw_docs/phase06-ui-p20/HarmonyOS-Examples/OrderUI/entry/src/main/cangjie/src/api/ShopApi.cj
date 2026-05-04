/**
 * Created on 2024/8/13
 */
package ohos_app_cangjie_entry.api
import ohos.base.AppLog
import std.collection.{ArrayList}
import ohos_app_cangjie_entry.models.{ShopInfoModel}
import ohos_app_cangjie_entry.constants.*
import std.sync.*
import std.time.*
public class ShopApi {
    public static func getShopList(tempPage: Int64, pageSize: Int64 ): ArrayList<ShopInfoModel> {
        AppLog.info("---------------- ShopApi getShopList start")
        sleep(Duration.millisecond * 500)
        AppLog.info("---------------- ShopApi getShopList end")
        let result = ArrayList<ShopInfoModel>()
        if (tempPage < 1) {
            return result
        }
        let totalSize = HomeConstants.SHOP_INFO_MAP.size
        let startIndex = (tempPage - 1) * pageSize
        let endIndex = tempPage * pageSize
        for(index in startIndex..endIndex where index < totalSize) {
            let shopInfoModel = HomeConstants.SHOP_INFO_MAP.get(index + 1).getOrThrow()
            result.append(shopInfoModel)
        }
        return result
    }
}