/**
 * Created on 2024/10/22
 */
package pendingitems.pages

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
internal import cj_res_pendingitems.*
import ohos.prompt_action.*
internal import std.collection.*
internal import pendingitems.model.*

// FIXME：仓颉不支持 @Extend 扩展UI组件
//@Extend(Image)
//function imageStyle() {
//  .aspectRatio(1)
//  .width(STYLE_CONFIG.IMAGE_SIZE)
//  .margin(STYLE_CONFIG.IMAGE_MARGIN)
//}

@CustomDialog
public class MyTextPickerDialog {
    var controller: Option<CustomDialogController> = Option.None
    var callback: (ToDo) -> Unit
    var select: UInt32 = 1
    private let availableThings: Array<String> = ['读书', '运动', '旅游', '听音乐', '看电影', '唱歌'] // 待办可选事项
    func build() {
        Column() {
            TextPicker(this.availableThings, selected: this.select)
                .width(80.percent)
                .margin(top: 16, bottom: 30)
                .onChange({result: TextPickerResData =>
                    this.select = result.index

                })
            Row(20) {
                Button("取消")
                    .width(40.percent)
                    .onClick({event =>
                        controller?.close()
                    })

                Divider()
                    .vertical(true)

                Button("确定")
                    .width(40.percent)
                    .onClick({event =>
                        let newToDo = ToDo()
                        newToDo.name = this.availableThings[Int64(this.select)]
                        AppLog.info("确定：新增item：name = ${newToDo.name}")
                        callback(newToDo)
                        controller?.close()
                    })
            }
            .height(30)
            .margin(10)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
        }
        .width(100.percent)
    }
}


/*
 * 实现步骤：
 * 1. List组件绑定@State修饰的数组变量toDoData。
 * 2. ListItem组件设置左滑动效swipeAction属性。
 * 3. 触发点击事件新增/删除列表项，更新数组变量toDoData，并同时更新List组件UI(MVVM)。
 */
@Entry
@Component
public class ToDoList {
    @State
    var toDoData: ObservedArrayList<ToDo> = ObservedArrayList(); // 待办事项
    @State
    var achieveData: ObservedArrayList<ToDo> = ObservedArrayList(); // 已完成事项

    // 自定义弹窗的控制器
    var dialogController: CustomDialogController = CustomDialogController(
            CustomDialogControllerOptions(
                builder: MyTextPickerDialog(
                    callback: { item: ToDo =>
                        AppLog.info("callback：新增item：name = ${item.name}")
                        this.toDoData.prepend(item)
                        AppLog.info("callback：list length = ${this.toDoData.size}")
                    }
                ),
                alignment: DialogAlignment.Bottom
            )
        )

