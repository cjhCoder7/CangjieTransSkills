/**
 * Created on 2024/10/29
 * 电池电量组件。
 */
package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.math.MathExtension
import std.random.Random
import std.collection.ArrayList
import ohos.system_date_time.SystemDateTime
import ohos.concurrency.launch
import std.sync.sleep
import std.time.Duration

@Component
public class ElectricQuantity {
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)
    private let random: Random = Random()
    private let bubbles: ArrayList<Bubble> = ArrayList()
    @State
    var radius: Float64 = 12.0

    @Prop
    var power: Option<Int64>

    @Prop
    var isCharging: Bool

    var canvasArea: Option<Area> = Option<Area>.None

    private var animFuture: Option<Future<Unit>> = None

    public override func aboutToAppear(): Unit {
        random.seed = UInt64(SystemDateTime.getCurrentTime())
    }

    func build() {
        Stack(Alignment.Start) {
            Canvas(this.context).size(width: 100.percent, height: 100.percent).onAreaChange {
                _, area =>
                let width = px2vp(area.width.px).getOrThrow().value
                let height = px2vp(area.height.px).getOrThrow().value
                animFuture?.cancel()
                animFuture = spawn {
                    if (bubbles.isEmpty()) {
                        for (i in 0..15) {
                            bubbles.append(
                                Bubble(
                                    -(Float64(random.nextInt64(Int64(width * 100.0))) / 100.0),
                                    height / 2.0,
                                    Float64(4 + random.nextInt64(4)),
                                    (5 + random.nextInt64(10)) / 20.0,
                                    (5 + random.nextInt64(5)) / 150.0,
                                    random.nextBool()
                                )
                            )
                        }
                    }
                    while (!Thread.currentThread.hasPendingCancellation) {
                        launch {
                            drawNormal(width, height)
                            if (isCharging) {
                                for (bubble in bubbles) {
                                    bubble.measure(width, height)
                                    context.beginPath()
                                    context.arc(bubble.currentX, bubble.currentY, bubble.size, 0.0, Float64.PI * 2.0)
                                    context.fillStyle(0x66FFFFFF)
                                    context.fill()
                                }
                            }
                        }
                        sleep(Duration.millisecond * 8)
                    }
                }
            }
            if (power.isSome()) {
                Text {
                    Span("${power.getOrThrow()}").fontSize(32).fontWeight(FontWeight.W700)
                    Span("%").fontSize(28).fontWeight(FontWeight.W700)
                }.height(100.percent).textAlign(TextAlign.Center).margin(left: 18)
            } else {
                Text("--").fontSize(32).fontWeight(FontWeight.W700).height(100.percent).textAlign(TextAlign.Center).
                    margin(left: 18)
            }
        }.size(width: 300, height: 100)
    }

    private func drawNormal(width: Float64, height: Float64): Unit {
        context.beginPath()
        context.addRoundRectPath(width, height, radius)
        context.clip()
        context.fillStyle(0xF3F4F4)
        context.fillRect(0.0, 0.0, width, height)
        if (let Some(v) <- power) {
            let end = width * (v / 100.0)
            let grad = context.createLinearGradient(0.0, 0.0, end, height)
            if (isCharging) { //充电中
                grad.addColorStop(0.0, 0xCEFCB3)
                grad.addColorStop(1.0, 0x55C51E)
            } else if (v > 20) { //电量正常
                grad.addColorStop(0.0, 0xB3EEFC)
                grad.addColorStop(1.0, 0x4FBFD8)
            } else { //电量低
                grad.addColorStop(0.0, 0xFCB3B3)
                grad.addColorStop(1.0, 0xFF4D4F)
            }
            context.fillStyle(grad)
            context.fillRect(0.0, 0.0, width * (v / 100.0), height)
        }
    }

    public override func aboutToDisappear(): Unit {
        animFuture?.cancel()
    }
}

private class Bubble {
    private var curX: Float64 = 0.0
    private var curY: Float64 = 0.0

    prop currentX: Float64 {
        get() {
            return curX
        }
    }

    prop currentY: Float64 {
        get() {
            return curY
        }
    }

    Bubble(private let initialX: Float64, private let initialY: Float64, let size: Float64, private let speed: Float64,
        private let offset: Float64, private var flag: Bool) {
        reset()
    }

    func measure(width: Float64, height: Float64): Unit {
        curX += speed
        if (curX - size > width) {
            reset()
        }
        if (curX + size > 0.0) {
            if (curY < size || curY > height - size) {
                flag = !flag
            }
            if (flag) {
                curY += offset
            } else {
                curY -= offset
            }
        }
    }

    private func reset(): Unit {
        curX = initialX
        curY = initialY
    }
}

public interface CanvasContext2DExtision {

    /**
     * 添加一个圆角矩形路径。
     * @param width 画布的宽度，单位vp。
     * @param height 画布的高度，单位vp。
     * @param radius 圆角的半径，单位vp。
     */
    func addRoundRectPath(width: Float64, height: Float64, radius: Float64): Unit
}

extend CanvasRenderingContext2D <: CanvasContext2DExtision {
    public func addRoundRectPath(width: Float64, height: Float64, radius: Float64) {
        moveTo(radius, 0.0)
        lineTo(width - radius, 0.0)
        ellipse(width - radius, radius, radius, radius, 0.0, Float64.PI * 1.5, 0.0)
        lineTo(width, height - radius)
        ellipse(width - radius, height - radius, radius, radius, 0.0, 0.0, Float64.PI * 0.5)
        lineTo(radius, height)
        ellipse(radius, height - radius, radius, radius, 0.0, Float64.PI * 0.5, Float64.PI)
        lineTo(0.0, radius)
        ellipse(radius, radius, radius, radius, 0.0, Float64.PI, Float64.PI * 1.5)
    }
}

extend Int64 {
    public func toFloat64(): Float64 {
        return Float64(this)
    }
    public operator func *(right: Float64): Float64 {
        return Float64(this) * right
    }
    public operator func /(right: Float64): Float64 {
        return Float64(this) / right
    }
}