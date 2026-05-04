/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.concurrency.*
import markdown.components.*

@Entry
@Component
class IndexPage {
    /**
     * 滑动控制器
     */
    var scroller: Scroller = Scroller()

    func build() {
        Column {
            titleComponent(
                "Markdown测试用例",
                false
            )
            Scroll(scroller) {
                List() {
                    ListItem() {
                        itemListComponent(
                            "1、Markdown全量加载",
                            "CompletePage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "2、Markdown增量加载",
                            "IncrementPage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "3、单独代码块全量加载",
                            "CodeCompletePage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "4、单独代码块增量加载",
                            "CodeIncrementPage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "5、定制化设置全量加载",
                            "CustomizationCompletePage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "6、定制化设置增量加载",
                            "CustomizationIncrementPage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "7、列表嵌套markdown",
                            "ListMarkdownPage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "8、BUG用例",
                            "BugPage"
                        )
                    }
                    ListItem() {
                        itemListComponent(
                            "9、单独代码块BUG用例",
                            "BugCodePage"
                        )
                    }
                }
                // 设置ListItem在List交叉轴方向的布局方式
                .alignListItem(ListItemAlign.Center)
            }
            // 内边距
            .padding(bottom: 100)
            // 设置滚动方法
            .scrollable(ScrollDirection.Vertical)
        }
    }
}
