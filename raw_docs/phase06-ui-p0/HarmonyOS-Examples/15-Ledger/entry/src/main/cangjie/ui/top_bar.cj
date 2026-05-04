/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.ui

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.app

@Component
public class TopBar {

  public func build() {
    Row {
      Image(@r(app.media.arrow_left)).size(width: 36, height: 36).margin(8)

      Text(@r(app.string.TITLE)).fontSize(20).fontWeight(W600).margin(15).layoutWeight(1)
    }
    .width(100.percent)
    .height(48)
    .margin(16)
  }
}