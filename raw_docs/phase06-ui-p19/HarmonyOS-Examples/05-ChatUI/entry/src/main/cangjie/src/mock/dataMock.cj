/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.mock

import ohos_app_cangjie_entry.entity.*
import cj_res_entry.*
import ohos.resource_manager.*
import ohos.state_manage.*
import ohos.component.*
import ohos.state_macro_manage.*
import std.collection.HashMap
import ohos.base.*

public let user1 = User(1, "Michael", UserStatus.ONLINE,
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [2, 3, 4, 5, 6, 7, 8, 9, 10],
    [1], @r(app.media.avatar_01))
public let user2 = User(2, "Robert", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_02))
public let user3 = User(3, "John", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_03))
public let user4 = User(4, "David", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_04))
public let user5 = User(5, "William", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_05))
public let user6 = User(6, "Richard", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_06))
public let user7 = User(7, "Joseph", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_07))
public let user8 = User(8, "James", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_08))
public let user9 = User(9, "Thomas", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_09))
public let user10 = User(10, "Christopher", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_10))
public let user11 = User(11, "Charles", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_11))
public let user12 = User(12, "Mary", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_12))
public let user13 = User(13, "Patricia", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_13))
public let user14 = User(14, "Jennifer", UserStatus.ONLINE, [], [], [], @r(app.media.avatar_14))

public let userMap = HashMap<Int64, User>(
    (1, user1), (2, user2), (3, user3), (4, user4),
    (5, user5), (6, user6), (7, user7), (8, user8),
    (9, user9), (10, user10), (11, user11)
)

public let chat1 = Chat(1, 10, [
        Message(1, 1, "08/08", "说说你现在最期待的事情"),
        Message(2, 2, "08/08", "高铁二号线"),
        Message(3, 1, "08/08", "这不是2009年的事情了吗？"),
        Message(4, 2, "08/08", "对, 那会儿还是戈登·布朗"),
        Message(5, 1, "08/08", "咋拖到现在了"),
        Message(6, 2, "08/08", "预算不够啊"),
        Message(7, 1, "08/08", "这玩意要多少钱？"),
        Message(8, 2, "08/08", "已经涨到1000亿了"),
        Message(9, 1, "08/08", "区区1000亿英镑...")
    ])

public let chat2 = Chat(2, 1, [
        Message(10, 3, "08/08", "谢谢")
    ])

public let chat3 = Chat(3, 1, [
        Message(11, 4, "08/08", "兄弟，你应该学仓颉")
    ])

public let chat4 = Chat(4, 2, [
        Message(12, 1, "08/08", "你有没有空帮我解决一个问题"),
        Message(13, 5, "08/08", "写材料,改bug,写设计文档,写项目,申报材料,干不完,根本干不完"),
        Message(14, 5, "08/08", "你直接去stackoverflow上搜吧")
    ])

public let chat5 = Chat(5, 1, [
        Message(15, 6, "08/08", "我想吃牛肉了...")
    ])

public let chat6 = Chat(6, 1, [
        Message(16, 7, "08/08", "小区停电了")
    ])

public let chat7 = Chat(7, 2, [
        Message(17, 8, "08/08", "去不去鹤岗"),
        Message(18, 8, "08/08", "一起远程办公")
    ])

public let chat8 = Chat(8, 2, [
        Message(19, 9, "08/08", "上午的会你总结一下"),
        Message(20, 9, "08/08", "PPT也改一下")
    ])

public let chat9 = Chat(9, 1, [
        Message(21, 10, "08/08", "我想躺平")
    ])

public let chat10 = Chat(10, 120, [
        Message(22, 2, "08/08", "1999年,意大利的奢侈品服装品牌米索尼正在经历改朝换代的阵痛"),
        Message(23, 2, "08/08", "企业的新一代掌门人为品牌带来了新的设计理念"),
        Message(24, 2, "08/08", "然而,新的理念却并没有收到市场的欢迎"),
        Message(25, 2, "08/08", "一段时间下来,产品的销量一路递减"),
        Message(26, 2, "08/08", "如果再不能扭亏为盈,这块牌子就要毁了"),
        Message(27, 2, "08/08", "正当管理层一筹莫展时,一个好消息从东方传来"),
        Message(28, 2, "08/08", "他们当年推出的一款男款T恤在亚洲大受欢迎,产品已经卖脱销了"),
        Message(29, 2, "08/08", "米索尼全力补货,没想到的是,哪怕把欧洲的产能都砸进去,也补不上韩国一个地方的消费,看到自己的审美被市场认可,米索尼的老板们倍感欣慰"),
        Message(30, 2, "08/08", "正当他们沾沾自喜时,一个比较尴尬的消息传来,这款T恤的爆火,跟米索尼的设计本身一点关系都没有,单纯是因为一位豪杰,为他们免费带了货"),
        Message(31, 2, "08/08", "而这位带货能力如此之强大的顶流,就是著名的..."),
        Message(32, 3, "08/08", "韩国警察界的贝利亚"),
        Message(33, 4, "08/08", "赫尔曼拉姆的反向投影"),
        Message(34, 5, "08/08", "赞佩里尼的韩国化身"),
        Message(35, 6, "08/08", "闯空门界的天才小伙"),
        Message(36, 7, "08/08", "享誉半岛的硬核狠人"),
        Message(37, 8, "08/08", "大韩民国的跑路之神"),
        Message(38, 9, "08/08", "申昌源！")
    ])

public let chatMap = HashMap<Int64, Chat>(
    (1, chat1), (2, chat2), (3, chat3), (4, chat4),
    (5, chat5), (6, chat6), (7, chat7), (8, chat8),
    (9, chat9), (10, chat10)
)

public let group1 = Group(1, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
    10, @r(app.media.avatar_12))

public let groupMap = HashMap<Int64, Group>(
    (1, group1)
)