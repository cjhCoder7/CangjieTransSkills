package ohos_app_cangjie_entry
import ohos_app_cangjie_entry.components.index.*

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry
@Component
class IndexView {
  // 主页面渲染
  func build() {
    // 滚动组件,内部内容超越父组件的时候可以上下滚动
    Scroll() {
      // 可滑动组件Scroll只能有一个子组件,所以后面的都要封装
      Column() {
        // 标题
        Text("UIPlayground").fontSize(40).margin(top: 50, bottom: 75)

        Column(20) {
          Row(20) {
            // 文本Text
            IndexText()
            // 按钮Button
            IndexButton()
          }

          // 图片Image
          IndexImage()
          // 输入框TextInput
          IndexTextInput()

          Row(20) {
            // 多选框CheckBox
            IndexCheckBox()
            // 消息Badge
            IndexBadge()
          }

          // 滑动条组件Slider
          IndexMusicPlayer()
          // 轮播Swiper
          IndexSwiper()
          // 页面切换Tabs
          IndexTab()
        }.width(100.percent)
      }.padding(20)
    }
  }
}
