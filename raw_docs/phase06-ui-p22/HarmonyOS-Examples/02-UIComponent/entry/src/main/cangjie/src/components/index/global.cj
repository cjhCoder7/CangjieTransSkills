/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index
import ohos.base.*
import ohos.component.*
import ohos.router.*

extend Column {
  // 因为卡片是上下布局的,所以通过Column来扩展
  // 这个只是主页面的卡片,和子页面中的card还是有不同的
  func card() {
  this.borderRadius(10).justifyContent(FlexAlign.SpaceBetween)
  .alignItems(HorizontalAlign.Start)
  }

  // 点击卡片重定向到子页面
  func redirect(url: String) {
  this.onClick({
    e: ClickEvent => Router.push(url: url)
  })
  }
}

extend Button {
  // 圆角按钮
  func rounded() {
  this.shape(ShapeType.Normal).borderRadius(6.fp)
  }
}

extend Text {
  // 标题文本,包含字体大小和字重
  func title() {
  this.fontSize(32).fontWeight(FontWeight.W200)
  }

  // Badge 消息来源名的字体
  func msgTitle() {
  this.fontSize(20).fontWeight(FontWeight.Medium)
  }

  // 外部的标题文本
  func outerTitle() {
  this.title().padding(bottom: 5)
    .borderWidth(EdgeWidths(bottom: 1.vp))
    .margin(bottom: 20)
  }
}