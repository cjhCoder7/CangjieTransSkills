package ohos_app_cangjie_entry.cube

type Vector = Array<(Face, Int64)>
type Matrix = Array<Vector>

// 标识行/列的索引
enum Index {
    Row(Int64) | Col(Int64) | Inv(Index)
    // 用于标记向量倒置
    public operator func -(): Index {
        match (this) {
            case Inv(v) => v
            case _ => Inv(this)
        }
    }

    // 去掉 Inv 符号
    public func value(): Index {
        match (this) {
            case Inv(v) => v
            case _ => this
        }
    }
}

extend Matrix {
    // 给指定的魔方面创建初始矩阵
    public static func create(face: Face) {
        Matrix(3, { i =>
            Vector(3, { j => (face, 3 * i + j + 1)})
        })
    }

    // 获取矩阵的行或列
    public operator func [](index: Index): Vector {
        match (index) {
            case Row(r) => this[r].clone()
            case Col(c) => Vector(this.size, { i => this[i][c] })
            case Inv(i) => this[i] // 应用场景需要，取值时忽略符号、不做倒置
        }
    }

    // 给矩阵的行或列赋值
    public func set(index: Index, value: Vector): Unit {
        match (index) {
            case Row(r) => this[r] = value
            case Col(c) =>
                for (i in 0..value.size) {
                    this[i][c] = value[i]
                }
            case Inv(i) => // 赋值时根据 index 符号做倒置
                value.reverse()
                this.set(i, value)
        }
    }
}

// 直接用以上 enum 表示行列索引还不够优雅，我们为整型扩展两个属性，让索引数值可以直接标记行列
extend Int64 {
    public prop r: Index {
        get() { Row(this) }
    }
    public prop c: Index {
        get() { Col(this) }
    }
}
