package ohos_app_cangjie_entry

import ohos_app_cangjie_entry.component.*
import ohos_app_cangjie_entry.common.*
internal import ohos.base.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.component.*
import ohos.concurrency.launch
import std.sync.*
import std.time.*

@Entry
@Component
class EntryView {
    @State var progress: Float64 = 0.0
    var timer: ?Timer = None

    protected override func onPageShow() {
        timer = Timer.repeat(Duration.Zero, Duration.second, { =>
            launch {
                if (progress >= MUSIC_TIME) {
                    progress = 0.0
                } else {
                    progress += 1.0
                }
            }
        }, style: CatchupStyle.Skip)
    }

    protected override func onPageHide(): Unit {
        timer?.cancel()
    }

    func build() {
        Column {
            Head()
            Content()
            Pannel(value: progress)
        }
        .width(100.percent)
        .height(100.percent)
        .expandSafeArea()
        .backgroundColor(@r(app.color.music_list_bg_color))
    }
}
