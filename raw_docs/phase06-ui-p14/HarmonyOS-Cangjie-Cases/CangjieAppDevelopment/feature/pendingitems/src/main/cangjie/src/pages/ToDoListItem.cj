/**
 * Created on 2024/10/22
 */
package pendingitems.pages

import ohos.state_macro_manage.*

@Component
public class ToDoListItem {
    @Link var achieveData: ObservedArrayList<ToDo> // 已完成列表项
    @Link var toDoData: ObservedArrayList<ToDo> // 未完成列表项
    @State var toDoItem: ToDo = ToDo() // item数据项
    @State var isEdited: Bool = false // 编辑状态

    func build() {
        Flex(FlexParams(justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center)) {
            Row(StyleConfig.ICON_GUTTER) {
                if (!this.isEdited) {
                    Row() {
                        if (this.toDoItem.isFinished) {
                            Image(@r(app.media.pendingitems_ic_public_ok_filled))
                                .width(StyleConfig.IMAGE_ICON_OK_SIZE)
                                .aspectRatio(1)
                                .borderRadius(StyleConfig.IMAGE_ICON_OK_SIZE)
                                .fillColor(Color.WHITE)
                                .transition(TransitionEffect.IDENTITY)
                        }
                    }
                    .width(StyleConfig.CUSTOM_CHECKBOX_SIZE)
                    .justifyContent(FlexAlign.Center)
                    .aspectRatio(1)
                    .borderRadius(StyleConfig.CUSTOM_CHECKBOX_SIZE)
                    .backgroundColor(
                        if (this.toDoItem.isFinished) {
                            Color.BLUE // TODO: 仓颉 CJResource 和 Color 类型不同，@r(sys.color.ohos_id_color_floating_button_bg_normal)
                        } else {
                            Color.TRANSPARENT
                        })
                    .borderWidth(1)
                    .borderColor(@r(sys.color.ohos_id_color_focused_content_tertiary))
                    .onClick({ evt =>
                        this.addAchieveData()
                    })

                    Text(this.toDoItem.name)
                        .fontSize(@r(sys.float.ohos_id_text_size_headline9))
                        .maxFontSize(StyleConfig.FONT_SIZE_MAX)
                        .minFontSize(StyleConfig.FONT_SIZE_MIN)
                        .layoutWeight(1)
                        .maxLines(3)
                        .textAlign(TextAlign.Center)
                        .textOverflow(TextOverflow.Ellipsis)
                        .decoration(
                            decorationType: if (this.toDoItem.isFinished) {TextDecorationType.LineThrough} else { TextDecorationType.None },
                            color: Color.BLACK
                        )
                } else {
                    TextInput(text: this.toDoItem.name)
                        //.maxLines(1)  //TODO: 仓颉不支持 maxLines
                        .fontSize(@r(sys.float.ohos_id_text_size_headline9))
                        .layoutWeight(1)
                        .backgroundColor(Color.TRANSPARENT)
                        .id('textEdit')
                        .onChange({ value =>
                          this.toDoItem.name = value // 更新待办事项数据
                        })
                        .onAppear({ =>
                          FocusControl.requestFocus('textEdit') // 请求输入框获取焦点
                        })
                }
                Blank()
                if (this.isEdited) {
                    Image(@r(app.media.pendingitems_ic_public_ok_filled))
                        .width(StyleConfig.MENU_IMAGE_SIZE)
                        .aspectRatio(1)
                        .onClick({ evt =>
                          this.isEdited = false
                        })
                } else {
                  Text("编辑")
                    .fontColor(@r(sys.color.ohos_id_color_text_secondary))
                    .onClick({ evt =>
                      this.isEdited = true
                    })
                }
            }
            .width(100.percent)
        }
        .width(100.percent)
        .height(StyleConfig.TODO_ITEM_HEIGHT)
        .padding(
            left: 10, //TODO: 仓颉不支持 CJResource 和 Int混用， $r('sys.float.ohos_id_default_padding_start'),
            right: 10, //TODO: 仓颉不支持 CJResource 和 Int混用， $r('sys.float.ohos_id_default_padding_end'),
            top: StyleConfig.TODO_ITEM_PADDING_VERTICAL,
            bottom: StyleConfig.TODO_ITEM_PADDING_VERTICAL
        )
        .borderRadius(@r(sys.float.ohos_id_corner_radius_default_m))
        .backgroundColor(Color.WHITE)
    }

    /**
    * 添加已完成数据项
    */
    func addAchieveData() {
        this.toDoItem.isFinished = true
        if (this.toDoItem.isFinished) {
            animateTo(
                AnimateParam(duration: Int32(StyleConfig.ANIMATION_DURATION)),
                { =>
                    this.toDoData.removeIf({item => item.key == this.toDoItem.key})
                    this.achieveData.append(this.toDoItem)
                })
        }
    }
}