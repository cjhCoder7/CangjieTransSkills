package secondarylinkage

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_secondarylinkage.*

import std.collection.*

import utils.component.FunctionDescription

const TAG_LIST_LENGTH = 12  // TagList长度
const CONTENT_PER_TAG = 6   // 每个TAG对应多少个元素

@Entry
@Component
public class SecondaryLinkageExample {
    @State @Watch[onIndexChange] var currentTagIndex: Int64 = 0 // 一级列表焦点索引值
    private let tagLists: ArrayList<String> = ArrayList() // 一级列表数据
    @State var contentData: MyDataSource = MyDataSource() // 二级列表数据
    private let records: ArrayList<Int64> = ArrayList() // 二级列表分组count数量
    // TODO:知识点: 1.级联列表分别绑定不同的Scroller对象，通过调用Scroller对象方法实现控制列表滚动
    private let classifyScroller: Scroller = Scroller() // 一级列表Scroller对象
    private let scroller: Scroller = Scroller() // 二级列表Scroller对象
    private var tagIndexPosition: ListIndexPosition = ListIndexPosition(0, 0) // 一级列表可视区域的起始索引和终点索引
    private var isClickTagList: Bool = false // 是否点击一级列表

    /**
     * 生命周期函数
     */
    protected override func aboutToAppear(): Unit {
        // 构造数据
        for (i in 0..TAG_LIST_LENGTH) {
            this.tagLists.append("类别${i+1}")
            let tempData = ArrayList<CustomDataType>(CONTENT_PER_TAG, { index => CustomDataType("内容数据", "类别${i+1}")})
            this.records.append(i * CONTENT_PER_TAG)
            this.contentData.pushData(tempData)
        }
        this.records.append(CONTENT_PER_TAG * TAG_LIST_LENGTH)
    }

    func build() {
        Column() {
            FunctionDescription(
                title: "二级联动",
                content: "当前界面主要展示了通过选择一个列表（一级列表），来更新另一个列表（二级列表）的选项的效果"
            )

            Row() {
                // TODO:知识点: 2.一级列表绑定Scroller对象
                List(initialIndex: 0, scroller: this.classifyScroller) {
                    // 性能知识点：此处为横向列表，列表项确定且数量较少，使用了ForEach，在列表项多的情况下，推荐使用LazyForeEach
                    ForEach(this.tagLists, itemGeneratorFunc: {item: String, index: Int64 =>
                        ListItem() {
                            this.tagListItemBuilder(item, index)
                        }
                    })
                }
                .onScrollIndex({start, end =>
                    this.tagIndexPosition = ListIndexPosition(Int64(start), Int64(end))
                })
                .listDirection(Axis.Vertical)
                .scrollBar(BarState.Off)
                .height(100.percent)
                .width(27.percent)

                // 二级列表
                List(space: ITEM_GUTTER, scroller: this.scroller) {
                    /*
                      性能知识点：列表中数据较多且不确定的情况下，使用LazyForEach进行数据循环渲染。
                      当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用。
                      文档参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609
                     */
                    LazyForEach(this.contentData, itemGeneratorFunc: {item, index =>
                        ListItem() {
                            this.contentListItemBuilder(item, index)
                        }
                        .padding(
                            left: 8,    // FIXME: 仓颉 padding 针对 CJResource 类型的入参，没有提供默认值，不能使用 @r(sys.float.ohos_id_card_margin_start)
                            right: 8    // FIXME：仓颉 padding 针对 CJResource 类型的入参，没有提供默认值，不能使用 @r(sys.float.ohos_id_card_margin_end)
                        )
                    })

                    ListItem() {
                        this.contentListNoMoreBuilder()
                    }.width(100.percent)
                }
                .scrollBar(BarState.Off)
                .listDirection(Axis.Vertical)
                .flexShrink(1)
                .divider(
                    strokeWidth: @r(app.string.secondary_linkage_stroke_width), // FIXME：仓颉 divider 针对 CJResource 类型的入参，没有提供默认值，不能直接使用 1
                    color: @r(sys.color.ohos_id_color_list_separator),
                    startMargin: @r(sys.float.ohos_id_card_margin_start),
                    endMargin: @r(sys.float.ohos_id_card_margin_end)
                )
                .onTouch({event: TouchEvent =>
                    if (let TouchType.Down <- event.eventType) {
                        this.isClickTagList = false //当前点击的非一级列表
                    }
                })
                // 性能知识点:onScrollIndex事件在列表滚动时频繁执行，在回调中需要尽量减少耗时和冗余操作，例如减少不必要的日志打印
                .onScrollIndex({start, end =>
                    let currentClassIndex = this.findClassIndex(Int64(start))
                    if (currentClassIndex != this.currentTagIndex && this.isClickTagList != true) {
                        this.currentTagIndex = currentClassIndex
                        this.classifyScroller.scrollToIndex(Int32(currentClassIndex), smooth: true)
                    }
                })
            }
            .width(100.percent)
            .layoutWeight(1)
        }
    }
    /**
     * 内容底部"没有更多"视图
     */
    @Builder
    func contentListNoMoreBuilder() {
        Text("没有更多了")
            .fontColor(@r(sys.color.ohos_fa_text_secondary))
    }

