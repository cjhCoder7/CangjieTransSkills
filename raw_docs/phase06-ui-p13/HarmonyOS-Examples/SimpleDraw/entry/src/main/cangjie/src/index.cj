package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
internal import std.collection.*
internal import std.math.*

@Entry
@Component
class MyView {
    // obj记录触摸刚开始时捕捉到的对象
    @State
    var obj: Option<DPoint> = Option<DPoint>.None
    // tmpPoint用于临时存储
    var tmpPoint: ArrayList<DPoint> = ArrayList<DPoint>()
    // current用于切换不同的功能: 0, 1, 2, 3分别对应["移动", "绘点", "绘圆", "双击清空"]
    @State
    var current = 0
    @State
    var pointList: ObservedArrayList<DPoint> = ObservedArrayList<DPoint>()
    var circleList: ArrayList<DCircle> = ArrayList<DCircle>()
    @State // 由于circleList放入ForEach有性能问题，临时放一个多余的index，唯一作用就是绘制circleList
    var index: ObservedArrayList<Int64> = ObservedArrayList<Int64>()

    func build() {
        Column {
            功能按钮(pointList: pointList, circleList: circleList, current: current, index: index)
            // 由于Shape内限制使用自定义组件，故只能全部放到这里
            Shape() {
                // 绘制pointList
                ForEach(
                    pointList,
                    {
                        p: DPoint, _: Int64 => if (p.rule == 0 && p.visible) {
                            // 绘制无约束的自由点，颜色为黑色
                            Circle(width: 2.0 * pointRadius, height: 2.0 * pointRadius).offset(x: p.x - pointRadius,
                                y: p.y - pointRadius)
                        } else if (p.rule == 1 && p.visible) {
                            // 绘制依附在某个圆上的点，颜色为蓝色
                            if (let Some(c) <- p.theCircle) {
                                // 这里必须明确使用p.theDeg，使用模式匹配定义Some(theta)无法更新
                                Circle(width: 2.0 * pointRadius, height: 2.0 * pointRadius).offset(
                                    x: c.center.x + c.r * cos(p.theDeg.getOrThrow()) - pointRadius,
                                    y: c.center.y + c.r * sin(p.theDeg.getOrThrow()) - pointRadius
                                ).fill(Color.BLUE)
                            }
                        } else if (p.rule == 2 && p.visible) {
                            // 交点完全由相交的两个圆计算得出，不可移动，颜色为灰色
                            if (let (Some(c1), Some(c2)) <- (p.c1, p.c2)) {
                                Circle(width: 2.0 * pointRadius, height: 2.0 * pointRadius).offset(
                                    x: p.x - pointRadius,
                                    y: p.y - pointRadius
                                ).fill(Color.GRAY)
                            }
                        }
                    }
                )
                // 绘制circleList
                ForEach(
                    // 临时解决方案,
                    // 理论上应该声明circleList为ObservedArrayList, 然后放到ForEach内。
                    // 此处若这样做不知为何会导致严重的性能问题
                    index,
                    {
                        i: Int64, _: Int64 => if (i < circleList.size) {
//                            let c = circleList[i]
                            if (circleList[i].center.visible && circleList[i].p.visible) {
                                Circle(width: 2.0 * circleList[i].r, height: 2.0 * circleList[i].r).offset(x: circleList[i].center.x - circleList[i].r,
                                    y: circleList[i].center.y - circleList[i].r).fillOpacity(0.0).strokeWidth(2).stroke(Color.RED)
                            }
                        }
                    }
                )
            }.width(100.percent).height(100.percent).onTouch(
                // 触摸事件处理动态几何交互
                {
                event: TouchEvent => if (current == 0) {
                    if (event.eventType.toString() == "Down") {
                        // 获取触摸开始时的点，保存到obj中
                        obj = getPoint((event.touches[0].x, event.touches[0].y), pointList)
                    } else if (event.eventType.toString() == "Move") {
                        // 在手指移动过程中自动更新触摸到的点的位置
                        if (let Some(p) <- obj) {
                            点更新(p, event.touches[0].x, event.touches[0].y)
                        }
                    }
                }
            }).onClick(
                // 通过点击事件添加几何对象
                {
                event: ClickEvent => match (current) {
                    case 1 => 绘点(event, pointList, circleList)
                    case 2 => 绘圆(event, tmpPoint, pointList, circleList, index)
                    case _ => return
                }
            })
        }.width(100.percent).height(100.percent)
    }
}

@Component
class 功能按钮 {
    @Link
    var pointList: ObservedArrayList<DPoint>
    @Link
    var circleList: ArrayList<DCircle>
    @Link
    var current: Int64
    @Link
    var index: ObservedArrayList<Int64>

    let 按钮 = ["移动", "绘点", "绘圆", "双击清空"]

    func build() {
        Row {
            ForEach(
                按钮,
                {
                    a: String, i: Int64 => Button(a).onClick(
                        {
                            event: ClickEvent =>
                            if (current == 3) {
                                pointList.clear()
                                circleList.clear()
                                index.clear()
                            }
                            current = i
                        }
                    ).backgroundColor(if (current == i) {
                        Color.BLUE
                    } else {
                        Color.GRAY
                    })
                }
            )
        }.zIndex(10)
    }
}

