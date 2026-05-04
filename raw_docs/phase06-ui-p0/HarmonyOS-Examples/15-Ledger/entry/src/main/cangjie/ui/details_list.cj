/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.ui

import ohos_app_cangjie_entry.constant.*
import ohos_app_cangjie_entry.ui.entity.*

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.format.*
import std.collection.ArrayList
import cj_res_entry.app


extend Text {
    func detailListSytle(isIncome: Bool, fontSize: Int64) {
        this
        .fontSize(fontSize)
        .fontWeight(FontWeight.W500)
        .margin(left: 4, right: 8)
        .fontColor(if (isIncome) { @r(app.color.income) } else { @r(app.color.expense) })
    }

    func detailListSytle(isIncome: Bool) {
        this.detailListSytle(isIncome, 14)
    }
}

@Component
public class DetailsList {
    @Prop
    var dynamicBill: DynamicBill

    public func build() {
        if (dynamicBill.selectedDetails.size > 0) {
            Column {
                ForEach(dynamicBill.selectedDetails, itemGeneratorFunc: { d: BillDetail, idx: Int64 => Column {
                            Row {
                                Image(d.icon).size(width: 20, height: 20).margin(left: 12, top: 8)

                                Column {
                                    Text(d.title).height(20).fontWeight(W500).align(Alignment.Start)
                                    Text(d.detail).fontSize(12).margin(top: 2).align(Alignment.Start)
                                }.layoutWeight(1).margin(left: 16)

                                Text(d.amount.format(".2")).detailListSytle(d.isIncome)
                            }
                            .height(80)

                            if (idx != dynamicBill.selectedDetails.size - 1) {
                                Divider()
                                .strokeWidth(0.5)
                                .offset(x: 8, y: 0)
                                .width(82.percent)
                                .color(Color.GRAY)
                            }
                        }
                    }, keyGeneratorFunc: {item: BillDetail, i: Int64 => "${i}-${item.title}"}
                )
            }
            .width(95.percent)
            .backgroundColor(Color.WHITE)
            .borderRadius(12)
            .margin(left: 8, right: 8)
        } else {
            Column {
                Text(@r(app.string.Not_available))
                .fontSize(22)
                .fontWeight(FontWeight.W700)
                .fontColor(Color.GRAY)
            }
            .height(80)
            .width(95.percent)
            .backgroundColor(Color.WHITE)
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .margin(left: 8, right: 8)
        }
    }
}
