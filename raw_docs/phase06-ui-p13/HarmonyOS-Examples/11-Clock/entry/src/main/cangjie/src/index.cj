package ohos_app_cangjie_entry

import ohos_app_cangjie_entry.utils.*
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.display.*
import ohos.concurrency.launch

import std.time.*
import std.sync.*
import std.format.*

@Entry
@Component
class EntryView {
    var width: Float64 = 360.0
    let height: Float64 = width + 140.0 // 底部显示时间文本
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    var timer: ?Timer = None

    protected override func onPageShow() {
        let clock = Clock(context, width)
        this.timer = Timer.repeat(Duration.Zero, Duration.second, { =>
            launch {
                context.clearRect(0.0, 0.0, width, height)
                clock.draw(DateTime.now())
            }
        }, style: CatchupStyle.Skip)
    }

    protected override func onPageHide(): Unit {
        this.timer?.cancel()
    }

    protected override func aboutToAppear() {
        let display: Display = getDefaultDisplaySync()
        width = if (display.width > display.height) {
            Float64(display.height) * 0.25
        } else {
            Float64(display.width) * 0.25
        }
    }

    func build() {
        Column {
            Canvas(this.context).padding(top: 76).width(width).height(height)
        }.width(100.percent).height(100.percent)
    }
}
