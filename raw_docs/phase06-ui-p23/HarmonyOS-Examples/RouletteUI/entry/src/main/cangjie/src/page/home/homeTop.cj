/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry.page.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*


@Component
public class homeTop {

	func build() {
        Row(){
            Image(@rawfile("ic_setting.png"))
            .topImg()
            Blank()
            Image(@rawfile("ic_turntable_setting.png"))
            .topImg().redirect("PublicPage","转盘列表")
        }
        .width(95.percent)
	}
}

