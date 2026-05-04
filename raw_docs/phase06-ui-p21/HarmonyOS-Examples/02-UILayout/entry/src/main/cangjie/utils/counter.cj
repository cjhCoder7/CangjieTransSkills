/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.utils


const defaultDesignWidth: Int64 = 720
/**
* @param outerWidth Int64 最外层的宽度(在使用时主要是面板本身的宽度)
* @param padding Int64 外层容器的内边距
* @return Int64 内部内容的宽度
*/
public func countInnerWidth(outerWidth: Int64, padding: Int64): Int64 {
    return outerWidth - 2 * padding
}


/**
* @param innerWidth Int64 容器内部可渲染的宽度
* @param space Int64 Row的space参数
* @param num Int64 子元素的数量(平均分)
* @return Int64 子元素的宽度
*/
public func countSubWidth(innerWidth: Int64, space: Int64, num: Int64) {
    return (innerWidth - space * (num - 1)) / num
}