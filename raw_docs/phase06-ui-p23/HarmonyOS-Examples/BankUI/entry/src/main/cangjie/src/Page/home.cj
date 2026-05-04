package ohos_app_cangjie_entry.Page

import cj_res_entry.app
import ohos_app_cangjie_entry.Component.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Component
public class Home {
    var scroller: Scroller = Scroller();
    @Provide
    var opacityValue: Float64 = 0.0;
    private var yOffset: Float64 = 0.0;
    @StorageLink["isLogin"]
    var isLoginCheck: Bool = false;

    protected override func aboutToAppear() {
        AppLog.info("home aboutToAppear")
    }

    func onScrollAction() {
        this.yOffset = this.scroller.currentOffset().yOffset
        if (this.yOffset > Float64(100)) {
            this.opacityValue = 1.0
        } else {
            this.opacityValue = this.yOffset / Float64(100)
        }
    }

    func build() {
        Stack(Alignment.Top) {
            Column() {
                Scroll(this.scroller) {
                    Column() {
                        HomeBanner()
                        HomeSwiper()
                        HomeEntrance()
                        HomeNews()
                        HomeAdvertisement()
                        HomeRecommend()
                        HomeLocation()
                    }.zIndex(1)
                }.onScroll({
                    offset => this.onScrollAction()
                })
                Column() {
                    HomeHeader()
                }.position(x: 0, y: 0).height(120.vp).zIndex(2)
            }
        }
    }
}