    /**
     * 右侧内容视图
     */
    @Builder
    func contentListItemBuilder(item: CustomDataType, index: Int64) {
        Row(ITEM_GUTTER) {
            Text("")
                .aspectRatio(1)
                .height(100.percent)
                .backgroundColor(@r(sys.color.ohos_id_color_component_normal))
                .borderRadius(@r(sys.float.ohos_id_corner_radius_default_m))
            Column(SUB_ITEM_GUTTER) {
                Text(item.desc + "${index}")
                Text(item.tag)
                    .fontSize(@r(sys.float.ohos_id_text_size_body2))
                    .fontColor(0xFF3CC824)
                Text("")
                    .height(SUB_ITEM_TEXT_HEIGHT)
                    .width(SUB_ITEM_TEXT_WIDTH_TITLE)
                    .backgroundColor(@r(sys.color.ohos_id_color_component_normal))
                Text("")
                    .height(SUB_ITEM_TEXT_HEIGHT)
                    .width(SUB_ITEM_TEXT_WIDTH_BODY)
                    .backgroundColor(@r(sys.color.ohos_id_color_component_normal))
            }
            .width(100.percent)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.SpaceEvenly)
            .height(100.percent)
        }
        .backgroundColor(0xFFFFFF)
        .height(SUB_ITEM_HEIGHT)
    }

    /**
     * 左侧类别视图
     */
    @Builder
    func tagListItemBuilder(item: String, index: Int64) {
        Text(item)
            .width(100.percent)
            .height(TAG_TEXT_HEIGHT)
            .fontWeight(FontWeight.Regular)
            .fontColor(@r(sys.color.ohos_fa_text_secondary))
            .textAlign(TextAlign.Center)
            .backgroundColor(if (this.currentTagIndex == index) {
                @r(sys.color.ohos_id_color_background)
            } else {
                @r(sys.color.ohos_id_color_component_normal)
            })
            .onTouch({event: TouchEvent =>
                if (let TouchType.Down <- event.eventType) {
                    this.isClickTagList = true; //当前点击的是一级列表
                }
            })
            .onClick({event =>
                // TODO:知识点: 3.点击一级列表后，通过一级列表索引获取二级列表索引，分别操作不同的Scroller对象使列表滚动到指定位置
                this.currentTagIndex = index
                let itemIndex = this.findItemIndex(index);
                this.scroller.scrollToIndex(Int32(itemIndex), smooth: true)
            })
    }

    /**
     * 根据一级列表索引值获取二级列表索引值
     *
     * @param {number} index - 一级列表索引值
     * @returns {number} 二级列表索引值
     */
    func findItemIndex(index: Int64): Int64 {
        return this.records[index]
    }

    /**
     * 根据二级列表索引值获取对应一级列表索引
     *
     * @param {number} index - 二级列表索引值
     * @returns {number} 一级列表索引值
     */
    func findClassIndex(index: Int64): Int64 {
        var ans = 0
        for (i in 0..this.records.size) {
            if (index >= this.records[i] && index < this.records[i + 1]) {
                ans = i;
                break
            }
        }
        return ans
    }

    /**
     * 监听一级列表获焦索引变化
     */
    func onIndexChange() {
        let start = this.tagIndexPosition.start
        let end = this.tagIndexPosition.end

        if (this.currentTagIndex == end || this.currentTagIndex == end - 1) {
            var leftScrollCount = this.currentTagIndex + 1
            if (leftScrollCount >= this.tagLists.size - 1) {
                leftScrollCount =this.tagLists.size - 1
            }
            /**
             * scrollToIndex(value: number, smooth?: boolean, align?: ScrollAlign)
             * 性能知识点：开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题。
             */
            this.classifyScroller.scrollToIndex(Int32(leftScrollCount), smooth: true)   // 使获焦item向左滚动
        }
        if (this.currentTagIndex == start || this.currentTagIndex == start + 1) {
            var rightScrollCount = this.currentTagIndex - 1
            if (rightScrollCount <= 0) {
                rightScrollCount = 0
            }
            this.classifyScroller.scrollToIndex(Int32(rightScrollCount), smooth: true)  // 使获焦item向右滚动
        }
    }
}