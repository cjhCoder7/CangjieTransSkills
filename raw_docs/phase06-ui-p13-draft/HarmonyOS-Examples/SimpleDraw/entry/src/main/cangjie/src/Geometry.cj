/**
 * Created on 2024/8/16
 * @file 几何.cj
 * @brief 关于点线圆的基础计算，摘抄自本人其他库。
 */
package ohos_app_cangjie_entry

import std.math.*
import std.math.numeric.*

// 浮点计算存在误差, 我们默认误差范围内的数相等
const 误差 = 0.0001

public func 约等于(a: Float64, b: Float64): Bool {
    return abs(a - b) < 误差
}
// 注意：角度函数的方向由坐标轴的定向决定
/**
 * @param a: 横坐标
 * @param b: 纵坐标
 * @brief 返回点(a,b)和x轴正向形成的角度
 */
public func atan2(a: Float64, b: Float64): Float64 {
    let d = sqrt(a ** 2 + b ** 2)
    let a1 = a / d
    let b1 = b / d
    var theta = acos(a1)
    if (b1 > 0.0) {
        return theta
    } else {
        return 2.0 * Float64.PI - theta
    }
}

public func atan2(p: 点): Float64 {
    return atan2(p.x, p.y)
}

// op绕到oq的角度
public func atan2(p: 点, q: 点) {
    if (atan2(p) < atan2(q)) {
        return atan2(q) - atan2(p)
    } else {
        return 2.0 * Float64.PI + atan2(q) - atan2(p)
    }
}

/**
 * @brief x.度
 * @bug `Float64`扩展度在0.53.4版本有问题，暂时使用deg
 */
extend Float64 {
    prop 度: Float64 {
        get() {
            this / 180.0 * Float64.PI
        }
    }
    prop deg: Float64 {
        get() {
            this / 180.0 * Float64.PI
        }
    }
}
// 整数度数自动转换成浮点度数
extend Int64 {
    prop 度: Float64 {
        get() {
            Float64(this).度
        }
    }
    prop deg: Float64 {
        get() {
            Float64(this).度
        }
    }
}

extend Float64 {
    operator func *(p: 点) {
        点(this * p.x, this * p.y)
    }
}

// 二维点，但同时也被当作二维向量定义了加减乘除
public class 点 <: ToString {
    var x: Float64
    var y: Float64

    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }

    public init(x: Int64, y: Int64) {
        this.x = Float64(x)
        this.y = Float64(y)
    }

    operator func ==(p: 点) {
        return x - p.x < 误差 && y - p.y < 误差
    }
    operator func +(p: 点) {
        return 点(x + p.x, y + p.y)
    }
    operator func -() {
        return 点(-x, -y)
    }
    operator func -(p: 点) {
        return this + (-p)
    }
    operator func *(p: 点) {
        return 点(x * p.x, y * p.y)
    }
    operator func /(num: Float64) {
        if (num == 0.0) {
            throw Exception("除零错误")
        }
        return 点(x / num, y / num)
    }

    // 归一
    func 标准化(): 点 {
        if (abs(x) < 误差 && abs(y) < 误差) {
            return this
        } else {
            let d = sqrt(x * x + y * y)
            return 点(x / d, y / d)
        }
    }

    func 旋转(theta: Float64) {
        return 点(x * cos(theta) - y * sin(theta), x * sin(theta) + y * cos(theta))
    }

    public func toString() {
        return [x, y].toString()
    }
}

func 点积(p: 点, q: 点): Float64 {
    return p.x * q.x + p.y * q.y
}

func 叉积(p: 点, q: 点): Float64 {
    return q.y * p.x - q.x * p.y
}

public class 直线 {
    var p: 点
    var q: 点

    init(p: 点, q: 点) {
        if (p == q) {
            throw Exception("两点必须不同")
        }
        this.p = p
        this.q = q
    }

    // 从直线一般方程a*x+b*y+c == 0构造直线
    public init(a: Float64, b: Float64, c: Float64) {
        if (a == 0.0) {
            this.p = 点(0.0, -c / b)
            this.q = 点(1.0, -c / b)
        } else if (b == 0.0) {
            this.p = 点(-c / a, 0.0)
            this.q = 点(-c / a, 1.0)
        } else {
            this.p = 点(0.0, -c / b)
            this.q = 点(1.0, -(a + c) / b)
        }
    }

    // 此处方向不同的直线不相等，需要修改
    operator func ==(l: 直线): Bool {
        let (a1, b1, c1) = this.一般方程()
        let (a2, b2, c2) = l.一般方程()
        return abs(a1 - a2) < 误差 && abs(b1 - b2) < 误差 && abs(c1 - c2) < 误差
    }

