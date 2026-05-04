/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package markdown.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

/**
 * Markdown标题自定义控件
 */
@Component
class MarkdownHeadingComponent {
    /**
     * markdown配置
     */
    var markdownConfiguration: MarkdownConfiguration

    /**
     * 标题内容数据
     */
    var nodeViews: ArrayList<NodeView>

    /**
     * 定位需要的数组
     */
    var indexList: ArrayList<Int64> = ArrayList<Int64>()

    /**
     * 标题等级
     */
    @State
    var level: Int64 = 1

    /**
     * 长度
     */
    var size: Int64 = -1

    /**
     * 上边距 - 单位vp
     */
    var marginTop: Float64

    /**
     * 下边距 - 单位vp
     */
    var marginBottom: Float64

    /**
     * 控件宽度 - 单位px
     */
    @Prop
    var componentWidth: Float64

    /**
     * 脚注点击事件
     */
    var fontCallback: (String) -> Unit

    /**
     * 图片点击事件
     */
    var imageCallback: (String) -> Unit

    /**
     * 是否全量加载 - true：全量加载，fasle：增量加载
     */
    var isFull: Bool

    /**
     * 缓存的标题控件列表
     */
    var headingComponents: ArrayList<MarkdownHeadingComponent>

    /**
     * 懒加载数据源
     */
    @State
    var nodeViewList: ObservedArrayList<NodeView> = ObservedArrayList<NodeView>()

    /**
     * 块引用背景颜色
     */
    var blockQuoteBackGroupColor: Option<Color> = Option<Color>.None

    /**
     * 图片上边距
     */
    var imageMarginTop: Float64 = 0.0

    /**
     * 图片下边距
     */
    var imageMarginBottom: Float64 = 0.0

    /**
     * 是否列表中的标题
     */
    var isListTo: Bool = false

    /**
     * 是否只有一条链接数据
     */
    var isOneLink: Bool = false

    protected override func aboutToAppear(): Unit {
        // 初始化刷新数据
        refreshData(nodeViews, level)
        // 缓存当前控件
        headingComponents.append(this)
        if(nodeViewList.size==1 && nodeViewList[0].node is CommonmarkLink){
            isOneLink = true
        }else{
            isOneLink = false
        }
    }

    protected override func aboutToDisappear(): Unit {
        // 清除当前控件
        headingComponents.removeIf(
            {
                predicate => if (predicate.indexList == indexList && predicate.size == size) {
                    true
                } else {
                    false
                }
            })
    }

    func build() {
        Column() {
            // 标题内容
            headingTitleComponent()

            // 一级二级标题是否显示下划线
            if ((level == 1 || level == 2) && markdownConfiguration.markdownTheme.headingBreakHeight > 0.0) {
                Divider()
                    // 设置分割线颜色
                    .color(markdownConfiguration.markdownTheme.headingBreakColor)
                    // 设置分割线宽度
                    .strokeWidth(markdownConfiguration.markdownTheme.headingBreakHeight)
            }
        }
        // 设置元素内容的对齐方式
        .align(Alignment.Start)
        // 设置元素水平方向的布局
        .direction(Direction.Ltr)
        // 设置外边距属性
        .margin(top: isMarginTop(), bottom: isMarginBottom())
        // 设置组件自身的宽度
        .width(100.percent)
    }

