/**
 * Created on 2025/1/7
 */
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import ohos.net.http.*
import ohos.prompt_action.*
import serialization.serialization.*
import encoding.json.*
import std.convert.*
import ohos.router.*


@Entry
@Component
class NewsDetailView {
    @State var imageIp: String = "http://192.168.3.11:8000"

    // 传入参数：新闻ID
    let newsId : Int64 = Int64.tryParse(Router.getParams() ?? "") ?? 0

    // 新闻对象
    @State var news : News = News()
    @State var strLike : String = ""


    // 显示界面时更新新闻
    protected override func onPageShow() {
        NewsManager.getInstance().queryNews(newsId) { res =>
            if (res) {
                news = NewsManager.getInstance().newsSearchLists[0]

                strLike = "🩷 ${news.propLikeNum}"
            }
        }
    }

    func build() {
        if(news.propId != 0){
            Column() {
                Text("新闻详情")
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor(0xffffff)
                    .backgroundColor(0xffbb86fc)
                    .borderRadius(2)
                    .margin(top:2,bottom:2)
                    .width(98.percent)
                    .height(40)
                Text("${news.propTitle}")
                    .textAlign(TextAlign.Center)
                    .fontSize(14)
                    .maxLines(2)
                    .textOverflow(TextOverflow.None)
                    .borderRadius(2)
                    .margin(top:2,bottom:2)
                    .width(98.percent)
                    .height(40)
                Text("${news.propPublishDate}")
                    .textAlign(TextAlign.Center)
                    .fontSize(12)
                    .fontColor(0xdddddd)
                    .margin(top:2,bottom:2)
                    .width(98.percent)
                    .height(20)
                Image(imageIp + "${news.propCover}")
                    .objectFit(ImageFit.Fill)
                    .width(98.percent)
                    .height(30.percent)
                    .borderStyle(BorderStyle.Solid)
                    .borderRadius(10)
                Text("${news.propContent}")
                    .textAlign(TextAlign.Start)
                    .fontSize(14)
                    .borderRadius(2)
                    .margin(top:2,bottom:2)
                    .width(98.percent)

                Row(){
                    Text("👉 分享" )
                        .width(25.percent)
                        .height(25)
                        .fontSize(12)
                        .fontColor(0xaaaaaa)
                        .textAlign(TextAlign.Center)
                        .onClick({  evt =>
                                      PromptAction.showToast(message:"已复制内容，可粘贴分享")
                                })

                    Text("💬 0" )
                        .width(25.percent)
                        .height(25)
                        .fontSize(12)
                        .fontColor(0xaaaaaa)
                        .textAlign(TextAlign.Center)
                        .onClick({  evt =>
                                      PromptAction.showToast(message:"期待你来开发新闻评论哦")
                                })
                    Text(strLike)
                        .width(25.percent)
                        .height(25)
                        .fontSize(12)
                        .fontColor(0xaaaaaa)
                        .textAlign(TextAlign.Center)
                        .onClick({  evt =>
                                    news.propLikeNum++
                                    strLike = "🩷 ${news.propLikeNum}"
                                    NewsManager.getInstance().modifyNews(news) { res =>
                                    }
                            })
                    Text("🌟 收藏")
                        .width(25.percent)
                        .height(25)
                        .fontSize(12)
                        .fontColor(0xaaaaaa)
                        .textAlign(TextAlign.Center)
                        .onClick({  evt =>
                             PromptAction.showToast(message: "已收藏!")
                        })
                }.height(40).margin(top:50)

            }.width(100.percent)
            .height(100.percent)
            .margin(top: 2)
        }
    }
}