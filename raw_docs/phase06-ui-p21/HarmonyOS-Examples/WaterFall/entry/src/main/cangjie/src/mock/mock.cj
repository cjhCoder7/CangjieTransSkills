/**
 * Created on 2024/8/27
 */
package ohos_app_cangjie_entry.mock

import ohos_app_cangjie_entry.entity.*
import std.collection.*
import std.random.*

let GLOBAL_RANDOM = Random()

public class ImageData {
    public ImageData(
        public var src: String,
        public var title: String,
        public var desc: String) {}
}

public class VideoData {
    public VideoData(
        public var src: String,
        public var preview: String,
        public var title: String,
        public var desc: String) {}
}

public class MockData {
    private static var nextNoId: Int64 = 0
    public var mediaType: MediaType
    public var title: String
    public var desc: String
    public var noId: Int64 = 0

    public init(mediaType: MediaType,title: String, desc: String) {
        this.mediaType = mediaType
        this.title = title
        this.desc = desc
        this.noId = nextNoId
        nextNoId ++
    }

    public init(imageData: ImageData) {
        this(MediaType.IMAGE(imageData.src), imageData.title, imageData.desc)
    }

    public init(videoData: VideoData) {
        this(MediaType.VIDEO((videoData.src, videoData.preview)), videoData.title, videoData.desc)
    }

    public init(mockData: MockData) {
        this(mockData.mediaType, mockData.title, mockData.desc)
    }
}

// 图片卡片的数据源
let mockImageDataList = [
    ImageData(
        "https://e.huawei.com/topic/sitecore/2022-digital-cities/img/europe//p3.jpg",
        "意大利Perdepera度假村",
        "享受无处不在的优质网络"
    ),
    ImageData(
        "https://e.huawei.com/topic/sitecore/2022-digital-cities/img/europe//p4.jpg",
        "奥地利空管",
        "携手华为保证空中每一次安全飞行"
    ),
    ImageData(
        "https://e.huawei.com/topic/sitecore/2022-digital-cities/img/europe//p5.jpg",
        "西班牙bonÀrea Agrupa",
        "数据中心网络全面升级，按下数字化转型加速键"
    ),
    ImageData(
        "https://e.huawei.com/topic/sitecore/2022-digital-cities/img/europe//p6.jpg",
        "德国Asklepios医疗集团",
        "防患于未然，数据长存无忧"
    ),
    ImageData(
        "https://www-file.huawei.com/-/media/corp2020/event/2024/5g-core-summit/5g-core-list.jpg",
        "2024年5G核心网峰会",
        "阿联酋 · 迪拜"
    ),
    ImageData(
        "https://www-file.huawei.com/-/media/corp2020/event/list/huawei-connect-2024-list-5.jpg",
        "华为全联接大会2024",
        "中国，上海"
    )
]

let mockVideoDataList = [
    VideoData(
        "https://e.huawei.com/topic/sitecore/2022-digital-cities/img/zhongdong/video-zhongdong.jpg",
        "https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2022/11/202abd98-231f-419c-af4c-ac9ad7884d3c.mp4",
        "数字中东",
        "数智并举，点亮中东数字化转型之旅"
    ),
    VideoData(
        "https://www-file.huawei.com/-/media/corp2020/media-center/image/our-value2/cover-chinese.jpg",
        "https://www-file.huawei.com/-/media/corp2020/media-center/video3/prasa%20chinese%20corrected_1080.mp4",
        "铁路守护者",
        "百废待兴，驶向数字化“快车道”迫在眉睫。"
    ),
    VideoData(
        "https://res-static.hc-cdn.cn/cloudbu-site/china/zh-cn/GSL20221208/huaweiyunstackanli/guangdongnongxin/896x504(1.jpg",
        "https://res-video.hc-cdn.com/cloudbu-site/china/zh-cn/HuaweiCloudStack/jiaotongyinghang/jiaotongyinghang-tonghui.mp4",
        "交通银行",
        "深度构建湖仓一体的数据平台，交通银行实现高质量发展。"
    ),
    VideoData(
        "https://www-file.huawei.com/-/media/corp2020/images/tech4all/cases1/12/white-headed-langur-cv.jpg",
        "https://www-file.huawei.com/-/media/corp2020/videos/tech4all/stories/3/guangxi-white-headed-langer-cn-1080.mp4",
        "拯救白猴",
        "从悬崖到云端：AI开启白头叶猴保护新纪元"
    )
]

public func mockData() {
    var mockDataList = ArrayList<MockData>()
    var ind = 0
    for(_ in 0..10) {
        ind = GLOBAL_RANDOM.nextInt64() % mockImageDataList.size
        if (ind < 0) {
            ind += mockImageDataList.size
        }
        mockDataList.append(MockData(mockImageDataList[ind]))
    }
//    for(_ in 0..4) {
//        ind = GLOBAL_RANDOM.nextInt64() % mockVideoDataList.size
//        mockDataList.append(MockData(mockVideoDataList[ind]))
//    }

    return mockDataList.toArray()
}




