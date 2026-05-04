package ohos_app_cangjie_entry.pages

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.PerformanceAnalysisKit.*
import ohos.resource_manager.AppResource
import kit.AbilityKit.*


import ohos_app_cangjie_entry.globalContext
import ohos_app_cangjie_entry.models.LevelData
import ohos_app_cangjie_entry.models.LevelStatus
import ohos_app_cangjie_entry.models.GameState
import ohos_app_cangjie_entry.components.SplashScreen
import std.sync.Timer
import ohos.resource.__GenerateResource__




@Component
class LevelItemView {
    @Prop var level: LevelData
    @Prop var onLampClick: (LevelData) -> Unit


    func build() {
        Stack {
            // Layer 1: Background Image
            Image(this.getMapImage(level.mapSegmentImage))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Contain)
            
            // Layer 2: Decorations
            // Left Side
            Image(this.getDecoration("left", level.id))
                .width(30.percent)
                .objectFit(ImageFit.Contain)
                .position(x: (0).percent, y: 100.percent)
                .markAnchor(x: 0.percent, y: 100.percent)

            // Right Side
            Image(this.getDecoration("right", level.id))
                .width(30.percent)
                .objectFit(ImageFit.Contain)
                .position(x: 100.percent, y: 0.percent)
                .markAnchor(x: 100.percent, y: 0.percent)

            // Layer 3: Lamp Button and Title
            Column {
                Image(this.getLampImage(level.status))
                    .width(30.percent)
                    .objectFit(ImageFit.Contain)
                    .onClick ({ evt =>
                        if (level.status != LevelStatus.Locked) {
                            onLampClick(level)
                        }
                    })
                Text(level.title)
                    .fontSize(16.fp)
                    .fontColor(0xFFD700)
                    .fontWeight(FontWeight.Bold)
                    .margin(top: 5.vp)
            }
            .width(50.percent)
            .alignItems(HorizontalAlign.Center)
            .position(x: 50.percent, y: 0.percent)
            .markAnchor(x: 50.percent, y: 50.percent)
        }
        .width(100.percent)
        .height(40.percent)
        .align(Alignment.TopStart)
    }

    func getDecoration(side: String, levelId: Int64): AppResource {
        if (side == "left") {
            let assets = [
                @r(app.media.img_bamboo_fg_left),
                @r(app.media.img_grass_dense_left), 
                @r(app.media.img_flower_orchid_left),
                @r(app.media.img_stone_moss_left),
                @r(app.media.img_dragonfly_reed_left)
            ]
            let index = Int64(levelId % Int64(assets.size))
            return assets[index]
        } else {
            // Right side
            // Currently using bamboo and pine (once generated). using bamboo_02 as fallback/filler
            let assets = [
                @r(app.media.img_bamboo_fg_right),
                @r(app.media.img_pine_branch_right),
                @r(app.media.img_colored_leaves_right),
                @r(app.media.img_bamboo_shoots_right)
            ]
            let index = Int64(levelId % Int64(assets.size))
            return assets[index]
        }
    }

    func getMapImage(name: String): AppResource {
        // If completed, use the completed version
        var imageName = name
        if (level.status == LevelStatus.Completed) {
            imageName = name + "_completed"
        }

        if (imageName == "bg_map_segment_01") {
            return @r(app.media.bg_map_segment_01)
        } else if (imageName == "bg_map_segment_01_completed") {
            return @r(app.media.bg_map_segment_01_completed)
        } else if (imageName == "bg_map_segment_02") {
            return @r(app.media.bg_map_segment_02)
        } else if (imageName == "bg_map_segment_02_completed") {
            return @r(app.media.bg_map_segment_02_completed)
        } else if (imageName == "bg_map_segment_03") {
            return @r(app.media.bg_map_segment_03)
        } else if (imageName == "bg_map_segment_03_completed") {
            return @r(app.media.bg_map_segment_03_completed)
        } else {
            // Fallback
             return @r(app.media.bg_map_segment_03)
        }
    }

    func getLampImage(status: LevelStatus): AppResource {
        match (status) {
            case LevelStatus.Completed => return @r(app.media.btn_lamp_completed)
            case LevelStatus.Active => return @r(app.media.btn_lamp_active)
            case LevelStatus.Locked => return @r(app.media.btn_lamp_locked)
        }
    }
}

@Component
class VerifiedCompletionOverlay {
    @Prop var onClose: () -> Unit

