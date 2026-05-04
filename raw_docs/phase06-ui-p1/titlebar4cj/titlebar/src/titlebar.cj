/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package titlebar

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import titlebar.models.*

/**
 * TitleBar 标题栏组件
 *
 * 三段式布局（左/中/右），支持自定义插槽
 */
@Component
public class TitleBar {
    @Link var model: TitleBarModel

    public func build() {
        Row() {
            buildLeftLayout()
            buildCenterLayout()
            buildRightLayout()
        }
        .alignItems(VerticalAlign.Center)
        .width(100.percent)
        .height(this.model.titleBarMinHeight)
        .backgroundColor(this.model.titleBarBackground)
    }

    @Builder
    private func buildLeftLayout() {
        if (this.model.leftTitleName.size > 0) {
            normalBothSidesLayoutLeft()
        } else {
            blankLayout()
        }
    }

    @Builder
    private func buildCenterLayout() {
        Column(space: this.model.titleSpace) {
            buildMainTitle()
            if (this.model.subTitleName.size > 0) {
                buildSubTitle()
            }
        }
        .padding(this.model.titleBarNormalPadding)
        .layoutWeight(1)
        .onClick({ evt: ClickEvent => this.model.onTitleClickListener() })
    }

    @Builder
    private func buildRightLayout() {
        if (this.model.rightTitleName.size > 0) {
            normalBothSidesLayoutRight()
        } else {
            blankLayout()
        }
    }

    @Builder
    private func buildMainTitle() {
        Text(this.model.titleName)
            .maxLines(1)
            .fontSize(this.model.titleFontSize)
            .fontColor(this.model.titleFontColor)
    }

    @Builder
    private func buildSubTitle() {
        Text(this.model.subTitleName)
            .maxLines(1)
            .fontSize(this.model.subTitleFontSize)
            .fontColor(this.model.subTitleFontColor)
    }

    @Builder
    private func blankLayout() {
        Row()
            .width(this.model.titleBarMinHeight)
            .height(this.model.titleBarMinHeight)
    }

    @Builder
    private func normalBothSidesLayoutLeft() {
        Row(space: this.model.leftTitleSpace) {
            Text(this.model.leftTitleName)
                .maxLines(1)
                .fontSize(this.model.leftTitleFontSize)
                .fontColor(this.model.leftTitleFontColor)
        }
        .height(this.model.titleBarMinHeight)
        .padding(this.model.titleBarNormalPadding)
        .backgroundColor(this.model.leftTitleBackground)
        .onClick({ evt: ClickEvent => this.model.onLeftClickListener() })
    }

    @Builder
    private func normalBothSidesLayoutRight() {
        Row(space: this.model.leftTitleSpace) {
            Text(this.model.rightTitleName)
                .maxLines(1)
                .fontSize(this.model.rightTitleFontSize)
                .fontColor(this.model.rightTitleFontColor)
        }
        .height(this.model.titleBarMinHeight)
        .padding(this.model.titleBarNormalPadding)
        .backgroundColor(this.model.rightTitleBackground)
        .onClick({ evt: ClickEvent => this.model.onRightClickListener() })
    }
}
