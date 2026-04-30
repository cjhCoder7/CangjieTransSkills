package ohos_app_cangjie_entry.views

import kit.ArkUI.*
import ohos.resource.__GenerateResource__
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.models
import ohos_app_cangjie_entry.models.Habit
import ohos_app_cangjie_entry.models.HabitColor
import ohos_app_cangjie_entry.models.DateHelper
import ohos_app_cangjie_entry.models.Constants
import ohos_app_cangjie_entry.models.randomHabitColor
import ohos_app_cangjie_entry.models.allHabitColors

/// 排序选项枚举
public enum SortingOption {
    | ByDate
    | ByName

    public operator func ==(right: SortingOption): Bool {
        match (this) {
            case ByDate => match (right) { case ByDate => true case _ => false }
            case ByName => match (right) { case ByName => true case _ => false }
        }
    }

    public prop displayName: String {
        get() {
            match (this) {
                case ByDate => "按日期排序"
                case ByName => "按名称排序"
            }
        }
    }
}

/// 排序菜单视图
@Component
class SortMenuView {
    @Link var selectedSortingOption: SortingOption
    @Link var isSortingOrderAscending: Bool

    func build() {
        Row() {
            Image(@r(app.media.circle))
                .width(24.0)
                .height(24.0)
                .fillColor(Color.Black)
                .onClick({ evt =>
                    this.isSortingOrderAscending = !this.isSortingOrderAscending
                })
        }
    }
}