    func build() {
        Stack {
            // Semi-transparent background
            Column()
                .width(100.percent)
                .height(100.percent)
                .backgroundColor(0x99000000)
                .onClick ({ evt =>
                    onClose()
                })

            // Card Content
            Column {
                // Title
                Text("游历圆满")
                    .fontSize(24.fp)
                    .fontColor(0x333333)
                    .fontWeight(FontWeight.Bold)
                
                Text("Journey Completed")
                    .fontSize(14.fp)
                    .fontColor(0x999999)
                    .margin(top: 4.vp, bottom: 20.vp)
                
                // Pavilion Image
                Stack {
                    Image(@r(app.media.img_grand_pavilion))
                        .width(200.vp)
                        .objectFit(ImageFit.Contain)
                    
                    // Stamp overlay
                    Image(@r(app.media.img_stamp_excellent))
                        .width(50.vp)
                        .objectFit(ImageFit.Contain)
                        .position(x: 55.percent, y: 55.percent)
                        .markAnchor(x: 50.percent, y: 50.percent)
                        .rotate(angle: -15.0)
                        .opacity(0.9)
                }
                .margin(bottom: 20.vp)

                // Message
                Text("笔墨生香，字字珠玑。\n恭喜你走遍万水千山，完成所有关卡的修行。")
                    .fontSize(16.fp)
                    .fontColor(0x666666)
                    .textAlign(TextAlign.Center)
                    .lineHeight(24.vp)

                Text("Ink brings fragrance, words are gems.\nCongratulations on completing your journey.")
                    .fontSize(12.fp)
                    .fontColor(0xAAAAAA)
                    .textAlign(TextAlign.Center)
                    .margin(top: 8.vp, bottom: 30.vp)

                // Close Hint
                Text("凯旋归来 / Return")
                    .fontSize(14.fp)
                    .fontColor(0x999999)
            }
            .width(80.percent)
            .backgroundColor(0xFFFFFF)
            .borderRadius(16.vp)
            .padding(30.vp)
            .alignItems(HorizontalAlign.Center)
            .onClick ({ evt =>
                // Consume click to prevent closing when clicking on card
                onClose()
            })
        }
        .width(100.percent)
        .height(100.percent)
        .alignContent(Alignment.Center)
        .onClick ({ evt =>
             onClose()
        })
    }
}

@Entry
@Component
class HomePage {
    @State var levels: Array<LevelData> = []
    @State var isAllCompleted: Bool = false
    @State var showCompletionOverlay: Bool = false
    @State var showSplash: Bool = true //Change to false for debug, switch to true to publish
    
    let scroller: Scroller = Scroller()

    protected override func aboutToAppear() {
        this.loadLevels()
    }

    protected override func onPageShow() {
        // Refresh level status when page is shown (e.g. returning from LevelPage)
        this.refreshLevelsState()
    }

    func getContext(): UIAbilityContext {
        // 从 main_ability 获取 context
        return globalContext.getOrThrow()
    }

    func loadLevels() {
        // Load persisted game state first
        GameState.instance.load(getContext())
        
        this.levels = LevelData.loadLevels(getContext())
    }

    func refreshLevelsState() {
        for (i in 0..this.levels.size) {
            let level = this.levels[i]
            let progress = GameState.instance.getProgress(level.id)
            
            // Check if completed (progress >= total chars)
            if (progress >= level.characters.size && level.status != LevelStatus.Completed) {
                level.status = LevelStatus.Completed
                // Unlock next level
                if (i + 1 < this.levels.size) {
                    if (this.levels[i+1].status == LevelStatus.Locked) {
                        this.levels[i+1].status = LevelStatus.Active
                    }
                }
            }
        }
        
        // Check if all levels are completed
        if (this.levels.size > 0 && this.levels[this.levels.size - 1].status == LevelStatus.Completed) {
            this.isAllCompleted = true
        } else {
            this.isAllCompleted = false
        }
    }

    func build() {
        Stack {
            // Root Background
            Image(@r(app.media.bg_paper))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Cover)

            // Scrollable Content
            Scroll(scroller) {
                Column {
                    // mountain peak
                    Image(@r(app.media.bg_mountain_peak))
                        .width(100.percent)
                        .objectFit(ImageFit.Contain)
                    //
                    ForEach(this.levels, itemGenerator: { item: LevelData, index: Int64 =>
                        LevelItemView(
                            level: item,
                            onLampClick: { level: LevelData =>
                                Hilog.info(0x0000, "CangjieApp", "Clicked lamp level: " + level.id.toString())
                                // Subscribe to level complete event
                                GameState.instance.onLevelComplete = { completedLevelId: Int64 => 
                                    // Also refresh when callback fires (though onPageShow handles it too)
                                    this.refreshLevelsState()
                                }
                                
                                getUIContext().getRouter().pushUrl(url: "LevelPage", params: level.toJsonString())
                            }
                        )
                    })
                    
                    // Destination: Grand Pavilion
                    Stack {
                        Image(@r(app.media.img_grand_pavilion))
                            .width(80.percent)
                            .objectFit(ImageFit.Contain)

                        // Glow effect when completed
                        if (this.isAllCompleted) {
                             Image(@r(app.media.efx_lamp_glow))
                                .width(50.percent) // Adjust specific to pavilion
                                .objectFit(ImageFit.Contain)
                                .position(x: 50.percent, y: 60.percent) // Roughly center on pavilion
                                .markAnchor(x: 50.percent, y: 50.percent)
//                                .hitTestBehavior(HitTestMode.None)  // TODO: 6.0.2升级适配  待fix
                        }
                    }
                    .width(100.percent)
                    .height(30.percent)
                    .align(Alignment.Top)
                    .margin(top: (-60).vp) // Slight overlap upwards to connect with the path end
                    .onClick ({ evt =>
                        if (this.isAllCompleted) {
                            this.showCompletionOverlay = true
                        }
                    })

                    // Footer image
                    Image(@r(app.media.bg_nature_footer))
                        .width(100.percent)
                        .objectFit(ImageFit.Contain)
                }
                .width(100.percent)
                // Add some padding at bottom for scrolling
                .padding(bottom: 50.vp)
            }
            .scrollBarWidth(0.vp)
//            .edgeEffect(EdgeEffect.Spring)    //TODO: 6.0.2升级适配  to be fixed
            .width(100.percent)
            .height(100.percent)

            if (this.showCompletionOverlay) {
                VerifiedCompletionOverlay(onClose: { =>
                    this.showCompletionOverlay = false
                })
            }

            if (this.showSplash) {
                SplashScreen(onComplete: { =>
                    this.showSplash = false
                })
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
}
