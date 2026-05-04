/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package svg

import ohos.state_macro_manage.*
import ohos.concurrency.*

var pxTovp: Float64 = 0.0

@Component
public class SVGImageView {
    @State
    var model: SVGImageViewModel = SVGImageViewModel()
    private var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    private let context2D: CanvasRenderingContext2D = CanvasRenderingContext2D(this.settings)

    @Builder
    func setSvgCanvas(b: Bool) {
        Canvas(this.context2D).width(100.percent).height(100.percent).onReady(
            {
                =>
                this.model.setContext2D(this.context2D)
                this.model.viewWidth = this.context2D.width()
                this.model.viewHeight = this.context2D.height()
                this.model.doRender(this.model.context, areaChanged: true)
            }
        )
    }

    func build() {
        Column {
            setSvgCanvas(pxTovpRes())
        }
    }

    func pxTovpRes(): Bool {
        let optValue: Float64 = 55.0
        let res = px2vp(optValue.px).getOrThrow().value
        pxTovp = optValue / res
        return true
    }
}

@Observed
public class SVGImageViewModel {
    @Publish
    var svg: ?SVG = Option<SVG>.None
    var renderOptions: RenderOptionsBase = RenderOptionsBase()
    var settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    var context2D: CanvasRenderingContext2D = CanvasRenderingContext2D(settings)
    var canvas: CanvasImpl = CanvasImpl(this.context2D)
    var render: ?SVGRenderer = Option<SVGRenderer>.None
    var viewWidth: Float64 = Float64(getDefaultDisplaySync().width)
    var viewHeight: Float64 = Float64(getDefaultDisplaySync().height)
    var context: ?AbilityContext = Option<AbilityContext>.None
    var scaleX: Float64 = 0.0
    var scaleY: Float64 = 0.0
    var needScale: Bool = true

    public func setContext2D(context2D: CanvasRenderingContext2D): Unit {
        this.context2D = context2D
        this.canvas = CanvasImpl(this.context2D)
    }

    public func setSVG(svg: SVG, context: ?AbilityContext, css!: String = this.renderOptions.css): Unit {
        if (context.isSome()) {
            this.context = context
        }
        this.svg = svg
        doRender(context)
    }

    public func setCSS(css: String, context: ?AbilityContext): Unit {
        this.renderOptions.css = css
        if (context.isSome()) {
            this.context = context
        }
        doRender(context)
    }

    public func setImageResource(resource: OhosResource, context: ?AbilityContext): Unit {
        if (context.isSome()) {
            this.context = context
        }
        SVG.getFromResource(
            resource,
            {
                v: SVG => launch {
                    this.svg = v
                    doRender(context)
                }
            },
            context()
        )
    }

    public func setImageRawfile(filename: String, context: ?AbilityContext): Unit {
        if (context.isSome()) {
            this.context = context
        }
        SVG.getFromRawfile(
            filename,
            {
                v: SVG => launch {
                    this.svg = v
                    doRender(context)
                }
            },
            context()
        )
    }

    public func setFromString(data: String, context: ?AbilityContext): Unit {
        if (context.isSome()) {
            this.context = context
        }
        SVG.getFromString(
            data,
            {
                v: SVG => launch {
                    this.svg = v
                    doRender(context)
                }
            }
        )
    }

    public func doRender(context: ?AbilityContext, areaChanged!: Bool = false): Unit {
        if (context.isSome()) {
            this.context = context
        }
        if (this.svg.isNone()) {
            return
        }
        if (let Some(v) <- this.svg) {
            if (this.needScale || areaChanged) {
                let viewBoxWidth = v.getRootElement().viewBox.width
                let viewBoxHeight = v.getRootElement().viewBox.height
                let xScale = this.viewWidth / viewBoxWidth
                let yScale = this.viewHeight / viewBoxHeight
                this.scaleX = min(xScale, yScale)
                this.scaleY = min(xScale, yScale)
                this.context2D.scale(this.scaleX, this.scaleY)
                this.needScale = false
            }
            this.render = SVGRenderer(this.canvas, v.base.renderDPI, v.base.externalFileResolver)
            launch {
                this.render().renderDocument(v.base, this.renderOptions, context)
            }
        } else {
            return
        }
    }

    public func getSVGPixelMap(data: Array<UInt8>, context: ?AbilityContext): PixelMap {
        if (context.isSome()) {
            this.context = context
        }
        let value: String = String.fromUtf8(data)
        let fut = SVG.getFromString(
            value,
            {
                v: SVG => svg = v
            }
        )
        fut.get()
        let setTings: RenderingContextSettings = RenderingContextSettings(antialias: true)
        let svgRootElement = svg().getRootElement()
        // 根据屏幕分辨率适配
        let targetCompWidth: Float64 = this.viewWidth * px2vp(1.px).getOrThrow().value
        let targetCompHeight: Float64 = this.viewHeight * px2vp(1.px).getOrThrow().value
        let offContext: OffscreenCanvasRenderingContext2D = OffscreenCanvasRenderingContext2D(targetCompWidth, targetCompHeight, setTings, LengthMetricsUnit.DEFAULT)
        var minScale: Float64 = 1.0
        let scaleW: Float64 = targetCompWidth / svgRootElement.viewBox.width * 1.0
        let scaleH: Float64 = targetCompHeight / svgRootElement.viewBox.height * 1.0
        minScale = min(scaleW, scaleH) // 选择较小的缩放比例以确保完全适应目标尺寸
        offContext.setTransform(minScale, 0.0, 0.0, minScale, 0.0, 0.0)
        canvas.setOffScreenCanvas(offContext)
        render = SVGRenderer(canvas, svg().base.renderDPI, svg().base.externalFileResolver)
        render().renderDocument(svg().base, renderOptions, context).get()
        let minShowWidth: Float64 = svgRootElement.viewBox.width * px2vp(1.px).getOrThrow().value * minScale
        let minShowHeight: Float64 = svgRootElement.viewBox.height * px2vp(1.px).getOrThrow().value * minScale
        let pix = offContext.getPixelMap(0.0, 0.0, minShowWidth, minShowHeight)
        offContext.clearRect(0.0, 0.0, minShowWidth, minShowHeight)
        return pix
    }
}
