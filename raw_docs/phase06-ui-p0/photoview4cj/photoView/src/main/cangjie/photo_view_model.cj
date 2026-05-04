/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package photoView

import ohos.image.PixelMap
import ohos.resource_manager.*
import ohos.matrix4.*
import ohos.base.*
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.state_manage.*

@Observed
public class PhotoViewModel {
    @Publish
    var strSrc: String = ""
    @Publish
    var resourceSrc: ?AppResource = Option<AppResource>.None
    @Publish
    var pixelSrc: ?PixelMap = Option<PixelMap>.None
    @Publish
    var sWidth: Float64 = 0.0
    @Publish
    var sHeight: Float64 = 0.0
    @Publish
    var componentWidth: Float64 = 0.0
    @Publish
    var componentHeight: Float64 = 0.0
    @Publish
    var baseAngle: Float64 = 0.0
    @Publish
    var rotateAngle: Float64 = 0.0
    @Publish
    public var scale: Float64 = 1.0
    @Publish
    var currentScale: Float64 = 1.0
    @Publish
    var animate: Bool = false //  是否可手势缩放
    @Publish
    var imageFit: ImageFit = ImageFit.Contain
    @Publish
    public var scaleMin: Float64 = 1.0
    @Publish
    var scaleMed: Float64 = 2.0
    @Publish
    var scaleMax: Float64 = 3.0
    @Publish
    var isZoom: Bool = true
    @Publish
    var centerX: Float64 = 0.0
    @Publish
    var centerY: Float64 = 0.0
    @Publish
    var centerZ: Float64 = 0.0
    @Publish
    var offsetX: Float64 = 0.0
    @Publish
    var offsetY: Float64 = 0.0
    @Publish
    var preOffsetX: Float64 = 0.0
    @Publish
    var preOffsetY: Float64 = 0.0
    @Publish
    var verticalEnd: Bool = false
    //缩放后 平移到半屏边界的填充值
    @Publish
    var startOffsetX: Float64 = 10.0
    @Publish
    var startOffsetY: Float64 = 23.0
    var photoTapListener: ?OnPhotoTapListener = Option<OnPhotoTapListener>.None
    var doubleTapListener: ?OnDoubleTapListener = Option<OnDoubleTapListener>.None
    var longPressListener: ?OnLongPressListener = Option<OnLongPressListener>.None
    var clickListener: ?OnClickListener = Option<OnClickListener>.None
    var matrixChangedListener: ?OnMatrixChangedListener = Option<OnMatrixChangedListener>.None
    var viewTapListener: ?OnViewTapListener = Option<OnViewTapListener>.None
    var viewDragListener: ?OnViewDragListener = Option<OnViewDragListener>.None
    var scaleChangeListener: ?OnScaleChangedListener = Option<OnScaleChangedListener>.None
    var outsidePhotoTapListener: ?OnOutsidePhotoTapListener = Option<OnOutsidePhotoTapListener>.None
    var onSwipeListener: ?OnSwipeListener = Option<OnSwipeListener>.None
    @Publish
    var rect: ?RectF = Option<RectF>.None
    @Publish
    var iterations: Float64 = 0.0
    @Publish
    var mZoomDuration: Int32 = 200
    @Publish
    var scaledDensity: Float64 = 0.0
    @Publish
    var isZooming: Bool = false
    @Publish
    var dragging: Bool = false
    @Publish
    var contentHeight: Float64 = 0.0
    @Publish
    var contentWidth: Float64 = 0.0
    @Publish
    var contentOffSetX: Float64 = 0.0
    @Publish
    var contentOffSetY: Float64 = 0.0
    @Publish
    var previewImageStr: String = ""
    @Publish
    var previewImageResource: ?AppResource = Option<AppResource>.None
    @Publish
    var previewImagePixelMap: ?PixelMap = Option<PixelMap>.None
    //    @Publish var panDirection: PanDirection = PanDirection.None TODO..
    //    @Publish var swipeDirection: SwipeDirection = SwipeDirection.Horizontal TODO..
    //    @Publish var cacheSwipeDirection: SwipeDirection = SwipeDirection.Horizontal TODO..
    @Publish
    var childSpan: Bool = false
    @Publish
    var parentIsSwiper: Bool = false
    @Publish
    var matrix: Matrix4Transit = Matrix4.identity()
    //是否拖拽到边界
    var isBoundary_X: Bool = false
    var isBoundary_Y: Bool = false
    // 是否双指缩放
    var isPinch: Bool = false
    //是否垂直滑动
    var vertical: Bool = false
    //是否启动滑动
    var enableSwipe: Bool = true
    // 拖拽手势参数
    var panOption: PanGestureOptions = PanGestureOptions(fingers: 1, direction: PanDirection.None)

    public func initMatrix(): Unit {
        matrix
            .rotate(
                RotateOption(
                    x: 0.0,
                    y: 0.0,
                    z: 1.0,
                    angle: Float32(rotateAngle)
                )
            )
            .translate(TranslateOption(x: Float32(offsetX), y: Float32(offsetY)))
            .scale(ScaleOption(x: Float32(scale), y: Float32(scale)))
    }

