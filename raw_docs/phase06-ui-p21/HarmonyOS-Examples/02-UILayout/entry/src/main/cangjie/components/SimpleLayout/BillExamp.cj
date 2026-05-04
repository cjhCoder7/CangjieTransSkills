/**
 * Created on 2025/8/3
 */
package ohos_app_cangjie_entry.components.SimpleLayout

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.convert.*
import ohos_app_cangjie_entry.utils.{formatFloat64}
import ohos_app_cangjie_entry.components.utils.BlackDivider


@Component
public class InfoItem {
    @Prop var title: String
    @Prop var content: String

    let infoTextSize: Int64 = 28

    func build() {
        Column(15.lpx) {
            Text("${title}").fontSize(infoTextSize.lpx).fontWeight(FontWeight.W800)
            Text("${content}").fontSize(infoTextSize.lpx).fontWeight(FontWeight.W300)
        }.width(100.percent).margin(bottom: 20.lpx).alignItems(HorizontalAlign.Start)
    }
}


@Component
public class InfoBand {
    let space: Int64 = 10

    func build() {
        Column(space.lpx) {
            Row() {
                Row() { InfoItem(title: "收件人", content: "李**") }.width(50.percent)
                Row() { InfoItem(title: "手机号", content: "13767109923") }.width(50.percent)
            }

            InfoItem(title: "地址", content: "汉东省京州市汉东政法大学学生宿舍4号楼")

            BlackDivider()
        }
    }
}


@Component
public class ProductItem {
    @Prop var product: Product  // 单个产品对象

    let normalFontSize: Int64 = 28
    let smallFontSize: Int64 = 24

    func build() {
        Row() {
            Column(10.lpx) {
                Text("${product.name}").fontSize(normalFontSize.lpx).fontColor(0x000000)
                Text("${product.description}").fontSize(smallFontSize.lpx).fontColor(0x535353)
            }.alignItems(HorizontalAlign.Start).width(400.lpx)
            Row(20.lpx) {
                Text("${product.num}x").fontSize(normalFontSize.lpx).fontColor(0x000000)
                Text("￥${formatFloat64(product.price * Float64(product.num))}")
                    .fontSize(normalFontSize.lpx).fontColor(0x000000)
            }.justifyContent(FlexAlign.Start)
        }.width(100.percent).justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Top)
    }
}


@Component
public class ProductBand {
    let fontSize: Int64 = 30  // 总金额及具体的价格的字体大小

    func build() {
        Column(40.lpx) {
            Column(20.lpx) {
                ForEach(defaultProductList, itemGeneratorFunc: {
                        product: Product, index: Int64 => ProductItem(product: product)
                }, keyGeneratorFunc: { product: Product, _: Int64 => product.name })
            }.width(100.percent)

            BlackDivider()

            Row() {
                Text("总金额").fontSize(fontSize.lpx).fontWeight(FontWeight.W600)
                Text("￥${defaultTotalCost}").fontSize(fontSize.lpx).fontWeight(FontWeight.W600)
            }.justifyContent(FlexAlign.SpaceBetween).width(100.percent)
        }.width(100.percent)
    }
}


@Component
public class BillExampBand {
    let padX: Int64 = 30  // X轴方向的内边距(单位.lpx)
    let padY: Int64 = 50  // Y轴方向的内边距(单位.lpx)

    func build() {
        Column(40.lpx) {
            InfoBand()

            ProductBand()
        }.padding(top: padY.lpx, bottom: padY.lpx, left: padX.lpx, right: padX.lpx)
        .border(width: 2.lpx, color: Color(0xa3a3a3)).borderRadius(10.lpx)
    }
}
