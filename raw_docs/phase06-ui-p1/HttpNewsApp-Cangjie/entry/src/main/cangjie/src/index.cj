package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import ohos.router.*
import ohos.prompt_action.*
import ohos.net.http.*

class MyDataSource <: IDataSource<CJResource> {
    public MyDataSource(let data_: ArrayList<CJResource>) {}
    public var listenerOp: Option<DataChangeListener> = None
    public func getData(index: Int64): CJResource {
        return data_[index]
    }

    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = listener
    }

    public func onUnregisterDataChangeListener(listener: DataChangeListener): Unit {
        listenerOp = None
    }

    public func totalCount(): Int64 {
        return data_.size
    }
}

let myDataSource: MyDataSource = MyDataSource(ArrayList<CJResource>([@r(app.media.swiper1),@r(app.media.swiper2),@r(app.media.swiper3)]))


@Entry
@Component
class EntryView {
    @State var imageIp: String = "http://192.168.3.11:8000"

    @State var titleMessage: String = "头条"

    var tabController: TabsController = TabsController()
    @State var currentIndex: Int32 = 0

    var swiperController: SwiperController = SwiperController()

    let controller = SearchController()
    @State var changeValue: String = ""
    @State var submitValue: String = ""

    // 新闻信息
    @State var newsLists : ObservedArrayList<News> = ObservedArrayList<News>()

    // 获取新闻数据
    protected override func onPageShow() {
        NewsManager.getInstance().getAll { res =>
            if (res) {
                newsLists = ObservedArrayList<News>(NewsManager.getInstance().newsLists)
            }
        }
    }

