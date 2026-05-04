package functionalscenes.model

internal import ohos.base.*

// 首页瀑布流列表信息
public class SceneModuleInfo {
    public SceneModuleInfo(
        public let imageSrc!: CJResource,       // 首页列表图片
        public let name!: String,               // 首页列表名称
        public let appUri!: String,             // 路由信息
        public let category!: String,           // 分类
        public let ratingNumber!: Int32 = 1,    // 难度星级
        public let param!: String = ""          // 路由传参数据
    ) {}
}