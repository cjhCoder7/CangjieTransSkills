/**
 * Created on 2025/1/19
 */
package ohos_app_cangjie_entry.color_picker

import ohos.state_manage.*
import ohos.state_macro_manage.*

@Observed
public class HSV {
    //色调 Hue 取值：0~360度
    @Publish
    var h: Float16 = 0.0
    //饱和度 Saturation 取值：0~100%
    @Publish
    var s: Float16 = 1.0
    //亮度 Value 取值：0~100%
    @Publish
    var v: Float16 = 1.0
}
