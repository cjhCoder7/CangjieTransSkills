/**
 * Created on 2025/2/13
 */
package ohos_app_cangjie_entry.color_picker

import ohos.base.*
import encoding.hex.*
import std.math.*

//颜色处理的工具类
public class ColorUtils {

    // 将RGB颜色值转换为HSV颜色空间
    public static func rgbToHsv(colorValue: UInt32): HSV {
        // 提取红色分量，并将其转换为Float16类型
        let rInt: Float16 = Float16((colorValue >> 16) & 0xFF)
        // 提取绿色分量，并将其转换为Float16类型
        let gInt: Float16 = Float16((colorValue >> 8) & 0xFF)
        // 提取蓝色分量，并将其转换为Float16类型
        let bInt: Float16 = Float16(colorValue & 0xFF)
        // 将红色分量归一化到[0, 1]范围
        let rNorm: Float16 = rInt / 255.0
        // 将绿色分量归一化到[0, 1]范围
        let gNorm: Float16 = gInt / 255.0
        // 将蓝色分量归一化到[0, 1]范围
        let bNorm: Float16 = bInt / 255.0

        // 计算RGB分量的最大值
        let maxVal = max(max(rNorm, gNorm), bNorm)
        // 计算RGB分量的最小值
        let minVal = min(min(rNorm, gNorm), bNorm)
        // 计算最大值与最小值的差值
        let delta = maxVal - minVal

        // 创建HSV对象
        let hsv = HSV()
        // 设置HSV的V（亮度）值为最大值
        hsv.v = maxVal

        // 如果差值不为0，计算色相（H）和饱和度（S）
        if (delta != 0.0) {
            // 根据最大值所在的颜色分量计算色相
            if (maxVal == rNorm) {
                hsv.h = ((gNorm - bNorm) / delta) * 60.0
            } else if (maxVal == gNorm) {
                hsv.h = ((bNorm - rNorm) / delta + 2.0) * 60.0
            } else {
                hsv.h = ((rNorm - gNorm) / delta + 4.0) * 60.0
            }
            // 如果色相小于0，将其调整到[0, 360]范围
            if (hsv.h < 0.0) {
                hsv.h += 360.0
            }
        }

        // 计算饱和度（S）
        hsv.s = if (maxVal == 0.0) {
            0.0
        } else {
            delta / maxVal
        }
        // 返回HSV对象
        return hsv
    }

    // 将RGB分量打包为一个UInt32类型的颜色值
    public static func packRGB(r: UInt8, g: UInt8, b: UInt8): UInt32 {
        return UInt32((UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b))
    }

    // 将HSV颜色空间转换为RGB颜色值
    public static func hsvToRgb(h: Float16, s: Float16, v: Float16): UInt32 {
        // 初始化RGB值
        var r: Float16 = 0.0
        var g: Float16 = 0.0
        var b: Float16 = 0.0

        // 将色相限制在[0, 360]范围内
        let clampedH = max(0.0, min(360.0, h))
        // 将饱和度限制在[0, 1]范围内
        let clampedS = max(0.0, min(1.0, s))
        // 将亮度限制在[0, 1]范围内
        let clampedV = max(0.0, min(1.0, v))

        // 计算色相所在的区间
        let hSegment: Float16 = if (clampedH == 360.0) {
            0.0
        } else {
            clampedH / 60.0
        }
        // 计算色相所在的区间索引
        let segmentIndex: Int16 = Int16(hSegment) % 6
        // 计算色相在区间内的小数部分
        let fractional: Float16 = hSegment - Float16(segmentIndex)

        // 计算中间值
        let p: Float16 = clampedV * (1.0 - clampedS)
        let q: Float16 = clampedV * (1.0 - fractional * clampedS)
        let t: Float16 = clampedV * (1.0 - (1.0 - fractional) * clampedS)

        // 根据色相所在的区间计算RGB值
        match (segmentIndex) {
            // 当色相在0-60度之间
            case 0 =>
                r = clampedV // 红色分量等于亮度值
                g = t // 绿色分量等于中间值t
                b = p // 蓝色分量等于中间值p

            // 当色相在60-120度之间
            case 1 =>
                r = q // 红色分量等于中间值q
                g = clampedV // 绿色分量等于亮度值
                b = p // 蓝色分量等于中间值p

            // 当色相在120-180度之间
            case 2 =>
                r = p // 红色分量等于中间值p
                g = clampedV // 绿色分量等于亮度值
                b = t // 蓝色分量等于中间值t

            // 当色相在180-240度之间
            case 3 =>
                r = p // 红色分量等于中间值p
                g = q // 绿色分量等于中间值q
                b = clampedV // 蓝色分量等于亮度值

            // 当色相在240-300度之间
            case 4 =>
                r = t // 红色分量等于中间值t
                g = p // 绿色分量等于中间值p
                b = clampedV // 蓝色分量等于亮度值

            // 当色相在300-360度之间
            case 5 =>
                r = clampedV // 红色分量等于亮度值
                g = p // 绿色分量等于中间值p
                b = q // 蓝色分量等于中间值q

            // 默认情况（理论上不会发生）
            case _ =>
                r = 0.0 // 红色分量为0
                g = 0.0 // 绿色分量为0
                b = 0.0 // 蓝色分量为0
        }

        // 将RGB值从[0, 1]范围转换到[0, 255]范围
        let rInt = UInt8(round(r * 255.0))
        let gInt = UInt8(round(g * 255.0))
        let bInt = UInt8(round(b * 255.0))

        // 打包RGB值为UInt32类型并返回
        return packRGB(rInt, gInt, bInt)
    }
}