    /**
     * 标题文字内容
     */
    @Builder
    func headingTitleComponent() {
        Text() {
            ForEach(
                nodeViewList,
                itemGeneratorFunc: {
                    item: NodeView, idx: Int64 => if (item.node is CommonmarkText) {
                        // 文本
                        headingTextComponent(
                            item,
                            markdownConfiguration,
                            level
                        )
                    } else if (item.node is Footnote) {
                        // 脚注
                        headingFootnoteComponent(
                            item,
                            markdownConfiguration,
                            level,
                            fontCallback
                        )
                    } else if (item.node is Code) {
                        // 内联代码
                        if(markdownConfiguration.markdownTheme.isCodeStyle){
                            MarkdownCodeLineImageSpanComponent(
                                markdownConfiguration: markdownConfiguration,
                                strCode: (item.node as Code)().getLiteral(),
                                strUrl: linkUrl(item)
                            )
                        }else{
                            headingCodeComponent(
                                item,
                                markdownConfiguration
                            )
                        }
                    } else if (item.node is CommonmarkLink) {
                        // 链接
                        if (isListTo && !markdownConfiguration.markdownTheme.isListLinkStyle && isOneLink) {
                            if(getLinkString(item).isSome()){
                                headingLinkComponent(
                                    item,
                                    getLinkString(item)(),
                                    markdownConfiguration,
                                    level
                                )
                            }else{
                                Span("")
                            }
                        } else {
                            if ((item.node as CommonmarkLink)().getDestination().startsWith("http://") || (item.node as CommonmarkLink)().getDestination().startsWith("https://")) {
                                if (item.node.getFirstChild().isSome() && item.node.getFirstChild()() is CommonmarkText) {
                                    if ((item.node.getFirstChild()() as CommonmarkText)().getLiteral().trimAscii().toRuneArray().size > 1) {
                                        MarkdownLinkRectImageComponent(
                                            markdownConfiguration: markdownConfiguration,
                                            strText: (item.node.getFirstChild()() as CommonmarkText)().getLiteral().trimAscii(),
                                            strUrl: (item.node as CommonmarkLink)().getDestination(),
                                            backGroupColor: markdownbackGroupColor(blockQuoteBackGroupColor, markdownConfiguration.markdownTheme.linkRectImageBackGroupColor)
                                        )
                                    } else {
                                        MarkdownLinkCircleImageComponent(
                                            markdownConfiguration: markdownConfiguration,
                                            strText: (item.node.getFirstChild()() as CommonmarkText)().getLiteral().trimAscii(),
                                            strUrl: (item.node as CommonmarkLink)().getDestination(),
                                            backGroupColor: markdownbackGroupColor(blockQuoteBackGroupColor, markdownConfiguration.markdownTheme.linkCircleImageBackGroupColor)
                                        )
                                    }
                                }
                            } else {
                                if (item.node.getFirstChild().isSome() && item.node.getFirstChild()() is CommonmarkText) {
                                    MarkdownLinkRectToolImageComponent(
                                        markdownConfiguration: markdownConfiguration,
                                        strText: (item.node.getFirstChild()() as CommonmarkText)().getLiteral(),
                                        strUrl: (item.node as CommonmarkLink)().getDestination(),
                                        strType: urlSafeBase64Decode((item.node as CommonmarkLink)().getDestination()),
                                        backGroupColor: markdownbackGroupColor(blockQuoteBackGroupColor, markdownConfiguration.markdownTheme.linkRectToolImageBackGroupColor)
                                    )
                                }
                            }
                        }
                    } else if (item.node is HardLineBreak) {
                        // 硬换行
                        Span("\n")
                    } else if (item.node is SoftLineBreak) {
                        // 软换行
                        Span(spanSoftLineBreak(markdownConfiguration.markdownTheme.isLineBreak))
                    } else if (item.node is LatexMathNode) {
                        // 数学公式节点
                        MarkdownLatexImageSpanComponent(
                            markdownConfiguration: markdownConfiguration,
                            componentWidth: componentWidth,
                            strLatexMath: (item.node as LatexMathNode)().latex,
                            backGroupColor: markdownbackGroupColor(blockQuoteBackGroupColor, markdownConfiguration.markdownTheme.latexMathBackGroupColor)
                        )
                    } else if (item.node is ImageHtmlNode) {
                        // HTML图片
                        MarkdownHtmlImageSpanComponent(
                            destination: (item.node as ImageHtmlNode)().getDestination(),
                            imageWidth: strToFloat64((item.node as ImageHtmlNode)().getWidth()),
                            imageHeight: strToFloat64((item.node as ImageHtmlNode)().getHeight()),
                            componentWidth:componentWidth,
                            imageCallback: imageCallback
                        )
                    } else if (item.node is StyleImage) {
                        //  图片Style节点
                        if((item.node as StyleImage)().getDestination().startsWith("./")){
                            MarkdownImageStyleSpanRawFileComponent(
                                markdownConfiguration: markdownConfiguration,
                                destination: (item.node as StyleImage)().getDestination(),
                                picStyle: (item.node as StyleImage)().styles,
                                componentWidth:componentWidth,
                                imageCallback: imageCallback
                            )
                        }else{
                            MarkdownImageStyleSpanComponent(
                                markdownConfiguration: markdownConfiguration,
                                destination: (item.node as StyleImage)().getDestination(),
                                picStyle: (item.node as StyleImage)().styles,
                                componentWidth:componentWidth,
                                imageCallback: imageCallback
                            )
                        }
                    } else if (item.node is CommonmarkImage) {
                        if((item.node as CommonmarkImage)().getDestination().startsWith("./")){
                            MarkdownImageSpanRawFileComponent(
                                markdownConfiguration: markdownConfiguration,
                                destination: (item.node as CommonmarkImage)().getDestination(),
                                componentWidth:componentWidth,
                                imageCallback: imageCallback
                            )
                        }else{
                            // 图片节点
                            MarkdownImageSpanComponent(
                                destination: (item.node as CommonmarkImage)().getDestination(),
                                componentWidth: componentWidth,
                                imageCallback: imageCallback
                            )
                        }
                    } else {
                        // TODO 其他节点
                        Span("")
                    }
                }
            )
        }
        // 设置多行文本的文本对齐方式
        .textAlign(TextAlign.Start)
        // 设置组件自身的宽度
        .width(100.percent)
        // 设置行高
        .lineHeight(tableLineHeight())
    }

    func isMarginTop():Float64{
        if(nodeViewList.size == 1 && nodeViewList[0].node is CommonmarkImage){
            return 0.0
        }else{
            return marginTop
        }
    }

    func isMarginBottom():Float64{
        if(nodeViewList.size == 1 && nodeViewList[0].node is CommonmarkImage){
            return 0.0
        }else{
            return marginBottom
        }
    }

