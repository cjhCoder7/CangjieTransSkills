/**
 * Created on 2024/8/10
 */
package ohos_app_cangjie_entry.components.me

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app

@Component
public class Me {

    @Builder
    func builder3(string3: String) {
        Row() {
            Text(string3)
        }
    }

    @Builder
    func builder2(string2:String, string3: String) {
        Row() {
            Text(string2)
            builder3(string3)
        }
    }

    @Builder
    func builder1(string1: String, string2:String, string3: String) {
        Row() {
            Text(string1)
            builder2(string2, string3)
        }
    }

    func build() {
        Column() {
            Row() {
                builder1("111111111", "22222222222", "33333333333333")
            }
        }
        .height(100.percent)
        .width(100.percent)
        .backgroundColor(@r(app.color.background_secondary))
        .padding(top: 0,right: 10, bottom: 0, left: 10)
    }
}