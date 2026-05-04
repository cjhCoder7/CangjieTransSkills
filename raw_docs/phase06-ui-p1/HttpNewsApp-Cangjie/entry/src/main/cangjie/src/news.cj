package ohos_app_cangjie_entry

import std.console.*
import std.collection.*
import std.convert.*
import encoding.json.*

import ohos.net.http.*
import serialization.serialization.*


/**
 * 新闻 类
 */
public class News <: ToString & Serializable<News> {
    // 成员变量
    private var id : UInt32                     // 编号
    private var cover : String                  // 封面
    private var title : String                  // 标题
    private var content : String                // 内容
    private var like_num : UInt32               // 点赞数
    private var hot : String                    // 热度
    private var publish_date : String           // 发布时间



    // 成员属性propId
    public mut prop propId: UInt32 {
        get() {
            id
        }
        set(id) {
            this.id = id
        }
    }

    public mut prop propCover: String {
        get() {
            cover
        }
        set(cover) {
            this.cover = cover
        }
    }

    public mut prop propTitle: String {
        get() {
            title
        }
        set(title) {
            this.title = title
        }
    }

    public mut prop propContent: String {
        get() {
            content
        }
        set(content) {
            this.content = content
        }
    }

    public mut prop propLikeNum: UInt32 {
        get() {
            like_num
        }
        set(like_num) {
            this.like_num = like_num
        }
    }

    public mut prop propHot: String {
        get() {
            hot
        }
        set(hot) {
            this.hot = hot
        }
    }

    public mut prop propPublishDate: String {
        get() {
            publish_date
        }
        set(publish_date) {
            this.publish_date = publish_date
        }
    }


    /**
     * 普通构造函数
     */
    public init () {
        // 初始化成员变量
        this.id = 0
        this.cover = ""
        this.title = ""
        this.content = ""
        this.like_num = 0
        this.hot = ""
        this.publish_date = ""
    }

    /**
     * 普通构造函数
     */
    public init (id : UInt32, cover : String, title : String, content : String, like_num : UInt32, hot : String, publish_date : String) {
        // 初始化成员变量
        this.id = id
        this.cover = cover
        this.title = title
        this.content = content
        this.like_num = like_num
        this.hot = hot
        this.publish_date = publish_date
    }


    /**
     * 输出新闻信息
     */
    public func outputInfo() {
        "编号: ${id} 封面: ${cover} 标题: ${title} 内容: ${content} 点赞数: ${like_num}  热点：${hot} 发布时间: ${publish_date}"
    }

    /**
     * 输出新闻信息（ToString 接口定义的转换字符串的函数）
     */
    public func toString() {
        outputInfo()
    }

    public func serialize(): DataModel {
        DataModelStruct()
            .add(field<UInt32>("id", id))
            .add(field<String>("cover", cover))
            .add(field<String>("title", title))
            .add(field<String>("content", content))
            .add(field<UInt32>("like_num", like_num))
            .add(field<String>("hot", hot))
            .add(field<String>("publish_date", publish_date))
    }

    public static func deserialize(dm: DataModel): News {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        var result = News()
        result.id = UInt32.deserialize(dms.get("id"))
        result.cover = String.deserialize(dms.get("cover"))
        result.title = String.deserialize(dms.get("title"))
        result.content = String.deserialize(dms.get("content"))
        result.like_num = UInt32.deserialize(dms.get("like_num"))
        result.hot = String.deserialize(dms.get("hot"))
        result.publish_date = String.deserialize(dms.get("publish_date"))

        return result
    }
}

/**
 * 新闻 管理类
 */
public class NewsManager {
    public var serverIp: String = "http://192.168.3.11:8080"

    /**
     * 新闻列表
     */
    public var newsLists : ArrayList<News>

    public var newsSearchLists : ArrayList<News>

    // 单例模式
    // 无法从外部访问构造函数
    private init() {
        // 初始化列表
        newsLists = ArrayList<News>()
        newsSearchLists = ArrayList<News>()
    }

    // 单例对象
    private static let instance : NewsManager = NewsManager()
    // 获取单例对象
    public static func getInstance() : NewsManager {
        return instance
    }

    /**
     * 通过编号查找新闻对象
     */
    func newsById(id : UInt32) : ?News {
        // 查找新闻
        for (i in 0..newsLists.size) {
            if (id == newsLists[i].propId) {
                return Some(newsLists[i])
            }
        }
        None
    }
    /**
     * 通过编号查找新闻对象
     */
    public func newsById(id : String) : ?News {
        var idInt = UInt32.tryParse(id)
        if (idInt.isSome()) {
            newsById(idInt ?? 0)
        } else {
            None
        }
    }

    /**
     * 同步新闻信息
     *
     * @param callback 回调函数
     */
    public func getAll(callback : (Bool)-> Unit) {
        let httpRequest = createHttp()
        let option = HttpRequestOptions(
            expectDataType: HttpDataType.STRING,
            header: HashMap<String, String>([("content-type", "application/json")])
        )
        let url = serverIp + "/news/all"
        httpRequest.request(url, { err, resp =>
                newsLists.clear()
                if (let Some(e) <- err) {
                    callback(false)
                }
                if (let Some(r) <- resp) {
                    let str = r.result.toString()
                    let jValue = JsonValue.fromStr(str)
                    let jArray = jValue.asArray()
                    for (i in 0..jArray.size()) {
                        var dm = DataModel.fromJson(jArray.get(i).getOrThrow().asObject())
                        let news = News.deserialize(dm)
                        newsLists.append(news)
                    }
                    callback(true)
                } else {
                    callback(false)
                }
                httpRequest.destroy()
            }, options: option)
    }