    func build() {
        Column() {
            Text(titleMessage)
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor(0xffffff)
                .backgroundColor(0xffbb86fc)
                .borderRadius(2)
                .margin(top:5,bottom:5)
                .width(98.percent)
                .height(40)

            Tabs(BarPosition.End, this.tabController) {
                TabContent {
                    Column() {
                        Search(value: "", placeholder: "",controller: controller)
                            .searchButton("搜索")
                            .width(100.percent)
                            .height(30)
                            .backgroundColor(0xDDDDDD)
                            .placeholderColor(0x000000)
                            .onSubmit({ value =>
                                submitValue = value
                                if(submitValue == ""){
                                    PromptAction.showToast(message:"搜索词不能为空")
                                } else{
                                    Router.push(url: "NewsSearchView", params: "${submitValue}")
                                }
                            })
                            .onChange({ value =>
                                changeValue = value
                            }).margin(top:5, bottom:5)
                        .id("searchComponent")

                        Swiper(swiperController) {
                            LazyForEach(myDataSource, itemGeneratorFunc: {element: CJResource, index: Int64 =>
                                Image(element)
                                    .width(100.percent)
                                    .height(20.percent)
                                    .borderStyle(BorderStyle.Solid)
                                    .borderRadius(10)
                                    .onClick({  evt =>
                                            Router.push(url: "NewsDetailView", params: "${newsLists[index].propId}")
                                    })
                            })
                        }.cachedCount(2)
                        .index(1)
                        .autoPlay(true)
                        .interval(3000)
                        .loop(true)
                        .duration(1000)
                        .itemSpace(0)
                        .curve(Curve.Linear)
                        .onChange({ index =>
                            AppLog.info(index.toString())
                        })

                        Text("热门主题")
                            .textAlign(TextAlign.Start)
                            .fontSize(14)
                            .fontColor(0x182431)
                            .margin(top:5,bottom:5)
                            .width(96.percent)

                        Grid() {
                            ForEach(this.newsLists, itemGeneratorFunc: {item: News, index: Int64 =>
                                if(item.propHot == "Y"){
                                    GridItem {
                                        Image(imageIp + "${item.propCover}")
                                        .objectFit(ImageFit.Fill)
                                        .width(100.percent)
                                        .height(100)
                                        .borderStyle(BorderStyle.Solid)
                                        .borderRadius(10)
                                        .onClick({  evt =>
                                             Router.push(url: "NewsDetailView", params: "${item.propId}")
                                        })
                                    }.margin(2)
                                }
                            }
                        )}.rowsTemplate("1fr").columnsTemplate("1fr 1fr")
                        .height(100)


                        Text("分类新闻")
                            .textAlign(TextAlign.Start)
                            .fontSize(14)
                            .fontColor(0x182431)
                            .margin(top:5,bottom:5)
                            .width(96.percent)

                        List(space: 5, initialIndex: 0 ) {
                            ForEach(this.newsLists, itemGeneratorFunc:{item: News,index: Int64  =>
                                ListItem() {
                                    Row(2){
                                         Image(imageIp + "${item.propCover}")
                                            .objectFit(ImageFit.Fill)
                                            .width(35.percent)
                                            .height(90)
                                            .borderStyle(BorderStyle.Solid)
                                            .borderRadius(10)

                                         Column(2){
                                                Text(item.propTitle)
                                                    .width(100.percent)
                                                    .height(25)
                                                    .fontSize(14)
                                                    .maxLines(1)
                                                    .textOverflow(TextOverflow.Ellipsis)
                                                    .textAlign(TextAlign.Start)
                                                Text(item.propContent )
                                                    .width(100.percent)
                                                    .height(40)
                                                    .fontSize(12)
                                                    .fontColor(0x555555)
                                                    .maxLines(2)
                                                    .textOverflow(TextOverflow.Ellipsis)
                                                    .textAlign(TextAlign.Start)
                                                Row(2){
                                                    Text(item.propPublishDate)
                                                        .width(60.percent)
                                                        .height(25)
                                                        .fontSize(10)
                                                        .fontColor(0xcccccc)
                                                        .textAlign(TextAlign.Start)
                                                    Text("🩷：${item.propLikeNum}" )
                                                        .width(30.percent)
                                                        .height(25)
                                                        .fontSize(10)
                                                        .fontColor(0xdddddd)
                                                        .textAlign(TextAlign.End)
                                                }
                                         }.width(64.percent).height(100)
                                    }.backgroundColor(0xFFFFFF)
                                }.onClick({  evt =>
                                      Router.push(url: "NewsDetailView", params: "${item.propId}")
                                })
                            })
                        }.width(100.percent).height(52.percent)
                        .scrollBar(BarState.Off)
                    }.width(98.percent)

                }
                .tabBar(icon: "/resources/base/media/tab_home.png", text: "头条")
                .id("tab0")

                TabContent {
                    Column() {
                        Text("视频")
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor(0x182431)
                        .opacity(0.4)
                        .height(100.percent)
                    }
                    .width(98.percent)
                    .height(100.percent)
                }
                .tabBar(icon: "/resources/base/media/tab_news.png", text: "视频")
                .id("tab1")

                TabContent() {
                    Column() {
                        Text("我的")
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor(0x182431)
                        .opacity(0.4)
                        .height(100.percent)
                    }
                    .width(98.percent)
                    .height(100.percent)
                }
                .tabBar(icon: "/resources/base/media/tab_user.png", text: "我的")
                .id("tab2")
            }
            .vertical(false)
            .scrollable(true)
            .barMode(BarMode.Fixed)
            .barWidth(100.percent)
            .barHeight(60)
            .animationDuration(400)
            .width(100.percent)
            .backgroundColor(0xF5F5F5)
            .onChange({ index: Int32  =>
                this.currentIndex = index
                if(this.currentIndex == 0){
                    titleMessage = "头条"
                } else if(this.currentIndex == 1){
                    titleMessage = "视频"
                } else if(this.currentIndex == 2){
                    titleMessage = "我的"
                }
            })
        }
        .width(100.percent)
        .height(96.percent)
        .margin(top: 2)
    }
}
