/**
 * Created on 2024/7/30
 */
package ohos_app_cangjie_entry.components.index

import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.resource_manager.*
import cj_res_entry.app

@Component
public class IndexImage {
  func build() {
    Column() {
      Text("IMAGE").outerTitle()

      Image(@r(app.media.hc_2024_cn)).height(160.vp)
      .objectFit(ImageFit.Cover)
      .borderRadius(bottomLeft: 10.vp, bottomRight: 10.vp)
    }.card().width(100.percent).height(220)
    .redirect("ImageView")
  }
}