    /**
     * 查询新闻
     */
    public func queryNews(newsId : Int64, callback : (Bool)-> Unit) {
        let httpRequest = createHttp()
        let option = HttpRequestOptions(
            expectDataType: HttpDataType.STRING,
            header: HashMap<String, String>([("content-type", "application/json")])
        )
        let url = serverIp + "/news/query?id=${newsId}"
        httpRequest.request(url, { err, resp =>
                newsSearchLists.clear()
                if (let Some(e) <- err) {
                    callback(false)
                }
                if (let Some(r) <- resp) {
                    let str = r.result.toString()
                    let jValue = JsonValue.fromStr(str)

                    if (jValue.asObject().get("result").getOrThrow().asBool().getValue()) {
                        let jNews = jValue.asObject().get("news").getOrThrow().asObject()
                        var dm = DataModel.fromJson(jNews)
                        let news = News.deserialize(dm)
                        newsSearchLists.append(news)
                        callback(true)
                    }
                } else {
                    callback(false)
                }
                httpRequest.destroy()
            }, options: option)

    }

    /**
     * 查询新闻
     */
    public func queryNews(newsKey : String, callback : (Bool)-> Unit) {
        let httpRequest = createHttp()
        let option = HttpRequestOptions(
            expectDataType: HttpDataType.STRING,
            header: HashMap<String, String>([("content-type", "application/json")])
        )
        let url = serverIp + "/news/querytitle?title=${newsKey}"
        httpRequest.request(url,{ err, resp =>
                newsSearchLists.clear()
                if (let Some(e) <- err) {
                    callback(false)
                }
                if (let Some(r) <- resp) {
                    let str = r.result.toString()
                    let jValue = JsonValue.fromStr(str)
                    let jArray = jValue.asArray()
                    for (i in 0..jArray.size()) {
                        var dm = DataModel.fromJson(jArray.get(i).getOrThrow().asObject())
                        let news = News.deserialize(dm)
                        newsSearchLists.append(news)
                    }
                    callback(true)
                } else {
                    callback(false)
                }
                httpRequest.destroy()
            }, options: option)
    }

    /**
     * 添加新闻
     */
    public func addNews(news : News, callback : (Bool)-> Unit) {

        let httpRequest = createHttp()
        let option = HttpRequestOptions(
            expectDataType: HttpDataType.STRING,
            header: HashMap<String, String>([("content-type", "application/json")])
        )
        let url = serverIp + "/news/input?id=${news.propId}&cover=${news.propCover}&title=${news.propTitle}&content=${news.propContent}&like_num=${news.propLikeNum}&hot=${news.propHot}&publish_date=${news.propPublishDate}"
        httpRequest.request(url, { err, resp =>
                if (let Some(e) <- err) {
                    callback(false)
                }
                if (let Some(r) <- resp) {
                    let str = r.result.toString()
                    let jValue = JsonValue.fromStr(str).asObject().get("result")

                    if (jValue.getOrThrow().asBool().getValue()) {
                    callback(true)
                    }
                } else {
                    callback(false)
                }
                httpRequest.destroy()
            }, options: option)
    }
    /**
     * 修改新闻
     */
    public func modifyNews(news : News, callback : (Bool)-> Unit) {
        let httpRequest = createHttp()
        let option = HttpRequestOptions(
            expectDataType: HttpDataType.STRING,
            header: HashMap<String, String>([("content-type", "application/json")])
        )
        let url = serverIp + "/news/update?id=${news.propId}&cover=${news.propCover}&title=${news.propTitle}&content=${news.propContent}&like_num=${news.propLikeNum}&hot=${news.propHot}&publish_date=${news.propPublishDate}"
        httpRequest.request(url, { err, resp =>
                if (let Some(e) <- err) {
                    callback(false)
                }
                if (let Some(r) <- resp) {
                    let str = r.result.toString()
                    let jValue = JsonValue.fromStr(str).asObject().get("result")

                    if (jValue.getOrThrow().asBool().getValue()) {
                        callback(true)
                    }
                } else {
                    callback(false)
                }
                httpRequest.destroy()
            }, options: option)
    }

    /**
     * 删除新闻
     */
    public func deleteNews(newsId : Int64, callback : (Bool)-> Unit) {
        let httpRequest = createHttp()
        let option = HttpRequestOptions(
            expectDataType: HttpDataType.STRING,
            header: HashMap<String, String>([("content-type", "application/json")])
        )
        let url = serverIp + "/news/delete?id=${newsId}"
        httpRequest.request(url, { err, resp =>

                if (let Some(e) <- err) {
                    callback(false)
                }
                if (let Some(r) <- resp) {
                    let str = r.result.toString()
                    let jValue = JsonValue.fromStr(str).asObject().get("result")

                    if (jValue.getOrThrow().asBool().getValue()) {
                        callback(true)
                    }
                } else {
                    callback(false)
                }
                httpRequest.destroy()
            }, options: option)
    }
}