    func 方向(): 点 {
        return (q - p).标准化()
    }

    func 法向量(): 点 {
        return 方向().旋转(90.deg)
    }

    func 一般方程(): (Float64, Float64, Float64) {
        let a = 法向量().x
        let b = 法向量().y
        let c = -(a * p.x + b * p.y)

        return (a, b, c)
    }
}

public class 圆 {
    var 圆心: 点
    var 半径: Float64

    public init(圆心: 点, 半径: Float64) {
        if (半径 <= 0.0) {
            throw IllegalArgumentException("半径必须为正数！")
        }
        this.圆心 = 圆心
        this.半径 = 半径
    }
    public init(圆心: 点, 半径: Int64) {
        if (半径 <= 0) {
            throw IllegalArgumentException("半径必须为正数！")
        }
        this.圆心 = 圆心
        this.半径 = Float64(半径)
    }

    func 圆上(p: 点): Bool {
        return abs((p.x - 圆心.x) ** 2 + (p.y - 圆心.y) ** 2 - 半径 ** 2) < 误差
    }

    func 圆内(p: 点): Bool {
        return (p.x - 圆心.x) ** 2 + (p.y - 圆心.y) ** 2 < 半径 ** 2
    }

    func 圆外(p: 点): Bool {
        return (p.x - 圆心.x) ** 2 + (p.y - 圆心.y) ** 2 > 半径 ** 2
    }

    func 面积() {
        return Float64.PI * 半径 * 半径
    }

    func 周长() {
        return 2.0 * Float64.PI * 半径
    }
}

func 投影(p: 点, l: 直线): 点 {
    let d = 有向距离(p, l)
    return p - d * l.法向量()
}

func 距离(p: 点, q: 点): Float64 {
    return sqrt((p.x - q.x) ** 2 + (p.y - q.y) ** 2)
}

func 距离(c: 圆, p: 点): Float64 {
    return 距离(c.圆心, p)
}

func 距离(p: 点, c: 圆): Float64 {
    return 距离(c, p)
}

// 以法向量方向为正
func 有向距离(p: 点, l: 直线): Float64 {
    let (a, b, c) = l.一般方程()
    return a * p.x + b * p.y + c
}

func 距离(p: 点, l: 直线): Float64 {
    let (a, b, c) = l.一般方程()
    return abs(a * p.x + b * p.y + c)
}

func 距离(l: 直线, p: 点): Float64 {
    let (a, b, c) = l.一般方程()
    return abs(a * p.x + b * p.y + c)
}

func det(a: Float64, b: Float64, c: Float64, d: Float64): Float64 {
    return a * d - b * c
}

public func 交点(l: 直线, m: 直线): Array<点> {
    let (a, b, c) = l.一般方程()
    let (a2, b2, c2) = m.一般方程()
    let d = a * b2 - b * a2
    if (l == m || abs(d) < 误差) {
        return []
    }
    return [点((b * c2 - c * b2) / d, (c * a2 - a * c2) / d)]
}

func 交点(l: 直线, c: 圆): Array<点> {
    let d = 距离(l, c.圆心)
    let p = 投影(c.圆心, l)
    let s = sqrt(c.半径 ** 2 - d ** 2)
    if (d > 误差 + c.半径) {
        return []
    } else if (abs(d - c.半径) < 误差) {
        return [p]
    } else {
        return [p + s * l.方向(), p - s * l.方向()]
    }
}
// 两圆交点，按照与c1c2的圆心连线所成角度排序
public func 交点(c1: 圆, c2: 圆): Array<点> {
    let r1 = c1.半径
    let r2 = c2.半径
    let a1 = c1.圆心.x
    let b1 = c1.圆心.y
    let a2 = c2.圆心.x
    let b2 = c2.圆心.y
    let d = 距离(c1.圆心, c2.圆心)
    // 交线方程c1 - c2 = a*x+b*y+c
    let (a, b, c) = (2.0 * (a2 - a1), 2.0 * (b2 - b1), a1 ** 2 + b1 ** 2 - a2 ** 2 - b2 ** 2 - r1 ** 2 + r2 ** 2)
    let l = 直线(a, b, c)
    if (d > r1 + r2 || d < abs(r1 - r2)) {
        return []
    } else if (约等于(d, r1 + r2)) {
        return [投影(c1.圆心, l)]
    } else if (约等于(d, abs(r1 - r2))) {
        return [投影(c1.圆心, l)]
    } else {
        let d1 = 距离(l, c1.圆心)
        let step = sqrt(r1 ** 2 - d1 ** 2)
        let p = 投影(c1.圆心, l)
        let 方向 = (c2.圆心 - c1.圆心).标准化().旋转(90.度)
        return [p + step * 方向, p - step * 方向]
    }
}

