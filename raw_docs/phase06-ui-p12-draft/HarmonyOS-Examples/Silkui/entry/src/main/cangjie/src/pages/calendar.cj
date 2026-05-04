/**
 * Created on 2025/5/9
 */
package ohos_app_cangjie_entry.pages


internal import ohos.base.LengthProp
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.Router

@Entry
@Component
class CalendarPage {
    func build () {
        Column(30){
            Button("None")
            .onClick{
                _=>
                    Router.push(url: "CalendarNonePage")
            }
            Button("Month")
            .onClick{
                _=>
                    Router.push(url: "CalendarMonthPage")
            }
            Button("YearMoth")
            .onClick{
                _=>
                    Router.push(url: "CalendarYearMonthPage")
            }
        }
        .justifyContent(FlexAlign.Center)
        .width(100.percent)
        .height(100.percent)
    }
}