/**
 * Created on 2024/9/7
 */
package ohos_app_cangjie_entry.model


import ohos.base.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app

public class TabItemData {
    public TabItemData(
        //未选中时的图片
        public let nor_img:CJResource,
        //选中时的图片
        public let sel_img:CJResource,
        public let text:String
    ){}
}


public let TabList: Array<TabItemData> = [
    TabItemData(@r(app.media.ic_turntable_nor),@r(app.media.ic_turntable_sel),"转盘"),
    TabItemData(@r(app.media.ic_random_nor),@r(app.media.ic_random_sel),"随机数"),
    TabItemData(@r(app.media.ic_more_nor),@r(app.media.ic_more_sel),"更多")
    ]