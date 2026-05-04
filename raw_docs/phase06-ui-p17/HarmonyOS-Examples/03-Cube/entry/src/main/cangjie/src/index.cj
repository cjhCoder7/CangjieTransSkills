package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

import std.collection.*
import ohos_app_cangjie_entry.cube.*

let colorMap = HashMap<Face, UInt32>([
    (F, 0x009E60), (B, 0x0051BA),
    (L, 0xC41E3A), (R, 0xFF5800),
    (U, 0xFFD500), (D, 0x9932CC)
])
type ObservedMatrix = ObservedArray<(Face, Int64)>

extend Text {
    func block(color: UInt32) {
        this.borderRadius(10.percent).width(100.percent).aspectRatio(1).fontColor(Color.WHITE)
            .backgroundColor(color).textAlign(TextAlign.Center).margin(3.percent)
    }

    func title() {
        this.fontSize(25).fontColor(Color.WHITE).margin(top: 20).padding(5)
            .width(100.percent).backgroundColor(0x84999E).textAlign(TextAlign.Center)
    }
}

extend Button {
    func style() {
        this.width(80.percent).height(40.vp).backgroundColor(0x64696E).fontSize(18).margin(top: 10.vp)
            .shape(ShapeType.Normal).borderRadius(10)
    }
}

@Component
class CubeFace {
    @Prop var data: ObservedMatrix
    let name: String
    func build() {
        Stack {
            // 用 Grid 构造魔方面
            Grid {
                // 为了实现数据绑定，必须通过索引来引用 data 中的元素
                ForEach(data, itemGeneratorFunc: { _: (Face, Int64), i: Int64 =>
                    GridItem { Text(data[i][1].toString()).block(colorMap[data[i][0]]) }
                })
            }
            .columnsTemplate("1fr 1fr 1fr")
            .rowsTemplate("1fr 1fr 1fr")
            .width(100.percent)
            .aspectRatio(1)
            .margin(3.percent)
            // 每个魔方面上显示对应的名字，水印效果
            Text(name).fontSize(100).fontColor(0x66FFFFFF)
        }
    }
}

@Entry
@Component
class EntryView {
    @State var data: ObservedArray<ObservedMatrix> =
        ObservedArray(Array(6, { _ => ObservedArray(Array(9, item: (F, 0))) }))
    let cube: Cube = Cube()
    let G = I(R) * D * R * F * D * I(F)
    let M = R * I(L) * F * F * L * I(R) * I(D) * R * I(L) * F * L * I(R)
    let N = M * I(U) * I(M) * U

    // 将魔方实例 cube 中的数据同步到 data 变量中，借用 ObservedArray 的绑定机制实现魔方 UI 更新
    func sync() {
        var i = 0
        for (face in [U, L, F, R, D, B]) {
            let vector = flatten(cube.data[face])
            for (j in 0..data[i].size) {
                data[i][j] = vector.next().getOrThrow()
            }
            i++
        }
    }

    @Builder
    func button(title: String, operation: Rotation) {
        Button(title).style().onClick {
            cube.transform(operation)
            sync()
        }
    }

    func build() {
        Scroll {
            Column {
                GridRow(columns: 3) {
                    GridCol {}
                    GridCol { CubeFace(data: data[0], name: 'U') }
                    GridCol {}
                }.width(100.percent)
                GridRow(columns: 3) {
                    GridCol { CubeFace(data: data[1], name: 'L') }
                    GridCol { CubeFace(data: data[2], name: 'F') }
                    GridCol { CubeFace(data: data[3], name: 'R') }
                }.width(100.percent)
                GridRow(columns: 3) {
                    GridCol {}
                    GridCol { CubeFace(data: data[4], name: 'D') }
                    GridCol {}
                }.width(100.percent)
                GridRow(columns: 3) {
                    GridCol {}
                    GridCol { CubeFace(data: data[5], name: 'B') }
                    GridCol {}
                }.width(100.percent)

                Text("基本操作").title()

                GridRow(columns: 6) {
                    ForEach([F, B, L, R, U, D], itemGeneratorFunc: { face: Face, _: Int64 =>
                        GridCol { button(face.toString(), face) }
                    })
                }
                GridRow(columns: 6) {
                    ForEach([F, B, L, R, U, D], itemGeneratorFunc: { face: Face, _: Int64 =>
                        GridCol {
                            Button("${face}⁻¹").style().fontSize(14).onClick {
                                cube.transform(I(face))
                                sync()
                            }
                        }
                    })
                }

                Button("重置魔方").style().onClick {
                    cube.reset()
                    sync()
                }

                Text("置换群的阶数").title()
                button("FFRR", F * F * R * R)
                button("FFRR^6", (F * F * R * R) ** 6)
                button("FULLR", F * U * L * L * R)
                button("FULLR^36", (F * U * L * L * R) ** 36)
                button("FFLLBR^90", (F * F * L * L * B * R) ** 90)

                Text("相似变换").title()
                button("G = R⁻¹DRFDF⁻¹", G)
                button("UGU⁻¹", U * G * I(U))

                Text("组合子变换").title()
                button("M = RL⁻¹FFLR⁻¹D⁻¹RL⁻¹FLR⁻¹", M)
                button("N = MU⁻¹M⁻¹U", M * I(U) * I(M) * U)
                button("P = NUN⁻¹U⁻¹", N * U * I(N) * I(U))
            }.margin(top: 10.percent)
             .onAppear { sync() }
        }
    }
}
