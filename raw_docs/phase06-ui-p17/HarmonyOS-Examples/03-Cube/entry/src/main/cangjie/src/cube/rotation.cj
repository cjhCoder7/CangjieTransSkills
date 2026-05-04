package ohos_app_cangjie_entry.cube

public enum Rotation <: ToString & Hashable & Equatable<Rotation> {
    // 在魔方研究中，通常用 Front/Back/Left/Right/Up/Down 表示六个面以及对应的原子操作，即正对此面顺时针旋转 90 度
    F | B | L | R | U | D
      | X(Rotation, Rotation) // 仓颉支持 enum 构造器和递归定义，此处 X 用于组织复合旋转操作
      | I(Rotation) // I(r) 用于表示 r 的逆变换，即正对 r 面逆时针旋转 90 度

    // enum 中也可以定义成员函数，这里我们重载 * 运算符以实现旋转操作的组合，由此可生成一个置换群
    public operator func *(that: Rotation): Rotation {
        match (this) {
            case X(x1, x2) => X(x1, X(x2, that)) // 按此顺序分解重组，使得递归时按从左到右的顺序执行变换
            case _ => X(this, that)
        }
    }

    // 重载 ** 运算符实现幂运算，以便表示和验证高阶置换操作，如 (F*F*L*L*B*R)**90 会让魔方回归初态
    public operator func **(exp: UInt32): Rotation {
        var result = this
        for (_ in 0..(exp - 1)) {
            result = result * this
        }
        return result
    }

    // 实现 ToString 接口以便打印和调试此代数系统
    private func text(inv: Bool): String {
        let exp = if (inv) { "⁻¹" } else { "" }
        match (this) {
            case F => "F${exp}" case B => "B${exp}" case L => "L${exp}"
            case R => "R${exp}" case U => "U${exp}" case D => "D${exp}"
            case I(r) => r.text(!inv)
            case X(x1, x2) =>
                if (inv) { // 逆变换需要反序
                    x2.text(inv) + x1.text(inv)
                } else {
                    x1.text(inv) + x2.text(inv)
                }
        }
    }

    public func toString(): String {
        text(false)
    }

    // 下面实现 Hashable 和 Equatable 接口，以便 Rotation 作为 HashMap 的 Key
    public func hashCode(): Int64 {
        this.toString().hashCode()
    }

    public operator func ==(that: Rotation): Bool {
        this.toString() == that.toString()
    }

    public operator func !=(that: Rotation): Bool {
        this.toString() != that.toString()
    }
}

public type Face = Rotation