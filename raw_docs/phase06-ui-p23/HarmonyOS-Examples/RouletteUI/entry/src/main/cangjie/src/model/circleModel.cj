/**
 * Created on 2024/8/31
 */
package ohos_app_cangjie_entry.model

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.ArrayList
import cj_res_entry.app

public class CircleModel {
    //圆的x轴坐标
    var circle_X: Float64
    //圆的y轴坐标
    var circle_Y: Float64
    //圆的半径
    var circle_Radius: Float64
    //弧线的开始弧度
    var circle_startAngle:Float64
    //弧线的终止弧度
    var circle_endAngle:Float64
    public CircleModel(circle_X: Float64, circle_Y: Float64, circle_Radius: Float64,circle_startAngle:Float64,circle_endAngle:Float64) {
        this.circle_X = circle_X
        this.circle_Y = circle_Y
        this.circle_Radius = circle_Radius
        this.circle_startAngle = circle_startAngle
        this.circle_endAngle = circle_endAngle
    }

    public func getCircleX(): Float64 {
        this.circle_X
    }
    public func getCircleY(): Float64 {
        this.circle_Y
    }

    public func getCircleRadius(): Float64 {
        this.circle_Radius
    }
        public func getCircleStartAngle(): Float64 {
        this.circle_startAngle
    }
        public func getCircleEndAngle(): Float64 {
        this.circle_endAngle
    }
}
