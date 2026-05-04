/**
 * Created on 2024/8/24
 */
package ohos_app_cangjie_entry.utils

import ohos.display.*

// 获取设备屏幕规格: xs｜sm｜md｜lg
public func getScreenType(): String {
    let display: Display = getDefaultDisplaySync()
    let width = Float32(display.width) / display.densityPixels // px -> vp
    HiLog.info("Display Width: ${display.width}px / ${display.densityPixels} = ${width}vp")
    // 根据宽度判断设备类型
    if (width < 320.0) {
        'xs'
    } else if (width < 600.0) {
        'sm'
    } else if (width < 840.0) {
        'md'
    } else {
        'lg'
    }
}
