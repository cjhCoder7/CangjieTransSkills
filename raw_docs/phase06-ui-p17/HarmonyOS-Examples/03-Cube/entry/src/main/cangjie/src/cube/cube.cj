package ohos_app_cangjie_entry.cube

import std.collection.*

public class Cube {
    public let data = HashMap<Face, Matrix>()
    private static let permutation = HashMap<Face, Permutation>()

    public init() {
        reset()
    }

    static init() {
        // 每个面顺时针转动 90 度时，相邻四面的置换关系
        permutation[F] = [(L, 2.c), (U, -2.r), (R, 0.c), (D, -0.r)]
        permutation[B] = [(L, -0.c), (D, 2.r), (R, -2.c), (U, 0.r)]
        permutation[L] = [(U, 0.c), (F, 0.c), (D, 0.c), (B, 0.c)]
        permutation[R] = [(B, 2.c), (D, 2.c), (F, 2.c), (U, 2.c)]
        permutation[U] = [(L, 0.r), (B, -2.r), (R, -0.r), (F, 0.r)]
        permutation[D] = [(R, 2.r), (B, -0.r), (L, -2.r), (F, 2.r)]
    }

    public func reset() {
        for (face in [F, B, L, R, U, D]) {
            data[face] = Matrix.create(face)
        }
    }

    // 对指定面上的矩阵旋转 90 度，inverse = true 代表逆时针方向
    // 此操作不影响其他面，要配合邻边置换操作才能完成魔方的实际转动
    private func rotate(face: Face, inverse: Bool) {
        const N = 3
        let matrix = Matrix.create(face)
        let map = if (inverse) {
            { i: Int64, j: Int64 => (N - 1 - j, i) }
        } else {
            { i: Int64, j: Int64 => (j, N - 1 - i) }
        }
        for (i in 0..N) {
            for (j in 0..N) {
                let (u, v) = map(i, j)
                matrix[u][v] = data[face][i][j]
            }
        }
        data[face] = matrix
    }

    // 实现各面行/列之间的置换操作，输入是一个置换序列
    private func permute(perm: Permutation, inverse: Bool) {
        let p = if (inverse) { perm.inverse() } else { perm.clone() }
        p.reverse()
        var (lastFace, lastIndex) = p[0]
        let vector = data[lastFace][lastIndex]
        for (i in 1..p.size) {
            let (face, index) = p[i]
            data[lastFace].set(lastIndex, data[face][index])
            (lastFace, lastIndex) = (face, index)
        }
        data[lastFace].set(lastIndex, vector)
    }

    // 在魔方上按序执行 rotation 中定义的操作序列
    private func transform(rotation: Rotation, inverse: Bool): Unit {
        match (rotation) {
            case I(r) => transform(r, !inverse)
            case X(r1, r2) => // 对复合操作进行递归分解
                if (inverse) { // 逆变换需要反序
                    transform(r2, inverse)
                    transform(r1, inverse)
                } else {
                    transform(r1, inverse)
                    transform(r2, inverse)
                }
            case _ => // 各原子操作对应面先旋转 90 度，然后对相邻四个面执行置换操作
                rotate(rotation, inverse)
                permute(permutation[rotation], inverse)
        }
    }

    public func transform(rotation: Rotation) {
        transform(rotation, false)
        return this
    }
}