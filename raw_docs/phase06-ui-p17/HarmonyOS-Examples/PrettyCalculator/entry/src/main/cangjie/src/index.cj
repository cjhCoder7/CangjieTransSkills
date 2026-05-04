package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
internal import ohos.display.*
import ohos.state_macro_manage.*

import cj_res_entry.app
import std.collection.ArrayList
import std.convert.Parsable

import ohos_app_cangjie_entry.components.*

let storageHistory = AppStorage.setOrCreate("history", ObservedArrayList<String>([]))
let storageHistoryIndex = AppStorage.setOrCreate("historyIndex", 0)
let storageThemeIndex = AppStorage.setOrCreate("themeIndex", 0)
let storageFoldStatusNum = AppStorage.setOrCreate("foldStatusNum", 1)
let storageExpression = AppStorage.setOrCreate("expression", "")
let storageResult = AppStorage.setOrCreate("result", "")

class Theme {
    public Theme(
        var foregroundColor !: Color = Color(0xFEB6B3),
        var backgroundColor !: Color = Color(0xFAD9DC)
    ) {}
}


@Entry
@Component
class HomeView {
    let foldStatus:FoldStatus = getFoldStatus()
    @StorageLink["themeIndex"] var themeIndex: Int64 = 0
    @StorageLink["foldStatusNum"] var foldStatusNum:Int64 = match (foldStatus) {
        case FoldStatus.FOLD_STATUS_EXPANDED => 1
        case FoldStatus.FOLD_STATUS_FOLDED => 2
        case FoldStatus.FOLD_STATUS_HALF_FOLDED => 3
        case FoldStatus.FOLD_STATUS_UNKNOWN => 4
    }

    let themes: Array<Theme> = [
        Theme(foregroundColor: Color(0xFEB6B3), backgroundColor: Color(0xFAD9DC)),
        Theme(foregroundColor: Color(0x31D2C7), backgroundColor: Color(0xC5EFE3)),
        Theme(foregroundColor: Color(0x36AFFF), backgroundColor: Color(0xCFF1FF)),
        Theme(foregroundColor: Color(0x5F5A91), backgroundColor: Color(0x817AC4)),
        Theme(foregroundColor: Color(0xFF9900), backgroundColor: Color(0xFFCC00))
    ]

    func onFoldChange(): Bool {
        var foldStatus:FoldStatus = getFoldStatus()
        foldStatusNum = match (foldStatus) {
            case FoldStatus.FOLD_STATUS_EXPANDED => 1
            case FoldStatus.FOLD_STATUS_FOLDED => 2
            case FoldStatus.FOLD_STATUS_HALF_FOLDED => 3
            case FoldStatus.FOLD_STATUS_UNKNOWN => 4
        }
        return true
    }

    func build() {
        Column {
            if(foldStatusNum == 1 || foldStatusNum == 3) {
                Row{
                    Flex(FlexParams(direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween)) {
                        History()
                        Expression()
                    }
                    .width(46.percent)
                    .height(94.percent)
                    .margin(left: 2.percent, right: 2.percent)
                    .backgroundColor(0xFDFBFA)
                    .borderRadius(10.vp)


                    Column() {
                        Keyboard()
                    }
                    .width(50.percent)
                    .height(100.percent)
                    .padding(left: 2.percent, right: 2.percent)
                }.width(100.percent)
                .height(100.percent)
            } else if(foldStatusNum == 2 || foldStatusNum == 4) {
                Flex(FlexParams(direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween)) {
                    History()
                    Expression()
                }
                .height(38.percent)
                .margin(left: 2.percent, right: 2.percent, bottom: 2.percent)
                .backgroundColor(0xFDFBFA)
                .borderRadius(10.vp)


                Column() {
                    Keyboard()
                }
                .width(100.percent)
                .height(60.percent)
                .padding(left: 2.percent, right: 2.percent)
            }
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(themes[themeIndex].backgroundColor)
        .expandSafeArea(
            types: [SafeAreaType.SYSTEM],
            edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
        )
        .onAreaChange({_, _ => onFoldChange()}) // 这里是否生效模拟器上无法测试

    }
}
