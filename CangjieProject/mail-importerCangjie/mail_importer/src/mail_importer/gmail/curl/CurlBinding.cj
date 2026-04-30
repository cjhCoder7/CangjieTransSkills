package mail_importer.gmail.curl

// CFFI 声明：libcurl 辅助库函数
// 对应 curl_helper.c 中的 C 函数
foreign {
    // GET 请求
    func curl_helper_get(url: CString, auth_header: CString,
        response_body: CPointer<CPointer<UInt8>>, response_body_len: CPointer<Int32>): Int32

    // POST JSON 请求
    func curl_helper_post_json(url: CString, auth_header: CString,
        json_body: CString,
        response_body: CPointer<CPointer<UInt8>>, response_body_len: CPointer<Int32>): Int32

    // 上传二进制数据
    func curl_helper_upload(url: CString, auth_header: CString,
        content_type: CString,
        data: CPointer<UInt8>, data_len: Int32,
        response_body: CPointer<CPointer<UInt8>>, response_body_len: CPointer<Int32>): Int32

    // 释放 curl_helper 返回的内存
    func curl_helper_free(ptr: CPointer<Unit>): Unit
}