    public func setVertical(isVertical: Bool): PhotoViewModel {
        vertical = isVertical
        return this
    }

    public func setImageURI(src: String): PhotoViewModel {
        strSrc = src
        return this
    }

    public func setImageResource(src: AppResource): PhotoViewModel {
        resourceSrc = src
        return this
    }

    public func setImageElement(src: PixelMap): PhotoViewModel {
        pixelSrc = src
        return this
    }

    public func setSwipeDirection(swipeDirection: SwipeDirection): PhotoViewModel {
        // this.swipeDirection = swipeDirection TODO..
        // cacheSwipeDirection = swipeDirection TODO..
        return this
    }

    public func isParentSwiper(parentIsSwiper: Bool): PhotoViewModel {
        this.parentIsSwiper = parentIsSwiper
        return this
    }

    public func setImageFit(imageFit: ImageFit): PhotoViewModel {
        this.imageFit = imageFit
        return this
    }

    public func setPreviewImageStr(src: String): PhotoViewModel {
        previewImageStr = src
        return this
    }

    public func setPreviewImageResource(src: AppResource): PhotoViewModel {
        previewImageResource = src
        return this
    }

    public func setPreviewImagePixelMap(src: PixelMap): PhotoViewModel {
        previewImagePixelMap = src
        return this
    }

    public func setScale(sca: Float64, anima: Bool): PhotoViewModel {
        scale = sca
        if (scale < scaleMin) {
            scale = scaleMin
        }
        if (scale > scaleMax) {
            scale = scaleMax
        }
        if (anima) {
            iterations = 1.0
        } else {
            iterations = 0.0
        }
        animate = anima
        return this
    }

    public func setZoomTransitionDuration(milliseconds: Int32): PhotoViewModel {
        mZoomDuration = milliseconds
        return this
    }

    public func getMinimumScale(): Float64 {
        return scaleMin
    }

    public func getMediumScale(): Float64 {
        return scaleMed
    }

    public func getMaximumScale(): Float64 {
        return scaleMax
    }

    public func getScale(): Float64 {
        return scale
    }

    public func setMinimumScale(minimumScale: Float64): PhotoViewModel {
        scaleMin = minimumScale
        return this
    }

    public func setMediumScale(mediumScale: Float64): PhotoViewModel {
        scaleMed = mediumScale
        return this
    }

    public func setMaximumScale(maximumScale: Float64): PhotoViewModel {
        scaleMax = maximumScale
        return this
    }

    public func setScaleLevels(minimumScale: Float64, mediumScale: Float64, maximumScale: Float64): PhotoViewModel {
        scaleMin = minimumScale
        scaleMed = mediumScale
        scaleMax = maximumScale
        return this
    }

    public func setBaseRotation(degrees: Int64): PhotoViewModel {
        rotateAngle = Float64(degrees % 360)
        setRotationBy(Int64(rotateAngle))
        return this
    }

    public func setRotationTo(rotationDegree: Int64): PhotoViewModel {
        rotateAngle = Float64(rotationDegree % 360)
        matrix = Matrix4
            .identity()
            .rotate(
                RotateOption(
                    x: 0.0,
                    y: 0.0,
                    z: 1.0,
                    angle: Float32(rotateAngle)
                )
            )
        return this
    }

    public func setRotationBy(rotationDegree: Int64): PhotoViewModel {
        rotateAngle = Float64((Int64(rotateAngle) + rotationDegree) % 360)
        matrix = Matrix4
            .identity()
            .rotate(
                RotateOption(
                    x: 0.0,
                    y: 0.0,
                    z: 1.0,
                    angle: Float32(rotateAngle)
                )
            )
        return this
    }

    public func setRotationCenter(x: Float64, y: Float64, z: Float64): PhotoViewModel {
        centerX = z
        centerY = y
        centerZ = z
        return this
    }

    public func setZoomable(zoomable: Bool): PhotoViewModel {
        if (!zoomable) {
            scale = scaleMin
            setImageFit(ImageFit.None)
            isZoom = false
            return this
        }
        isZoom = zoomable
        return this
    }

    public func isZoomEnabled(): Bool {
        return isZoom
    }

    public func setImageOffset(pointX: Float64, pointY: Float64): PhotoViewModel {
        offsetX = pointX
        offsetY = pointY
        return this
    }

    public func setOnClickListener(listener: OnClickListener): PhotoViewModel {
        clickListener = listener
        return this
    }

    public func setOnLongClickListener(listener: OnLongPressListener): PhotoViewModel {
        longPressListener = listener
        return this
    }

    public func setOnMatrixChangeListener(listener: OnMatrixChangedListener): PhotoViewModel {
        matrixChangedListener = listener
        return this
    }

    public func setOnPhotoTapListener(listener: OnPhotoTapListener): PhotoViewModel {
        photoTapListener = listener
        return this
    }

    public func setOnViewTapListener(listener: OnViewTapListener): PhotoViewModel {
        viewTapListener = listener
        return this
    }

    public func setOnViewDragListener(listener: OnViewDragListener): PhotoViewModel {
        viewDragListener = listener
        return this
    }

