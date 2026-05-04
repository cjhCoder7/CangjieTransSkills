/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package ohos_app_cangjie_entry

import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.component.*
import ohos.base.*
import ohos.resource_manager.ResourceManager
import avif4cj.*

@Entry
@Component
class EntryView12 {

    var imageValue51:?Array<UInt8> = None
    var imageValue25:?Array<UInt8> = None

    protected override func aboutToAppear() {
        imageValue51 = getImageFromRawFile("a51.avif") //静态图
        imageValue25 = getImageFromRawFile("a25.avif") //动态图
    }

    let scroller = Scroller()

    func build() {
        Scroll(this.scroller){
            Column(){
                AvifImage(imageBuffer:imageValue25,imageViewWidth:600.px,imageViewHeight:400.px,imagePicWidth:600,imagePicHeight:400,imageFit:ImageFit.None)
                AvifImage(imageBuffer:imageValue51,imageViewWidth:600.px,imageViewHeight:400.px,imagePicWidth:600,imagePicHeight:400,imageFit:ImageFit.None)
            }
        }
    }

    private func getImageFromRawFile(rawFileName: String): ?Array<UInt8> {
        try {
            let resourceManager = ResourceManager.getResourceManager(getStageContext(globalAbilityContext.getOrThrow()))
            let arr: Array<UInt8> = resourceManager.getRawFileContent(rawFileName)
            return arr
        } catch (e: Exception) {
            return None
        }
    }
}
