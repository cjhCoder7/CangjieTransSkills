/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package photoView

import ohos.hiappevent.Event
import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*
import kit.UIKit.*

@Component
public class PhotoView {
    @State
    var model: PhotoViewModel = PhotoViewModel()

    @State
    var currentScale: Float64 = 0.0

    public func zoomTo(scale: Float64, durationMs: Int32): Unit {
        if (scale > model.getMaximumScale()) {
            currentScale = model.getMaximumScale()
        } else if (scale < model.getMinimumScale()) {
            currentScale = model.getMinimumScale()
        } else {
            currentScale = scale
        }
        animateTo(
            AnimateParam(
                duration: durationMs,
                tempo: 0.5,
                curve: Curve.EaseInOut,
                delay: 0,
                iterations: 1,
                playMode: PlayMode.Normal,
                onFinish: {
                    => AppLog.info("play end")
                }
            ),
            {
                =>
                model.scale = currentScale
                model.updateMatrix()
            }
        )
    }

    func build() {
        Flex(FlexParams(direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center)
        ) {
            if (!model
                .strSrc
                .isEmpty()) {
                Image(model.strSrc)
                    .alt(model.previewImageStr)
                    .objectFit(model.imageFit)
                    .transform(model.matrix)
                    .interpolation(ImageInterpolation.Low)
                    .draggable(false)
                    .autoResize(true)
                    .onComplete(
                        {
                            event =>
                            model.sWidth = event.width
                            model.sHeight = event.height
                            model.componentWidth = event.componentWidth
                            model.componentHeight = event.componentHeight
                            model.contentHeight = event.contentHeight
                            model.contentWidth = event.contentWidth
                            model.contentOffSetX = event.contentOffsetX
                            model.contentOffSetY = event.contentOffsetY
                            let left: Float64 = event.contentOffsetX
                            let top: Float64 = event.contentOffsetY
                            let right: Float64 = event.contentOffsetX + event.contentWidth
                            let bottom: Float64 = event.contentOffsetY + event.contentHeight
                            model.rect = RectF(left, top, right, bottom)
                        }
                    )
            } else if (let Some(v) <- model.resourceSrc) {
                if (let Some(j) <- model.previewImageResource) {
                    Image(v)
                        .alt(j)
                        .objectFit(model.imageFit)
                        .transform(model.matrix)
                        .interpolation(ImageInterpolation.Low)
                        .draggable(false)
                        .autoResize(true)
                        .onComplete(
                            {
                                event =>
                                model.sWidth = event.width
                                model.sHeight = event.height
                                model.componentWidth = event.componentWidth
                                model.componentHeight = event.componentHeight
                                model.contentHeight = event.contentHeight
                                model.contentWidth = event.contentWidth
                                model.contentOffSetX = event.contentOffsetX
                                model.contentOffSetY = event.contentOffsetY
                                let left: Float64 = event.contentOffsetX
                                let top: Float64 = event.contentOffsetY
                                let right: Float64 = event.contentOffsetX + event.contentWidth
                                let bottom: Float64 = event.contentOffsetY + event.contentHeight
                                model.rect = RectF(left, top, right, bottom)
                            }
                        )
                } else {
                    Image(v)
                        .objectFit(model.imageFit)
                        .transform(model.matrix)
                        .interpolation(ImageInterpolation.Low)
                        .draggable(false)
                        .autoResize(true)
                        .onComplete(
                            {
                                event =>
                                model.sWidth = event.width
                                model.sHeight = event.height
                                model.componentWidth = event.componentWidth
                                model.componentHeight = event.componentHeight
                                model.contentHeight = event.contentHeight
                                model.contentWidth = event.contentWidth
                                model.contentOffSetX = event.contentOffsetX
                                model.contentOffSetY = event.contentOffsetY
                                let left: Float64 = event.contentOffsetX
                                let top: Float64 = event.contentOffsetY
                                let right: Float64 = event.contentOffsetX + event.contentWidth
                                let bottom: Float64 = event.contentOffsetY + event.contentHeight
                                model.rect = RectF(left, top, right, bottom)
                            }
                        )
                }
            } else if (let Some(j) <- model.pixelSrc) {
                if (let Some(p) <- model.previewImagePixelMap) {
                    Image(j)
                        .alt(p)
                        .objectFit(model.imageFit)
                        .transform(model.matrix)
                        .interpolation(ImageInterpolation.Low)
                        .draggable(false)
                        .autoResize(true)
                        .onComplete(
                            {
                                event =>
                                model.sWidth = event.width
                                model.sHeight = event.height
                                model.componentWidth = event.componentWidth
                                model.componentHeight = event.componentHeight
                                model.contentHeight = event.contentHeight
                                model.contentWidth = event.contentWidth
                                model.contentOffSetX = event.contentOffsetX
                                model.contentOffSetY = event.contentOffsetY
                                let left: Float64 = event.contentOffsetX
                                let top: Float64 = event.contentOffsetY
                                let right: Float64 = event.contentOffsetX + event.contentWidth
                                let bottom: Float64 = event.contentOffsetY + event.contentHeight
                                model.rect = RectF(left, top, right, bottom)
                            }
                        )
                } else {
                    Image(j)
                        .objectFit(model.imageFit)
                        .transform(model.matrix)
                        .interpolation(ImageInterpolation.Low)
                        .draggable(false)
                        .autoResize(true)
                        .onComplete(
                            {
                                event =>
                                model.sWidth = event.width
                                model.sHeight = event.height
                                model.componentWidth = event.componentWidth
                                model.componentHeight = event.componentHeight
                                model.contentHeight = event.contentHeight
                                model.contentWidth = event.contentWidth
                                model.contentOffSetX = event.contentOffsetX
                                model.contentOffSetY = event.contentOffsetY
                                let left: Float64 = event.contentOffsetX
                                let top: Float64 = event.contentOffsetY
                                let right: Float64 = event.contentOffsetX + event.contentWidth
                                let bottom: Float64 = event.contentOffsetY + event.contentHeight
                                model.rect = RectF(left, top, right, bottom)
                            }
                        )
                }
            } else {
                return
            }
        }
            .gesture(
                GestureGroup(
                    GestureMode.Exclusive,
                    [
                        TapGesture(count: 2, fingers: 1).onAction(
                            {
                                event =>
                                if (model.isZoom) {
                                    if (model.scale == model.scaleMax) {
                                        model.scale = model.scaleMin
                                        model.childSpan = false
                                        model.resetMatrix()
                                    } else {
                                        if (model.scale < model.scaleMax) {
                                            model.scale = model.scaleMax
                                            // model.panDirection = PanDirection.All TODO..
                                            // model.swipeDirection = SwipeDirection.None TODO..
                                            model.childSpan = true
                                        } else {
                                            model.scale = model.scaleMin
                                            // model.panDirection = PanDirection.None TODO..
                                            // model.swipeDirection = model.cacheSwipeDirection TODO..
                                            model.childSpan = false
                                        }
                                        if (model.animate) {
                                            zoomTo(model.scale, model.mZoomDuration)
                                        } else {
                                            model.updateMatrix()
                                        }
                                    }
                                }
                                if (let Some(v) <- model.matrixChangedListener) {
                                    v.onMatrixChanged(model.rect)
                                }
                                if (let Some(v) <- model.scaleChangeListener) {
                                    v.onScaleChange(model.scale, 0.0, 0.0)
                                }
                                if (let Some(v) <- model.doubleTapListener) {
                                    v.onDoubleTap(event)
                                }
                            }
                        ),
                        TapGesture(count: 1, fingers: 1).onAction(
                            {
                                event =>
                                if (let Some(v) <- model.clickListener) {
                                    v.onClick(event)
                                }
                                if (event
                                    .fingerList
                                    .isEmpty()) {
                                    return
                                }
                                if (let Some(v) <- model.viewTapListener) {
                                    v.onViewTap(
                                        vp2px(event.fingerList[0]
                                            .globalX
                                            .vp)
                                            .getOrThrow()
                                            .value,
                                        vp2px(event.fingerList[0]
                                            .globalY
                                            .vp)
                                            .getOrThrow()
                                            .value
                                    )
                                }
                                if (let Some(v) <- model.rect) {
                                    // Check to see if the user tapped on the photo
                                    if (v.contains(
                                        vp2px(event.fingerList[0]
                                            .globalX
                                            .vp)
                                            .getOrThrow()
                                            .value,
                                        vp2px(event.fingerList[0]
                                            .globalY
                                            .vp)
                                            .getOrThrow()
                                            .value
                                    )) {
                                        let xResult: Float64 = (vp2px(event.fingerList[0]
                                            .globalX
                                            .vp)
                                            .getOrThrow()
                                            .value - v.left) / v.getWidth()
                                        let yResult: Float64 = (vp2px(event.fingerList[0]
                                            .globalY
                                            .vp)
                                            .getOrThrow()
                                            .value - v.top) / v.getHeight()
                                        if (let Some(v) <- model.photoTapListener) {
                                            v.onPhotoTap(xResult, yResult)
                                        }
                                    } else {
                                        if (let Some(v) <- model.outsidePhotoTapListener) {
                                            v.onOutsidePhotoTap()
                                        }
                                    }
                                }
                            }
                        ),
                        LongPressGesture()
                            .onAction({
                                event => if (let Some(v) <- model.longPressListener) {
                                    v.onLongPress(event)
                                }
                            })
                            .onActionEnd({event =>}),
                        PanGesture(model.panOption)
                            .onActionStart(
                                {
                                    event =>
                                    model.preOffsetX = model.offsetX
                                    model.preOffsetY = model.offsetY
                                }
                            )
                            .onActionUpdate(
                                {
                                    event => if (model.isZoom && model.scale != model.scaleMin) {
                                        model.setOffset(model.preOffsetX + event.offsetX * model.scale,
                                            model.preOffsetY + event.offsetY * model.scale)
                                    }
                                })
                            .onActionEnd(
                                {
                                    event =>
                                    if (let Some(v) <- model.viewDragListener) {
                                        v.onDrag(model.offsetX, model.offsetY)
                                    }
                                    if (let Some(v) <- model.matrixChangedListener) {
                                        v.onMatrixChanged(model.rect)
                                    }
                                }
                            ),
                        PinchGesture(fingers: 2)
                            .onActionUpdate(
                                {
                                    event => if (model.isZoom) {
                                        model.isPinch = true
                                        model.scale = model.currentScale * event.scale
                                        if (model.animate) {
                                            zoomTo(model.scale, model.mZoomDuration)
                                        } else {
                                            model.offsetX = 0.0
                                            model.offsetY = 0.0
                                            model.updateMatrix()
                                        }
                                    }
                                })
                            .onActionEnd(
                                {
                                    event =>
                                    model.isPinch = false
                                    if (model.scale < model.scaleMin) {
                                        model.scale = model.scaleMin
                                    }
                                    if (model.scale > model.scaleMax) {
                                        model.scale = model.scaleMax
                                    }
                                    model.currentScale = model.scale
                                    model.preOffsetX = 0.0
                                    model.preOffsetY = 0.0
                                    if (model.animate) {
                                        zoomTo(model.scale, model.mZoomDuration)
                                    } else {
                                        model.offsetX = 0.0
                                        model.offsetY = 0.0
                                        model.updateMatrix()
                                    }
                                    model.isZooming = (model.scale > 1.0)
                                    if (let Some(v) <- model.matrixChangedListener) {
                                        v.onMatrixChanged(model.rect)
                                    }
                                    if (let Some(v) <- model.scaleChangeListener) {
                                        v.onScaleChange(model.scale, 0.0, 0.0)
                                    }
                                }
                                //), TODO..
                            )
                        // SwipeGesture(direction: model.swipeDirection).onAction({ TODO..
                        // event => TODO..
                        // }), TODO..
                    ]
                )
            )
            .onTouch(
                {
                    event => if (event
                        .eventType
                        .toString() == TouchType
                        .Up
                        .toString()) {
                        //放大图片拖拽到边界后，启动滑动手势，将拖拽手势方向调整
                        if (!model.vertical && model.enableSwipe) {
                            if (model.isBoundary_X) {
                                model.isBoundary_X = false
                                model.gestureConversion(PanDirection.Vertical, SwipeDirection.Horizontal,
                                    Option<Bool>.None)
                            }
                        } else if (model.vertical && model.enableSwipe) {
                            if (model.isBoundary_Y) {
                                model.isBoundary_Y = false
                                model.gestureConversion(PanDirection.Horizontal, SwipeDirection.Vertical,
                                    Option<Bool>.None)
                            }
                        }
                    }
                })
    }
}