    public func setOnScaleChangeListener(scaleChangeListener: OnScaleChangedListener): PhotoViewModel {
        this.scaleChangeListener = scaleChangeListener
        return this
    }

    public func setOnOutsidePhotoTapListener(outsidePhotoTapListener: OnOutsidePhotoTapListener): PhotoViewModel {
        this.outsidePhotoTapListener = outsidePhotoTapListener
        return this
    }

    public func setOnDoubleTapListener(onDoubleTapListener: OnDoubleTapListener): PhotoViewModel {
        doubleTapListener = onDoubleTapListener
        return this
    }

    public func setOnSwipeListener(onSwipeListener: OnSwipeListener): PhotoViewModel {
        this.onSwipeListener = onSwipeListener
        return this
    }

    public func updateMatrix(): Unit {
        if (let Some(v) <- rect) {
            let originLeft: Float64 = contentOffSetX
            let originTop: Float64 = contentOffSetY
            let originWidth: Float64 = contentWidth
            let originHeight: Float64 = contentHeight
            let scaledWidth: Float64 = originWidth * scale
            let scaledHeight: Float64 = originHeight * scale
            let centerXOffset = (scaledWidth - originWidth) / 2.0
            let centerYOffset = (scaledHeight - originHeight) / 2.0
            v.left = originLeft + offsetX - centerXOffset
            v.top = originTop + offsetY - centerYOffset
            v.right = v.left + scaledWidth + centerXOffset
            v.bottom = v.top + scaledHeight + centerYOffset
        }

        if (enableSwipe && !isPinch) {
            //图片放大时禁用滑动手势，启动拖动手势
            //图片复原时启动滑动手势，禁用拖动手势
            if (scale == scaleMin) {
                if (!vertical) {
                    gestureConversion(PanDirection.None, SwipeDirection.Horizontal, Option<Bool>.None)
                } else {
                    gestureConversion(PanDirection.None, SwipeDirection.Vertical, Option<Bool>.None)
                }
            } else {
                gestureConversion(PanDirection.All, SwipeDirection.None, Option<Bool>.None)
            }
        }

        matrix = Matrix4
            .identity()
            .rotate(
                RotateOption(
                    x: 0.0,
                    y: 0.0,
                    z: 1.0,
                    angle: Float32(rotateAngle)
                )
            )
            .translate(TranslateOption(x: Float32(offsetX), y: Float32(offsetY), z: 1.0))
            .scale(ScaleOption(x: Float32(scale), y: Float32(scale), centerX: Float32(centerX),
                centerY: Float32(centerY)))
        if (let Some(v) <- onSwipeListener) {
            v.onSwipeListener(childSpan)
        }
    }

    //设置滑动手势与拖拽手势的方向
    public func gestureConversion(panDirection: PanDirection, swipeDirection: ?SwipeDirection, vertical: ?Bool): PhotoViewModel {
        panOption.setDirection(panDirection)
        if (let Some(v) <- swipeDirection) {
            // this.swipeDirection = v TODO..
            if (let Some(j) <- vertical) {
                this.vertical = j
            }
            if (!enableSwipe) {
                enableSwipe = true
            }
        } else {
            enableSwipe = false
            // swipeDirection = SwipeDirection.None TODO..
        }
        return this
    }

    public func resetMatrix(): Unit {
        scale = 1.0
        currentScale = 1.0
        centerX = 0.0
        centerY = 0.0
        offsetX = 0.0
        offsetY = 0.0
        rotateAngle = 0.0
        // panDirection = PanDirection.None TODO..
        // swipeDirection = cacheSwipeDirection TODO..
        updateMatrix()
    }

    public func getSuppMatrix(): Matrix4Transit {
        return matrix
    }

    public func setSuppMatrix(matrix: Matrix4Transit): PhotoViewModel {
        this.matrix = matrix
        return this
    }

    public func isScaling(): Bool {
        return scale != 1.0
    }

    public func isDragging(): Bool {
        return offsetX != 0.0 || offsetY != 0.0
    }

    public func getRectF(): ?RectF {
        return rect
    }

    public func setOffset(offsetX: Float64, offsetY: Float64): Unit {
        let maxOffsetX = (contentWidth * scale - componentWidth) / 2.0 / scale + 10.0
        let maxOffsetY = (contentHeight * scale - componentHeight) / 2.0 / scale + 10.0
        if (contentWidth * scale > componentWidth) {
            this.offsetX = offsetX
            if (offsetX > maxOffsetX) {
                //左边
                this.offsetX = maxOffsetX
                isBoundary_X = true
            } else if (offsetX < -maxOffsetX) {
                //右边
                this.offsetX = -maxOffsetX
                isBoundary_X = true
            }
        }

        if (contentHeight * scale > componentHeight) {
            this.offsetY = offsetY
            if (offsetY > maxOffsetY) {
                this.offsetY = maxOffsetY
                isBoundary_Y = true
            } else if (offsetY < -maxOffsetY) {
                this.offsetY = -maxOffsetY
                isBoundary_Y = true
            }
        }
        updateMatrix()
    }
}
