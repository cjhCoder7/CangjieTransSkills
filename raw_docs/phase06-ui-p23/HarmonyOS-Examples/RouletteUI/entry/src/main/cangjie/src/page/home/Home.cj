/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry.page.home

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app

@Component
public class Home {

	func build() {
        Column(){
            homeTop()
            homeBody()
        }
        .home()
	}
}

