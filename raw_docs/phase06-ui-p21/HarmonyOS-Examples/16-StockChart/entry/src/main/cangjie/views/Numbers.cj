/**
 * Created on 2025/7/31
 */
package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos_app_cangjie_entry.models.*
import ohos_app_cangjie_entry.constants.*
import ohos_app_cangjie_entry.viewmodels.TimeLineViewModel

@Component
public class Numbers {
    @LocalStorageLink['timeLineViewModel']
    var viewModel: TimeLineViewModel = TimeLineViewModel()

    func build() {
        Column(5) {
            mainData(viewModel.displayNumberData)
            otherData(viewModel.displayNumberData)
            tags()
        }
    }
}

@Builder
private func mainData(latestPoint: DisplayNumberData) {

    Row(5) {
        Text(latestPoint.priceText)
            .numberStyle(color: latestPoint.dataColor, size: 22)

        Text(latestPoint.changeText)
            .offset(x: 0, y: -3)
            .numberStyle(color: latestPoint.dataColor)

        Text(latestPoint.percentText)
            .offset(x: 0, y: -3)
            .numberStyle(color: latestPoint.dataColor)
    }
    .width(StyleConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Bottom)
}

@Builder
private func otherData(data: DisplayNumberData) {
    Row(20) {
        Row(5) {
            Text("成交量").wordStyle()
            Text(data.volumeText).numberStyle()
        }

        Row(5) {
            Text("成交额").wordStyle()
            Text(data.turnoverText).numberStyle()
        }

        Row(5) {
            Text("振  幅").wordStyle()
            Text(data.amplitudeText).numberStyle()
        }
    }
    .width(StyleConstants.FULL_WIDTH)
}

@Builder
private func tags() {
    Row(5) {
        Text("综合指数").tagStyle(Color(0xe6f1ff), Color(0x007ef0))

        Text("估值高").tagStyle(Color(0xeeeeee), StyleConstants.GRAY_COLOR)

        Text("景气度较高").tagStyle(Color(0xfff3e5), Color(0xff8900))
    }
    .width(StyleConstants.FULL_WIDTH)
}