// 根据触摸坐标(x, y)实时更新点p的坐标
func 点更新(p: DPoint, x: Float64, y: Float64): Unit {
    match (p.rule) {
        // 自由点直接更新坐标
        case 0 =>
            p.x = x
            p.y = y
            // 更新p之后还需要同时更新所有和p相关的点
            for (f in p.follower) {
                // f在和p相关的一个圆上
                if (let (Some(c), Some(theDeg)) <- (f.theCircle, f.theDeg)) {
                    f.x = c.center.x + c.r * cos(theDeg)
                    f.y = c.center.y + c.r * sin(theDeg)
                }
                // f为和p相关的某个圆的一个交点
                if (let (Some(c1), Some(c2)) <- (f.c1, f.c2)) {
                    // 交点无法保证永远存在
                    try {
                        f.x = 交点(c1, c2)[f.pos].x
                        f.y = 交点(c1, c2)[f.pos].y
                        // 确保有交点时重新恢复可见性
                        f.visible = true
                        for (p in f.follower) {
                            p.visible = true
                        }
                    } catch (e: Exception) {
                        // 无交点时交点计算会抛出异常，捕捉到后隐藏f。
                        f.visible = false
                        for (p in f.follower) {
                            p.visible = false
                        }
                    }
                }
                点更新(f, f.x, f.y)
            }
        // 圆上的点更新时不可脱离圆
        case 1 => if (let Some(c) <- p.theCircle) {
            p.theDeg = atan2(x - c.center.x, y - c.center.y)
            p.x = c.center.x + c.r * cos(p.theDeg.getOrThrow())
            p.y = c.center.y + c.r * sin(p.theDeg.getOrThrow())
        }
        // 交点无自由性，只可以跟随其他部分移动，无需处理。
        case 2 => return
        case _ => throw Exception("不支持的点！")
    }
}

// 根据点击坐标添加一个点
// 此处需要根据点击位置和已有几何物体的关系分别处理
func 绘点(event: ClickEvent, pointList: ObservedArrayList<DPoint>, circleList: ArrayList<DCircle>) {
    let x = event.x
    let y = event.y
    if (let Some(c) <- getCircle((x, y), circleList)) {
        // 点击位置在圆上，此时应该添加一个圆上点或者两圆交点
        if (let Some((c1, c2)) <- get2Circle((x, y), circleList)) {
            // 点击在两个圆上，表明添加一个圆圆交点
            let i = 交点(c1, c2)
            let x0 = i[0].x
            let y0 = i[0].y
            let x1 = i[1].x
            let y1 = i[1].y
            // 两个圆一般有两个交点，这里计算应该选择哪个交点，用pos表示
            var pos = 0
            if ((x1 - x) ** 2 + (y1 - y) ** 2 < (x0 - x) ** 2 + (y0 - y) ** 2) {
                pos = 1
            }
            // 创建交点
            let newPoint = DPoint(x: i[pos].x, y: i[pos].y)
            newPoint.pos = pos
            newPoint.rule = 2
            newPoint.c1 = c1
            newPoint.c2 = c2
            c1.center.follower.append(newPoint)
            c2.center.follower.append(newPoint)
            c1.p.follower.append(newPoint)
            c2.p.follower.append(newPoint)
            pointList.append(newPoint)
            let updatePoints = [c1.center, c2.center, c1.p, c2.p]
            for (i in 0..pointList.size) {
                let pt = pointList[i]
                for (u in updatePoints) {
                    if (pt.follower.contains(u)) {
                        pt.follower.append(newPoint)
                    }
                }
            }
        } else {
            // 吸附在圆上
            let theta = atan2(x - c.center.x, y - c.center.y)
            let newPoint = DPoint(x: c.center.x + c.r * cos(theta), y: c.center.y + c.r * sin(theta))
            newPoint.rule = 1
            newPoint.theDeg = theta
            newPoint.theCircle = c
            pointList.append(newPoint)
            c.center.follower.append(newPoint)
            c.p.follower.append(newPoint)
            let updatePoints = [c.center, c.p]
            for (i in 0..pointList.size) {
                let pt = pointList[i]
                for (u in updatePoints) {
                    if (pt.follower.contains(u)) {
                        pt.follower.append(newPoint)
                    }
                }
            }
        }
    }
    // 点击位置不在圆上
    if (let Some(obj) <- getPoint((x, y), pointList)) {
        // 点击到已有的点，无需处理
        return
    } else {
        // 点击到空白区域，创建一个自由点
        pointList.append(DPoint(x: x, y: y))
    }
}

// 等到用户点击两个点，然后构造圆
func 绘圆(event: ClickEvent, tmpPoint: ArrayList<DPoint>, pointList: ObservedArrayList<DPoint>,
    circleList: ArrayList<DCircle>, index: ObservedArrayList<Int64>) {
    // 收集两个点
    if (tmpPoint.size < 2) {
        let x = event.x
        let y = event.y
        if (let Some(obj) <- getPoint((x, y), pointList)) {
            tmpPoint.append(obj)
        }
    }
    // 收集完成后添加到circleList
    if (tmpPoint.size == 2) {
        circleList.append(DCircle(center: tmpPoint[0], p: tmpPoint[1]))
        index.append(index.size)
        tmpPoint.clear()
    }
}
