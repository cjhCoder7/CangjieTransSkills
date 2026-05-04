/**
 * Created on 2025/8/8
 */
package ohos_app_cangjie_entry.services

import encoding.json.JsonValue
import std.collection.ArrayList

import ohos.resource_manager.ResourceManager

import ohos_app_cangjie_entry.models.*

public class ChartDataServices {
    private let resourceManager: ResourceManager

    public init(resMgr: ResourceManager) {
        this.resourceManager = resMgr
    }

    private func loadAndParseData<T>(filename: String, jsonKey: String, parser: (JsonValue) -> Option<T>): ArrayList<T> {
        let result = ArrayList<T>()
        let rawFile = resourceManager.getRawFileContent(filename)
        let jsonStr = String.fromUtf8(rawFile)
        let jsonVal = JsonValue.fromStr(jsonStr)

        match(jsonVal.asObject().get(jsonKey)) {
            case Some(arrVal) =>
                let dataArray = arrVal.asArray()
                for (itemVal in dataArray.getItems()) {
                    match(parser(itemVal)) {
                        case Some(parsedItem) => result.append(parsedItem)
                        case None => ()
                    }
                }
            case None => ()
        }

        result
    }

    public func loadTimeLineData(): ArrayList<TimeLineDataPoint> {
        return loadAndParseData("MockTimeLineData.json", "timeLineData") { itemVal =>
            let itemObj  = itemVal.asObject()
            let time     = itemObj.get("time")?.asString().getValue() ?? "00:00"
            let price    = itemObj.get("price")?.asFloat().getValue() ?? 0.0
            let volume   = itemObj.get("volume")?.asInt().getValue() ?? 0
            let change   = itemObj.get("change")?.asFloat().getValue() ?? 0.0
            let avgPrice = itemObj.get("avgPrice")?.asFloat().getValue() ?? 0.0
            Some(TimeLineDataPoint(time, price, volume, change, avgPrice))
        }
    }

    public func loadKLineData(): ArrayList<KLinePointWrapper> {
        let rawData = loadAndParseData("MockDailyKLineData.json", "dailyKLineData") { itemVal =>
            let itemObj = itemVal.asObject()
            let low     = itemObj.get("low")?.asFloat().getValue() ?? 0.0
            let high    = itemObj.get("high")?.asFloat().getValue() ?? 0.0
            let open    = itemObj.get("open")?.asFloat().getValue() ?? 0.0
            let close   = itemObj.get("close")?.asFloat().getValue() ?? 0.0
            let volume  = itemObj.get("volume")?.asInt().getValue() ?? 0
            let ts      = itemObj.get("timestamp")?.asString().getValue() ?? "99991231"
            let percent = itemObj.get("changePercent")?.asFloat().getValue() ?? 0.0
            Some(KLineDataPoint(ts, high, open, low, close, volume, percent))
        }
        let dataWithMA5 = ArrayList<KLinePointWrapper>()
        var cumulativeSum: Float64 = 0.0
        for(i in 0..rawData.size) {
            let wrapper = KLinePointWrapper(rawData[i])
            if (i >= 4) {
                var sum: Float64 = 0.0
                for(j in 0..5) { sum += rawData[i - j].close }
                wrapper.ma5 = sum / 5.0
            } else {
                cumulativeSum += rawData[i].close
                wrapper.ma5 = cumulativeSum / Float64(i + 1)
            }
            dataWithMA5.append(wrapper)
        }
        return dataWithMA5
    }
}
