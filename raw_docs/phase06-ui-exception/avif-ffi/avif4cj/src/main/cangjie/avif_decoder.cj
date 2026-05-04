/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package avif4cj

internal import ohos.base.nativeLog
import std.io.ByteBuffer
import ohos.image.PixelMap
import ohos.base.AppLog
import ohos.image.ImageInfo
import ohos.image.PixelMapFormat
import ohos.hilog.Hilog

@FastNative
foreign func versionString(): CString

@FastNative
foreign func resultToString(result: Int32): CString

@FastNative
foreign func isAvifImage(result: CPointer<UInt8>, length: Int32): Int32

@FastNative
foreign func getInfo(result: CPointer<UInt8>, length: Int32): CPointer<Info>

@FastNative
foreign func encodedFree(encoded: CPointer<Info>): Unit

@FastNative
foreign func encoded2Free(encoded: CPointer<DecoderInfo>): Unit

@FastNative
foreign func encoded3Free(encoded: CPointer<Float64>): Unit

@FastNative
foreign func createDecoder(result: CPointer<UInt8>, length: Int32, threads: Int32): CPointer<DecoderInfo>

@FastNative
foreign func destroyDecoder(decoder: Int64): Unit

@FastNative
foreign func nextFrameIndex(decoder: Int64): Int32

@FastNative
foreign func nextFrame(decoder: Int64, pixels: CPointer<UInt8>, picwidth: Int32, picheight: Int32, stride: Int32,
    formatvalue: Int32): Int32

@FastNative
foreign func nthFrame(decoder: Int64, index: Int32, pixels: CPointer<UInt8>, picwidth: Int32, picheight: Int32,
    stride: Int32, formatvalue: Int32): Int32

@FastNative
foreign func decode(result: CPointer<UInt8>, length: Int32, pixels: CPointer<UInt8>, picwidth: Int32, picheight: Int32,
    stride: Int32, formatvalue: Int32, threads: Int32): Bool

public class AvifDecoder {
    private var decoder: Int64 = 0

    private var width: Int64 = 0
    private var height: Int64 = 0
    private var depth: Int64 = 0
    private var alphaPresent: Bool = false
    private var frameCount: Int64 = 0
    private var repetitionCount: Int64 = 0
    private var frameDurations: ?Array<Float64> = None

    private var handle: ?CPointerHandle<UInt8> = None

    private func createDecoderffi(encoded: Array<UInt8>, threads: Int32): DecoderInfo {
        unsafe {
            handle = acquireArrayRawData(encoded)
            if(let Some(i) <- handle){
                var result: CPointer<DecoderInfo> = createDecoder(i.pointer, Int32(encoded.size), threads)
                if (result.isNull()) {
                    releaseArrayRawData<UInt8>(i)
                    return DecoderInfo(0, CPointer<Info>())
                }
                let res: DecoderInfo = result.read()
                encoded2Free(result)
                return res
            }else{
                return DecoderInfo(0, CPointer<Info>())
            }
        }
    }

    private func destroyDecoderffi(address: Int64): Unit {
        unsafe {
            if(let Some(i) <- handle){
                releaseArrayRawData<UInt8>(i)
            }
            destroyDecoder(address)
        }
    }

    private init(encoded: Array<UInt8>, threads: Int32) {
        let decoderInfo: DecoderInfo = createDecoderffi(encoded, threads)
        decoder = decoderInfo.address
        let cpointInfo: CPointer<Info> = decoderInfo.info
        unsafe {
            if (decoder != 0) {
                let info: Info = cpointInfo.read()
                width = Int64(info.width)
                height = Int64(info.height)
                depth = Int64(info.depth)
                alphaPresent = info.alphaPresent
                frameCount = Int64(info.frameCount)
                repetitionCount = Int64(info.repetitionCount)
                let durationsPoint: CPointer<Float64> = info.frameDurations
                frameDurations = Array<Float64>(frameCount, repeat: 0.0)
                if (let Some(j) <- frameDurations) {
                    for (i in 0..frameCount) {
                        let duration: Float64 = durationsPoint.read(Int64(i)) //对象直接read() 数组read(0) read(1) read(2) read(3) ...
                        j[i] = duration
                    }
                }
                encodedFree(cpointInfo)
                encoded3Free(durationsPoint)
            }else{
                encodedFree(cpointInfo)
            }
        }
    }

    public static func create(encoded: Array<UInt8>): ?AvifDecoder {
        return create(encoded, 1)
    }

    public static func create(encoded: Array<UInt8>, threads: Int32): ?AvifDecoder {
        let decoder: AvifDecoder = AvifDecoder(encoded, threads)
        if (decoder.decoder == 0) {
            return None
        }
        return decoder
    }

    /** Get the width of the image. */
    public func getWidth(): Int64 {
        return width
    }

