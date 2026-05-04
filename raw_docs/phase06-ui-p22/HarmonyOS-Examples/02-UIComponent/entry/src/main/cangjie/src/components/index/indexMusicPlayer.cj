package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import std.format.*
import std.math.floor
import std.time.Duration
import std.sync.Timer

@Component
public class IndexMusicPlayer {
  // 时间滑动的值
  @State var timeSliderValue: Float64 = 0.0

  // 是否正在播放
  @State var onPlaying: Bool = false

  // 计时器
  var timer : Option<Timer> = None

  // 正在播放音乐
  func playing() {
    // 如果音乐已经播放到末尾,则停止并归零
    if (this.timeSliderValue >= 269.0) {
      this.onPlaying = false
      this.timer.getOrThrow().cancel()
    } else {
      this.timeSliderValue += 1.0
    }
  }

  // 开始/暂停播放音乐
  func playHandler() {
    // 如果音乐已经播放到末尾,则重置
    if (this.timeSliderValue >= 269.0) {
      this.timeSliderValue = 0.0
    }
    this.onPlaying = !this.onPlaying
    // 开始播放
    if (this.onPlaying) {
      // 设定一个计时器来重复运行playing函数
      this.timer = Timer.repeat(Duration.second,Duration.second,this.playing)
    } else {
      this.timer.getOrThrow().cancel()
    }
  }

  func build() {
    Column() {
      Text("Slider").outerTitle()

      Column() {
        Row() {
          // 左侧图片
          Row() {
            Image(@r(app.media.jay_zhou))
            .width(160)
            .height(160)
            .borderRadius(10)
            .objectFit(ImageFit.Cover)
          }

          // 右侧文字
          Column() {
            Text("晴天").fontSize(28)
            .fontWeight(FontWeight.W800).margin(bottom: 10)

            Text("周杰伦").fontSize(18)
            .fontColor(0x6c757d).margin(bottom: 15)

            Column(5) {
              Text("故事的小黄花").fontSize(14)
              .fontWeight(FontWeight.W300)

              Text("从出生那年就飘着").fontSize(16)
              .fontWeight(FontWeight.W600)

              Text("童年的荡秋千").fontSize(14)
              .fontWeight(FontWeight.W300)

              Text("...").fontSize(12)
              .fontWeight(FontWeight.W300)
            }.alignItems(HorizontalAlign.Start)
          }.layoutWeight(1).padding(left: 15)
          .alignItems(HorizontalAlign.Start)
        }.width(100.percent)
        .padding(top: 40, left: 20, right: 20)
        .alignItems(VerticalAlign.Top)

        Column(10) {
          // 播放进度的滑块
          Slider(
            value: timeSliderValue,
            min: 0.0,
            max: 269.0,
            step: 1.0,
            style: SliderStyle.OutSet
          ).blockColor(0x161315)  // 滑块颜色
          .trackColor(0x9b80a6)  // 滑轨背景色
          .selectedColor(0x161315)  // 滑块已滑动部分颜色
          .showSteps(false)  // 不显示步长刻度
          .showTips(false)  // 不显示
          .onChange({
            value: Float64, mode: SliderChangeMode => timeSliderValue = value
          })

          // 时间显示
          Row() {
            // 当前已播放时间,format函数会在秒数小于10时自动在前面补0
            Text(
              "${Int64(floor(this.timeSliderValue / 60.0))}:${(Int64(this.timeSliderValue) % 60).format("02")}"
            )

            // 总时间
            Text("${Int64(269 / 60)}:${(269 % 60).format("02")}")
          }.width(100.percent)
          .justifyContent(FlexAlign.SpaceBetween)

          // 播放按钮
          Row() {
            Image(@r(app.media.previous_music))
            .width(40)
            .height(40)

            // 正在播放
            if (this.onPlaying) {
              Image(@r(app.media.stop))
              .width(60)
              .height(60)
              .rotate(180.0)
              .onClick({e =>this.playHandler()})
            } else {
              Image(@r(app.media.play_music))
              .width(60)
              .height(60)
              .rotate(180.0)
              .onClick({e =>this.playHandler()})
            }

            Image(@r(app.media.previous_music))
            .width(40)
            .height(40)
            .rotate(180.0)  // 旋转180度
          }.width(100.percent).padding(20)
          .justifyContent(FlexAlign.SpaceBetween)
        }.padding(20)
        .alignItems(HorizontalAlign.Start)
      }.width(100.percent).shadow(radius: 20, color: Color(0xb2afb0))
    }.card().width(100.percent)
    .redirect("SliderView")
  }
}