/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.utils


/**
* @param index Int64 当前组件的序号, 单数是有颜色的, 双数是没颜色的
* @param colorArr Array<UInt32> 在两个颜色之间转换
* @return UInt32 具体的颜色
*/
public func interColor(index: Int64, colorArr: Array<UInt32>): UInt32 {
    if ((index & 1) == 1) {
        return colorArr[0]
    } else {
        return colorArr[1]
    }
}