    func build() {
        Column() {
            Row(StyleConfig.LIST_ITEM_GUTTER) {
                Text("待办")
                    .fontSize(@r(sys.float.ohos_id_text_size_headline7))
                Blank()
                Image(@r(app.media.pendingitems_ic_public_add_filled))
                    .width(StyleConfig.MENU_IMAGE_SIZE)
                    .aspectRatio(1)
                    .onClick({ event =>
                        // TODO：知识点：1.根据文本选择的选择结果，向待办事项数组中添加数据
                        // FIXME：仓颉暂未提供 TextPickerDialog，当前只能使用 TextPicker + CustomDialog 来实现。
                        dialogController.open()
                    })
            }
            .height(12.percent)
            .width(100.percent)
            .padding(
                left: 10, // FIXME:仓颉的padding针对 CJResource 没有提供默认值，因此无法使用 @r(sys.float.ohos_id_max_padding_start),
                right: 10, // FIXME:仓颉的padding针对 CJResource 没有提供默认值，因此无法使用 @r(sys.float.ohos_id_max_padding_end)
            )
            .backgroundColor(Color.WHITE)

            // TODO：知识点：2.待办数据显示列表组件绑定数据变量toDoData
            List(initialIndex: 0, space: StyleConfig.LIST_ITEM_GUTTER) {
                // 未完成列表项
                if (this.toDoData.size != 0) {
                    ListItem() {
                        Text("未完成").fontSize(@r(sys.float.ohos_id_text_size_headline8))
                    }
                }

                // 性能知识点：ForEach主要用于循环数据量小的数据，数据量大建议使用LazyForEach
                ForEach(
                    this.toDoData,
                    itemGeneratorFunc: { toDoItem: ToDo, index: Int64 =>
                        ListItem() {
                            ToDoListItem(
                                toDoItem: toDoItem,
                                achieveData: achieveData,
                                toDoData: toDoData
                            )
                        }
                        // TODO：知识点：3.设置ListItem的swipeAction属性，左滑时，显示自定义UI视图
                        // FIXME: 仓颉的 .swipeAction 未生效，存在bug
                        .swipeAction(end: {=> bind(itemEnd, this)(toDoItem)}, edgeEffect: SwipeEdgeEffect.Spring)
                    },
                    keyGeneratorFunc: { toDoItem: ToDo, index: Int64 =>
                        toDoItem.key
                    }
                )

                // 已完成列表项
                if (this.achieveData.size != 0) {
                    ListItem() {
                        Text("已完成").fontSize(@r(sys.float.ohos_id_text_size_headline8))
                    }
                }
                ForEach(
                    this.achieveData,
                    itemGeneratorFunc: { toDoItem: ToDo, index: Int64 =>
                        ListItem() {
                            ToDoListItem(
                                toDoItem: toDoItem,
                                achieveData: achieveData,
                                toDoData: toDoData
                            )
                        }.swipeAction(end: {=> bind(itemEnd, this)(toDoItem)}, edgeEffect: SwipeEdgeEffect.Spring)
                    },
                    keyGeneratorFunc: { toDoItem: ToDo, index: Int64 =>
                        toDoItem.key
                    }
                )
            }
            .layoutWeight(1)
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring)
            .padding(
                top: @r(sys.float.ohos_id_default_padding_top),
                left: @r(sys.float.ohos_id_default_padding_start),
                right: @r(sys.float.ohos_id_default_padding_end),
                bottom: @r(sys.float.ohos_id_default_padding_bottom_fixed)
            )
        }
        .backgroundColor(Color(0xFFF1F3F5))
        .width(100.percent)
        .height(100.percent)
    }

    // item左滑显示工具栏
    @Builder
    func itemEnd(item: ToDo) {
        Row(StyleConfig.ICON_GUTTER) {
            Image(@r(app.media.pendingitems_ic_public_settings_filled))
                .aspectRatio(1) //FIXME：仓颉不支持 @Extend 扩展UI组件
                .width(StyleConfig.IMAGE_SIZE)
                .margin(StyleConfig.IMAGE_MARGIN)
                .onClick({ event =>
                    PromptAction.showToast(message: "功能待完善");
                })
            Image(@r(app.media.pendingitems_ic_public_detail_filled))
                .aspectRatio(1) //FIXME：仓颉不支持 @Extend 扩展UI组件
                .width(StyleConfig.IMAGE_SIZE)
                .margin(StyleConfig.IMAGE_MARGIN)
                .onClick({ event =>
                    PromptAction.showToast(message: "功能待完善");
                })
            Image(@r(app.media.pendingitems_ic_public_delete_filled))
                .aspectRatio(1) //FIXME：仓颉不支持 @Extend 扩展UI组件
                .width(StyleConfig.IMAGE_SIZE)
                .margin(StyleConfig.IMAGE_MARGIN)
                .onClick({ event =>
                    this.deleteTodoItem(item);
                })
        }
        .padding(StyleConfig.OPERATION_BUTTON_PADDING)
        .justifyContent(FlexAlign.SpaceEvenly)
    }

    /**
     * 删除待办/已完成事项
     */
    func deleteTodoItem(item: ToDo) {
        if (item.isFinished) {
            this.achieveData.removeIf({todoItem => item.key == todoItem.key})
        } else {
            this.toDoData.removeIf({todoItem: ToDo => item.key == todoItem.key})
        }
        PromptAction.showToast(message: "删除成功");
    }
}
