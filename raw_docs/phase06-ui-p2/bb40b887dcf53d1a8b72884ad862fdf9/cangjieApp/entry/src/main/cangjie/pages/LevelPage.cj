package ohos_app_cangjie_entry.pages

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource_manager.*
import ohos.resource_manager.AppResource
import std.random.Random
import ohos_app_cangjie_entry.models.CharacterInfo
import ohos_app_cangjie_entry.models.LevelData
import ohos_app_cangjie_entry.models.GameState
import ohos_app_cangjie_entry.globalContext
import ohos.resource.__GenerateResource__
import kit.PerformanceAnalysisKit.Hilog

@Entry
@Component
class LevelPage {
    @State var levelData: Option<LevelData> = Option<LevelData>.None
    @State var currentActiveIndex: Int64 = 0
    @State var seasonalDecoration: AppResource = @r(app.media.deco_spring_bottom)

    protected override func aboutToAppear() {
        let params = getUIContext().getRouter().getParams()
        if (let Some(data) <- params) {
            let lvl = LevelData.fromJsonString(data)
            this.levelData = Some(lvl)
            // Load progress
            this.currentActiveIndex = GameState.instance.getProgress(lvl.id)
            
            // Set current level chars for review
            GameState.instance.currentLevelCharacters = lvl.characters

            // Random seasonal decoration
            let seasons = [@r(app.media.deco_spring_bottom), @r(app.media.deco_summer_bottom), @r(app.media.deco_autumn_bottom), @r(app.media.deco_winter_bottom)]
            let rnd = Int64(Random().nextUInt64() % 4)
            this.seasonalDecoration = seasons[rnd]
        } else {
            Hilog.warn(0x0000, "CangjieApp", "LevelPage: Invalid or missing params")
        }
    }

    protected override func onPageShow() {
         // Check if we need to advance progress (simulated "learning complete" upon return)
         // In a real app, HanziPage would return a result or update a shared store we observe.
         // For now, let's just refresh the progress in case it changed (if we decide to change it elsewhere)
         if (let Some(data) <- levelData) {
             this.currentActiveIndex = GameState.instance.getProgress(data.id)
         }
    }

    func navigateToHanzi(charInfo: CharacterInfo, index: Int64) {
        if (let Some(level) <- levelData) {
            // Assign the callback for completion
            // Assign the callback for completion
            GameState.instance.onPracticeComplete = { completedChar: String =>
                 // Find index of completed char
                 var idx = -1
                 for (i in 0..level.characters.size) {
                     if (level.characters[i].character == completedChar) {
                         idx = i
                         break
                     }
                 }

                if (idx != -1 && idx == this.currentActiveIndex) {
                    GameState.instance.advanceProgress(level.id, globalContext.getOrThrow())
                    // Update local state to reflect change immediately (or upon return)
                    this.currentActiveIndex = GameState.instance.getProgress(level.id)
                    
                    // Check if level is completed
                    if (this.currentActiveIndex >= level.characters.size) {
                        if (let Some(cb) <- GameState.instance.onLevelComplete) {
                            cb(level.id)
                        }
                    }
                }
            }
            
            // Callback to get previous character
            GameState.instance.onGetPreviousChar = { currentChar: String =>
                 // Find index of current char
                 var idx = -1
                 for (i in 0..level.characters.size) {
                     if (level.characters[i].character == currentChar) {
                         idx = i
                         break
                     }
                 }
                 
                 Hilog.info(0x0000, "CangjieApp", "LevelPage: onGetPreviousChar for ${currentChar}, idx=${idx}")

                 if (idx > 0) {
                     return Some(level.characters[idx - 1])
                 }
                 return None
            }

            // Callback to get next character
            GameState.instance.onGetNextChar = { currentChar: String =>
                 // Find index of current char
                 var idx = -1
                 for (i in 0..level.characters.size) {
                     if (level.characters[i].character == currentChar) {
                         idx = i
                         break
                     }
                 }
                 
                 let progress = GameState.instance.getProgress(level.id)
                 Hilog.info(0x0000, "CangjieApp", "LevelPage: onGetNextChar for ${currentChar}, idx=${idx}, progress=${progress}")
                 
                 if (idx >= 0 && idx < level.characters.size - 1) {
                     // Next char exists. Is it unlocked?
                     if (idx + 1 <= progress) {
                         Hilog.info(0x0000, "CangjieApp", "LevelPage: Next char unlocked. Returning ${level.characters[idx+1].character}")
                         return Some(level.characters[idx + 1])
                     } else {
                         Hilog.info(0x0000, "CangjieApp", "LevelPage: Next char locked (idx+1=${idx+1} > progress=${progress})")
                     }
                 } else {
                     Hilog.info(0x0000, "CangjieApp", "LevelPage: No next char or invalid index.")
                 }
                 return None
            }
            
            getUIContext().getRouter().pushUrl(url: "HanziPage", params: charInfo.toJsonString())
        }
    }


