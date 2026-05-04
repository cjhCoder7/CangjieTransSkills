/**
 * Created on 2025/7/30
 */
package ohos_app_cangjie_entry.views

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.ResourceManager

import ohos_app_cangjie_entry.viewmodels.*
import ohos_app_cangjie_entry.constants.StyleConstants
import ohos_app_cangjie_entry.services.ChartDataServices

@Component
public class Content {
    @StorageProp['resMgr']
    let resourceManager: Option<ResourceManager> = Option.None
    
    @LocalStorageLink['timeLineViewModel']
    var timeLineViewModel: TimeLineViewModel = TimeLineViewModel()

    @LocalStorageLink['kLineViewModel']
    var kLineViewModel: KLineViewModel = KLineViewModel()

    protected override func aboutToAppear() {
        match(resourceManager) {
            case Some(resMgr) =>
                let dataService = ChartDataServices(resMgr)
                timeLineViewModel.initialize(dataService)
                kLineViewModel.initialize(dataService)
                timeLineViewModel.startUpdating()
            case None => ()
        }
    }

    protected override func aboutToDisappear() {
        timeLineViewModel.stopUpdating()
    }

    func build() {
        Column(10) {
            Column {
                Numbers()
            }
            .cardStyle()

            Column {
                Quotes()
            }
            .cardStyle()
        }
        .padding(10)
        .backgroundColor(0xf5f5f5)
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
    }
}