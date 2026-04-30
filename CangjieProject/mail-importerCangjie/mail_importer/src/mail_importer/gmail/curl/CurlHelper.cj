package mail_importer.gmail.curl

import std.collection.ArrayList

// HTTP 响应封装
public class CurlResponse {
    public var statusCode: Int64
    public var body: String

    public init(statusCode: Int64, body: String) {
        this.statusCode = statusCode
        this.body = body
    }

    public func isSuccessful(): Bool {
        statusCode >= 200 && statusCode < 300
    }
}

// 高层 HTTP 封装：通过 CFFI 调用 curl_helper C 库
public class CurlHelper {
    let accessToken: String

    public init(accessToken: String) {
        this.accessToken = accessToken
    }

    // 执行 GET 请求
    public func httpGet(url: String): CurlResponse {
        var bodyPtr: CPointer<UInt8> = CPointer<UInt8>()
        var bodyLen: Int32 = 0

        let statusCode = unsafe {
            let cUrl = LibC.mallocCString(url)
            let cAuth = LibC.mallocCString(accessToken)
            let code = curl_helper_get(cUrl, cAuth,
                inout bodyPtr, inout bodyLen)
            LibC.free(cUrl)
            LibC.free(cAuth)
            code
        }

        let body = cStringSliceToString(bodyPtr, Int64(bodyLen))
        unsafe { curl_helper_free(CPointer<Unit>(bodyPtr)) }

        CurlResponse(Int64(statusCode), body)
    }

    // 执行 POST JSON 请求
    public func httpPostJson(url: String, jsonBody: String): CurlResponse {
        var bodyPtr: CPointer<UInt8> = CPointer<UInt8>()
        var bodyLen: Int32 = 0

        let statusCode = unsafe {
            let cUrl = LibC.mallocCString(url)
            let cAuth = LibC.mallocCString(accessToken)
            let cBody = LibC.mallocCString(jsonBody)
            let code = curl_helper_post_json(cUrl, cAuth, cBody,
                inout bodyPtr, inout bodyLen)
            LibC.free(cUrl)
            LibC.free(cAuth)
            LibC.free(cBody)
            code
        }

        let body = cStringSliceToString(bodyPtr, Int64(bodyLen))
        unsafe { curl_helper_free(CPointer<Unit>(bodyPtr)) }

        CurlResponse(Int64(statusCode), body)
    }

    // 上传二进制数据
    public func httpUpload(url: String, contentType: String, data: Array<UInt8>): CurlResponse {
        var bodyPtr: CPointer<UInt8> = CPointer<UInt8>()
        var bodyLen: Int32 = 0

        let statusCode = unsafe {
            let cUrl = LibC.mallocCString(url)
            let cAuth = LibC.mallocCString(accessToken)
            let cContentType = LibC.mallocCString(contentType)

            // 将 Array<UInt8> 复制到 C 内存
            let dataPtr = LibC.malloc<UInt8>(count: Int64(data.size))
            var i: Int64 = 0
            while (i < data.size) {
                (dataPtr + i).write(data[i])
                i++
            }

            let code = curl_helper_upload(cUrl, cAuth, cContentType,
                dataPtr, Int32(data.size),
                inout bodyPtr, inout bodyLen)

            LibC.free(cUrl)
            LibC.free(cAuth)
            LibC.free(cContentType)
            LibC.free(CPointer<Unit>(dataPtr))
            code
        }

        let body = cStringSliceToString(bodyPtr, Int64(bodyLen))
        unsafe { curl_helper_free(CPointer<Unit>(bodyPtr)) }

        CurlResponse(Int64(statusCode), body)
    }

    // 将 C 指针 + 长度 转为 String
    func cStringSliceToString(ptr: CPointer<UInt8>, len: Int64): String {
        if (ptr.isNull() || len <= 0) {
            return ""
        }
        let arr = ArrayList<UInt8>()
        var i: Int64 = 0
        while (i < len) {
            arr.add(unsafe { ptr.read(i) })
            i++
        }
        String.fromUtf8(arr.toArray())
    }
}
