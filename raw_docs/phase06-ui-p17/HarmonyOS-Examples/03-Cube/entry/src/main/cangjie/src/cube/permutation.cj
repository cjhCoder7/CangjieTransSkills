package ohos_app_cangjie_entry.cube

// Permutation 可以表示一个置换序列
// 如 [(L, 2.c), (U, -0.r)] 表示 L 面第三列和 U 面第一行之间的轮换，且前者在换到后者时需要倒置
type Permutation = Array<(Face, Index)>
extend Permutation {
    // 获取当前置换的逆变换
    public func inverse() {
        let perm = this.clone()
        for (i in 0..perm.size) {
            let j = (i + 1) % perm.size
            let (face, index) = this[i] // 解构元组
            if (let Inv(_) <- this[j][1]) { // if-let 模式匹配
                perm[i] = (face, -(index.value()))
            } else {
                perm[i] = (face, index.value())
            }
        }
        perm.reverse()
        return perm
    }
}