    private func getColumnsTemplate(data: LevelData): String {
        let charCount = data.characters.size
        if (charCount <= 9) {
            return "1fr 1fr 1fr"
        } else {
            return "1fr 1fr 1fr 1fr"
        }
    }

    @Builder
    func buildCell(charInfo: CharacterInfo, index: Int64) {
        Stack {
            // Base
            Image(@r(app.media.grid_cell_bg))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Fill)

            if (index < currentActiveIndex) {
                // LEARNED State
                // "Shows grid_overlay_redline.png (Red Box) AND the Character text centered above it."
                Image(@r(app.media.grid_overlay_redline))
                    .width(100.percent)
                    .height(100.percent)
                    .objectFit(ImageFit.Fill)

                Text(charInfo.character)
                    .fontSize(50.fp)
                    .fontColor(0xFF2B2B2B) // Ink Black
                    .fontWeight(FontWeight.Medium)
                    .fontStyle(FontStyle.Normal)

            } else if (index == currentActiveIndex) {
                 // ACTIVE State
                 // "Shows ONLY grid_overlay_redline.png (Red Box). The Character is HIDDEN."
                 Image(@r(app.media.grid_overlay_redline))
                    .width(100.percent)
                    .height(100.percent)
                    .objectFit(ImageFit.Fill)
            
                 // Transparent hit target to ensure clickability if needed, though Stack captures clicks
                 
            } else {
                 // LOCKED State
                 // "Shows a placeholder block with color #FFFFFF and opacity 0.5"
                 // Effectively a white overlay over the base bg
                 Row().width(100.percent).height(100.percent).backgroundColor(0x80FFFFFF)
            }
        }
        .width(100.percent)
        .aspectRatio(1.0)
        .onClick ({ evt =>
            if (index <= currentActiveIndex) {
                 // Allow clicking already learned ones too to review?
                 // Requirement: "Automatically advance focus... to the next" imply linear progression.
                 // "Clicking a character should navigate..."
                 // I will allow clicking Learned and Active. Locked is ignored.
                 this.navigateToHanzi(charInfo, index)
            }
        })
    }

    func build() {
        Stack(alignContent: Alignment.Bottom) {
            // 1. Background Layer
            Image(@r(app.media.bg_paper))
                .width(100.percent)
                .height(100.percent)
                .objectFit(ImageFit.Cover)

            // 2. Seasonal Decoration (Bottom)
            Image(this.seasonalDecoration).width(100.percent).objectFit(ImageFit.Contain)

            // 3. Content Layer (Top via Column)
            if (let Some(data) <- levelData) {
                Column {
                    // Top Section: Title & Description
                    Text(data.title)
                        .fontSize(24.fp)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(0xFF2B2B2B)
                        .margin(top: 40.vp, bottom: 10.vp)
                    
                    Text(data.description)
                        .fontSize(14.fp)
                        .fontColor(0xFF666666)
                        .margin(bottom: 20.vp)
                        .padding(left: 20.vp, right: 20.vp)
                        .textAlign(TextAlign.Center)

                    // Middle Section: Grid
                    // Determine columns based on size
                    
                    Grid() {
                        ForEach(data.characters, itemGenerator: { item: CharacterInfo, index: Int64 =>
                            GridItem() {
                                this.buildCell(item, index)
                            }
                        })
                    }
                    .columnsTemplate(this.getColumnsTemplate(data))
                    .rowsGap(10.vp)
                    .columnsGap(10.vp)
                    .padding(20.vp)
                    .height(50.percent)

                    // Review Entry Points
                    // Review Entry Points
                    if (this.currentActiveIndex >= data.characters.size) {
                        Row {
                            Column {
                                Image(@r(app.media.btn_review_listen))
                                    .width(60.vp)
                                    .height(60.vp)
                                    .objectFit(ImageFit.Contain)
                                    .margin(bottom: 4.vp)
                                Text("听写复习")
                                    .fontSize(12.fp)
                                    .fontColor(0xFF6B6B6B)
                            }
                            .onClick({ _ => getUIContext().getRouter().pushUrl(url: "ListenPage") })
                            .alignItems(HorizontalAlign.Center)
                            .margin(right: 40.vp)

                            Column {
                                Image(@r(app.media.btn_review_speak))
                                    .width(60.vp)
                                    .height(60.vp)
                                    .objectFit(ImageFit.Contain)
                                    .margin(bottom: 4.vp)
                                Text("跟读复习")
                                    .fontSize(12.fp)
                                    .fontColor(0xFF6B6B6B)
                            }
                            .onClick({ _ => getUIContext().getRouter().pushUrl(url: "SpeakPage") })
                            .alignItems(HorizontalAlign.Center)
                        }
                        .width(100.percent)
                        .justifyContent(FlexAlign.Center)
                        .margin(bottom: 30.vp)
                    }

                }
                .width(100.percent)
                .height(100.percent)
                .alignItems(HorizontalAlign.Center)
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
}
