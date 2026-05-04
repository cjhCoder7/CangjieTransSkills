package ohos_app_cangjie_entry
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import encoding.json.*
import std.random.*
import std.math.*
import ohos.hilog.*
import std.convert.*

public class Utils {
    static var rect_left: Float64 = 0.00f64
    static var rect_top: Float64 = 0.00f64
    static var rect_right: Float64 = 0.00f64
    static var rect_bottom: Float64 = 0.00f64
    static var rect_value: HashMap<String, Float64> = HashMap<String, Float64>()
    //获取组件所占矩形区域坐标
    static func getComponentRect(key: String): HashMap<String, Float64> {
        let strJson = getInspectorByKey(key)
        let obj = JsonValue.fromStr(strJson).asObject()
        let fields = obj.getFields()
        let children = fields.get("$rect").getOrThrow().toString()
        let strArr = children.split(",")
        rect_left = Float64.parse(strArr[0][2..])
        var temp = strArr[1]
        rect_top = Float64.parse(temp[..temp.size - 1])
        temp = strArr[2]
        rect_right = Float64.parse(temp[1..])
        temp = strArr[3]
        rect_bottom = Float64.parse(temp[0..temp.size - 2])
        rect_value.put("rect_left", rect_left)
        rect_value.put("rect_top", rect_top)
        rect_value.put("rect_right", rect_right)
        rect_value.put("rect_bottom", rect_bottom)
        return Utils.rect_value
    }
}

public struct Setting {
    public var x: Float64
    public var y: Float64
    public var r: Float64
    public var speedX: Float64
    public var speedY: Float64
    public var image: String
    public init() {
        this.x = 0.0
        this.y = 0.0
        this.r = 0.0
        this.speedX = Random().nextFloat64() * 30.0 - 15.0
        this.speedY = Random().nextFloat64() * 30.0 - 15.0
        this.image = ""
    }
    public init(x: Float64, y: Float64, r: Float64, speedX: Float64, speedY: Float64, image: String) {
        this.x = x
        this.y = y
        this.r = r
        this.speedX = speedX
        this.speedY = speedY
        this.image = image
    }
}

@Entry
@Component
class EntryView {
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    var particles: ArrayList<Setting> = ArrayList<Setting>()
    var timer: TextTimerController = TextTimerController()
    @State var z: Int32 = 10

    func data(x: Float64, y: Float64) {
        var images = ["resource://rawfile/icon1.png", "resource://rawfile/icon2.png", "resource://rawfile/icon3.png", "resource://rawfile/icon4.png",
        "resource://rawfile/icon5.png", "resource://rawfile/icon6.png", "resource://rawfile/icon7.png", "resource://rawfile/icon8.png"]
        var rawdata = ArrayList<Setting>([])
        for (i in 0..30) {
            rawdata.append(Setting(x, y, abs(Random().nextFloat64()) * 30.0 + 10.0, abs(Random().nextFloat64() * 10.0 - 3.0),
                abs(Random().nextFloat64() * 10.0 - 5.0), images[abs(Random().nextInt64()) % 8]));
        }
        return rawdata
    }

    func draw(contexts: CanvasRenderingContext2D, particle: ArrayList<Setting>): ArrayList<Setting>{
        var keepList = ArrayList<Int64>([])
        contexts.clearRect(0, 0, 600, 1200)
        for(i in 0..particle.size) {
            particle[i] = Setting(particle[i].x - 2.0 * abs(particle[i].speedX),  particle[i].speedY * 0.8 + particle[i].y - 10.0,
                particle[i].r - 0.8, particle[i].speedX, particle[i].speedY + 1.0, particle[i].image)
            contexts.beginPath()
            contexts.drawImage(ImageBitmap(particle[i].image), particle[i].x, particle[i].y, particle[i].r, particle[i].r)
            contexts.closePath()
            contexts.fill()
            if (particle[i].r > 20.0) {
                keepList.append(i)
            }
        }
        var newParticles = ArrayList<Setting>()
        for (i in keepList) {
            newParticles.append(particle[i])
        }
        return newParticles
    }

    func build() {
        Column {
            Stack(Alignment.Bottom) {
                Row {
                    List(space: 15) {
                        ForEach(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'], itemGeneratorFunc: {item: String, id: Int64 =>
                            ListItem {
                                Row {
                                    Text("这是一条测试列表")
                                    Image(@r(app.media.good)).id(item)
                                        .height(30).width(30).borderRadius(30)
                                        .onClick { _ =>
                                            z = -10
                                            particles = ArrayList<Setting>(data(Utils.getComponentRect(item).get("rect_left").getOrThrow() / 3.0 - 20.0,
                                                Utils.getComponentRect(item).get("rect_top").getOrThrow() / 3.0 - 80.0))
                                            this.timer.start()
                                        }
                                }.width(100.percent).justifyContent(FlexAlign.SpaceBetween).padding(15)
                            }
                        })
                    }.scrollBar(BarState.Off)
                    .divider(strokeWidth: 2.px, color: Color(0xDCDCDC), startMargin: 20.px, endMargin: 20.px)
                }.zIndex(z).padding(20).height(60.percent).backgroundColor(0xffffff)
                TextTimer(isCountDown: true, count: 1000, controller: this.timer)
                .format('mm:ss.SS')
                .height(0)
                .onTimer({ utc, elapsedTime =>
                    if (particles.size > 0) {
                       this.timer.reset()
                       this.timer.start()
                    } else {
                        z = 10
                        this.timer.reset()
                    }
                    particles = draw(context, particles)
                })
               Canvas(this.context).width(100.percent).height(100.percent)
            }.width(100.percent).height(100.percent)
        }.backgroundColor(0xC7EDCC)
    }
}