    func tableLineHeight(): Float64 {
        return match (level) {
            case 1 => markdownConfiguration.markdownTheme.headingTextLineheight1
            case 2 => markdownConfiguration.markdownTheme.headingTextLineheight2
            case 3 => markdownConfiguration.markdownTheme.headingTextLineheight3
            case 4 => markdownConfiguration.markdownTheme.headingTextLineheight4
            case 5 => markdownConfiguration.markdownTheme.headingTextLineheight5
            case 6 => markdownConfiguration.markdownTheme.headingTextLineheight6
            case _ => markdownConfiguration.markdownTheme.headingTextLineheight6
        }
    }

    /**
     * 数据刷新
     */
    public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit {
        this.level = level // 等级
        let refreshNodeViewSize: Int64 = refreshNodeViews.size // 刷新进来的数据长度
        let nodeViewListSize: Int64 = nodeViewList.size // 页面缓存的数据长度
        if (isFull) {
            // 全量加载
            nodeViewList.clear()
            nodeViewList.appendAll(refreshNodeViews)
        } else {
            // 增量加载
            if (refreshNodeViewSize == 0) {
                return
            }
            if (refreshNodeViewSize > nodeViewListSize) {
                // 刷新数据的长度大于页面数据长度，需要添加数据
                if (nodeViewListSize >= 2) {
                    if (refreshNodeViews[nodeViewListSize - 2].node.getNodeType() != nodeViewList[nodeViewListSize - 2].node.getNodeType()) {
                        nodeViewList[nodeViewListSize - 2] = refreshNodeViews[nodeViewListSize - 2]
                    }
                    if ((refreshNodeViews[nodeViewListSize - 2].node is CommonmarkText) && (nodeViewList[nodeViewListSize - 2].node is CommonmarkText)) {
                        if ((refreshNodeViews[nodeViewListSize - 2].node as CommonmarkText)().getLiteral() != (nodeViewList[nodeViewListSize - 2].node as CommonmarkText)().getLiteral()) {
                            nodeViewList[nodeViewListSize - 2] = refreshNodeViews[nodeViewListSize - 2]
                        }
                    }
                }
                if (nodeViewListSize != 0) {
                    // 更新页面最后一条数据
                    nodeViewList[nodeViewListSize - 1] = refreshNodeViews[nodeViewListSize - 1]
                }
                // 循环添加所有新增数据
                for (i in refreshNodeViewSize - nodeViewListSize..0 : -1) {
                    nodeViewList.append(refreshNodeViews[refreshNodeViewSize - i])
                }
            } else if (refreshNodeViewSize == nodeViewListSize) {
                // 刷新数据的长度等于页面数据长度，需要更新当前数据
                // 有可能还需要刷新倒数第二条数据内容
                if (refreshNodeViewSize >= 2) {
                    if (refreshNodeViews[refreshNodeViewSize - 2].node.getNodeType() != nodeViewList[nodeViewListSize - 2].node.getNodeType()) {
                        nodeViewList[refreshNodeViewSize - 2] = refreshNodeViews[refreshNodeViewSize - 2]
                    }
                    if ((refreshNodeViews[refreshNodeViewSize - 2].node is CommonmarkText) && (nodeViewList[nodeViewListSize - 2].node is CommonmarkText)) {
                        if ((refreshNodeViews[refreshNodeViewSize - 2].node as CommonmarkText)().getLiteral() != (nodeViewList[nodeViewListSize - 2].node as CommonmarkText)().getLiteral()) {
                            nodeViewList[refreshNodeViewSize - 2] = refreshNodeViews[refreshNodeViewSize - 2]
                        }
                    }
                }
                // 刷新最后一条数据
                nodeViewList[nodeViewListSize - 1] = refreshNodeViews[refreshNodeViewSize - 1]
            } else {
                // 刷新数据小于页面数据长度，需要删除数据
                // 更新页面中间一条数据 - 刷新数据长度的最后一条数据
                if (refreshNodeViewSize >= 2) {
                    if (refreshNodeViews[refreshNodeViewSize - 2].node.getNodeType() != nodeViewList[refreshNodeViewSize - 2].node.getNodeType()) {
                        nodeViewList[refreshNodeViewSize - 2] = refreshNodeViews[refreshNodeViewSize - 2]
                    }
                    if ((refreshNodeViews[refreshNodeViewSize - 2].node is CommonmarkText) && (nodeViewList[refreshNodeViewSize - 2].node is CommonmarkText)) {
                        if ((refreshNodeViews[refreshNodeViewSize - 2].node as CommonmarkText)().getLiteral() != (nodeViewList[refreshNodeViewSize - 2].node as CommonmarkText)().getLiteral()) {
                            nodeViewList[refreshNodeViewSize - 2] = refreshNodeViews[refreshNodeViewSize - 2]
                        }
                    }
                }
                nodeViewList[refreshNodeViewSize - 1] = refreshNodeViews[refreshNodeViewSize - 1]
                // 循环删除所有多余数据
                for (i in 1..=(nodeViewListSize - refreshNodeViewSize)) {
                    nodeViewList.remove(nodeViewListSize - i)
                }
            }
        }
        size = nodeViewList.size // 更新列表长度
    }
}
