/**
 * Created on 2024/8/15
 */
package ohos_app_cangjie_entry

import ohos.state_macro_manage.*
import std.math.*
import std.collection.*

// D = Dynamic
// 定义动态几何需要使用的几何类

// 点的默认半径
const pointRadius = 5.0

// 动点
@Observed
public class DPoint {
    @Publish
    var x: Float64 = 0.0
    @Publish
    var y: Float64 = 0.0

    // 显隐控制
    @Publish
    var visible = true
    // 记录受该点影响的其它点，用于动态更新
    var follower: ArrayList<DPoint> = ArrayList<DPoint>()

    // rule取值为0,1,2
    // 默认值0表示该点为自由移动点
    var rule = 0
    //  rule = 1 表示点在圆上，theCircle为点所在圆，theDeg为该点相对于theCircle的度数
    @Publish
    var theCircle: Option<DCircle> = Option<DCircle>.None
    @Publish
    var theDeg: Option<Float64> = Option<Float64>.None
    // rule = 2 表示点为两圆c1, c2的交点, pos = 0,1 表示选择第一个还是第二个交点
    var c1: Option<DCircle> = Option<DCircle>.None
    var c2: Option<DCircle> = Option<DCircle>.None
    var pos: Int64 = 0
}
// 动圆
@Observed
public class DCircle {
    @Publish
    var center: DPoint

    // 圆上一点
    @Publish
    var p: DPoint

    // 半径
    prop r: Float64 {
        get() {
            return sqrt((p.x - center.x) ** 2 + (p.y - center.y) ** 2)
        }
    }
}

@Observed
public class DLine {
    @Publish
    var p: DPoint
    @Publish
    var q: DPoint
}

extend DCircle <: ToString {
    public func toString() {
        return [this.center.x, this.center.y, this.r].toString()
    }
}

extend DPoint <: Equatable<DPoint> {
    public operator func ==(that: DPoint) {
        return refEq(this, that)
    }

    public operator func !=(that: DPoint) {
        return !(this == that)
    }
}

// 默认事件无法满足要求,需要自行定义并且绑定到Shape然后自行使用下面的三个函数处理
// getPoint获取离pos最近的点(< 20.0)，否则为None
func getPoint(pos: (Float64, Float64), pointList: ObservedArrayList<DPoint>): Option<DPoint> {
    let x = pos[0]
    let y = pos[1]

    var minPosition = -1
    var minDistance = Float64.Max

    for (i in 0..pointList.size) {
        let p = pointList[i]
        if (sqrt((p.x - x) ** 2 + (p.y - y) ** 2) < minDistance) {
            minPosition = i
            minDistance = sqrt((p.x - x) ** 2 + (p.y - y) ** 2)
        }
    }
    if (minDistance > 20.0) {
        return None
    } else {
        return pointList[minPosition]
    }
}
// getCircle获取离pos最近的圆(<20.0)，否则为None
func getCircle(pos: (Float64, Float64), circleList: ArrayList<DCircle>): Option<DCircle> {
    if (circleList.size == 0) {
        return None
    }

    let x = pos[0]
    let y = pos[1]

    var minPosition = -1
    var minDistance = Float64.Max

    for (i in 0..circleList.size) {
        let c = circleList[i].center
        let r = circleList[i].r
        if (abs(sqrt((c.x - x) ** 2 + (c.y - y) ** 2) - r) < minDistance) {
            minPosition = i
            minDistance = abs(sqrt((c.x - x) ** 2 + (c.y - y) ** 2) - r)
        }
    }
    if (minDistance > 20.0) {
        return None
    } else {
        return circleList[minPosition]
    }
}

// get2Circle获取离点击点最近的两个圆，若点击位置不在两个圆旁边，则返回None
func get2Circle(pos: (Float64, Float64), circleList: ArrayList<DCircle>): Option<(DCircle, DCircle)> {
    if (circleList.size == 0) {
        return None
    }

    let x = pos[0]
    let y = pos[1]

    let minPosition = ArrayList<Int64>()
    let minDistance = 20.0

    for (i in 0..circleList.size) {
        let c = circleList[i].center
        let r = circleList[i].r
        let d = abs(sqrt((c.x - x) ** 2 + (c.y - y) ** 2) - r)
        if (d < minDistance) {
            minPosition.append(i)
        }
    }

    if (minPosition.size < 2) {
        return None
    } else {
        return (circleList[minPosition[0]], circleList[minPosition[1]])
    }
}

// 计算两个圆的交点，复用Geometry.cj中的函数
func 交点(c1: DCircle, c2: DCircle): Array<点> {
    let c11 = 圆(点(c1.center.x, c1.center.y), c1.r)
    let c21 = 圆(点(c2.center.x, c2.center.y), c2.r)
    return 交点(c11, c21)
}

func 距离(pos: (Float64, Float64), q: DPoint) {
    return sqrt((q.x - pos[0]) ** 2 + (q.y - pos[1]) ** 2)
}

func 距离(pos: (Float64, Float64), c: DCircle) {
    return abs(距离(pos, c.center) - c.r)
}

func 距离(pos: (Float64, Float64), l: DLine) {
    距离(点(pos[0], pos[1]), 直线(点(l.p.x, l.p.y), 点(l.q.x, l.q.y)))
}