    /** Get the height of the image. */
    public func getHeight(): Int64 {
        return height
    }

    /** Get the depth (bit depth) of the image. */
    public func getDepth(): Int64 {
        return depth
    }

    /** Returns true if the image contains a transparency/alpha channel, false otherwise. */
    public func getAlphaPresent(): Bool {
        return alphaPresent
    }

    /** Get the number of frames in the image. */
    public func getFrameCount(): Int64 {
        return frameCount
    }

    /**
     * Get the number of repetitions for an animated image (see repetitionCount in avif.h for
     * details).
     */
    public func getRepetitionCount(): Int64 {
        return repetitionCount
    }

    /** Get the duration for each frame in the image. */
    public func getFrameDurations(): ?Array<Float64> {
        return frameDurations
    }

    public func isAvifImageffi(encoded: Array<UInt8>): Int32 {
        unsafe {
            let handle: CPointerHandle<UInt8> = acquireArrayRawData(encoded)
            let res: Int32 = isAvifImage(handle.pointer, Int32(encoded.size))
            return res
        }
    }

    public func getInfoffi(encoded: Array<UInt8>): Cjinfo {
        unsafe {
            let handle: CPointerHandle<UInt8> = acquireArrayRawData(encoded)
            var result: CPointer<Info> = getInfo(handle.pointer, Int32(encoded.size))
            var res: Info = result.read()
            let cjinfo:Cjinfo = Cjinfo(0,0,0,false,0,0,Array<Float64>())
            cjinfo.width = res.width
            cjinfo.height = res.height
            cjinfo.depth = res.depth
            cjinfo.alphaPresent = res.alphaPresent
            cjinfo.frameCount = res.frameCount
            cjinfo.repetitionCount = res.repetitionCount
            let durationsPoint: CPointer<Float64> = res.frameDurations
            var array:Array<Float64> = Array<Float64>(Int64(res.frameCount),repeat: 0.0)
            for(i in 0..Int64(res.frameCount)){
                let duration:Float64 = durationsPoint.read(Int64(i))  //对象直接read() 数组read(0) read(1) read(2) read(3) ...
                array[i] = duration
            }
            cjinfo.frameDurations = array
            encoded3Free(durationsPoint)
            encodedFree(result)
            return cjinfo
        }
    }

    public func nextFrameIndexffi(): Int32 {
        unsafe {
            return nextFrameIndex(decoder);
        }
    }

    public func nextFrameffi(color: Array<UInt8>, imageWidth: Int32, imageHeight: Int32): Int32 {
        if(color.size == 0){
            Hilog.error(0,"aviflog","the size of color array must > 0")
            return -1
        }
        unsafe {
            let handle: CPointerHandle<UInt8> = acquireArrayRawData(color)
            let format: Int32 = 2
            var perPixelByte:Int32 = 4
            let res = nextFrame(decoder, handle.pointer, imageWidth, imageHeight, imageWidth * perPixelByte, format)
            releaseArrayRawData<UInt8>(handle)
            return res
        }
    }

    public func nthFrameffi(index: Int32, color: Array<UInt8>, imageWidth: Int32, imageHeight: Int32): Int32 {
        if(color.size == 0){
            Hilog.error(0,"aviflog","the size of color array must > 0")
            return -1
        }
        unsafe {
            let handle: CPointerHandle<UInt8> = acquireArrayRawData(color)
            let format: Int32 = 2
            var perPixelByte:Int32 = 4
            let res =  nthFrame(decoder, index, handle.pointer, imageWidth, imageHeight, imageWidth * perPixelByte, format)
            releaseArrayRawData<UInt8>(handle)
            return res
        }
    }

    public func decodeffi(encoded: Array<UInt8>, color: Array<UInt8>, imageWidth: Int32, imageHeight: Int32): Bool {
        if(color.size == 0){
            Hilog.error(0,"aviflog","the size of color array must > 0")
            return false
        }
        unsafe {
            let handlePic: CPointerHandle<UInt8> = acquireArrayRawData(encoded)
            let handleColor: CPointerHandle<UInt8> = acquireArrayRawData(color)
            let format: Int32 = 2
            var perPixelByte:Int32 = 4
            let res =  decode(handlePic.pointer, Int32(encoded.size), handleColor.pointer, imageWidth, imageHeight,imageWidth * perPixelByte, format, 0)
            releaseArrayRawData<UInt8>(handleColor)
            return res
        }
    }

    public func release(): Unit {
        if (decoder != 0) {
            destroyDecoderffi(decoder)
        }
        decoder = 0
    }

    func versionStringffi(): String {
        unsafe {
            let cstr: CString = versionString()
            return cstr.toString()
        }
    }

    func resultToStringffi(result: Int32): String {
        unsafe {
            let cstr: CString = resultToString(result)
            return cstr.toString()
        }
    }
}
