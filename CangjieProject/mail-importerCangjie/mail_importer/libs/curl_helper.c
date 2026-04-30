// curl_helper.c - 简化 libcurl 调用的 C 封装
// 编译: clang -shared -fPIC -lcurl curl_helper.c -o libcurl_helper.dylib

#include <curl/curl.h>
#include <stdlib.h>
#include <string.h>

// 响应缓冲区
typedef struct {
    char* data;
    size_t size;
    size_t capacity;
} ResponseBuffer;

static void buf_init(ResponseBuffer* buf) {
    buf->data = (char*)malloc(4096);
    buf->data[0] = '\0';
    buf->size = 0;
    buf->capacity = 4096;
}

static void buf_append(ResponseBuffer* buf, const char* ptr, size_t len) {
    while (buf->size + len + 1 > buf->capacity) {
        buf->capacity *= 2;
        buf->data = (char*)realloc(buf->data, buf->capacity);
    }
    memcpy(buf->data + buf->size, ptr, len);
    buf->size += len;
    buf->data[buf->size] = '\0';
}

static void buf_free(ResponseBuffer* buf) {
    free(buf->data);
    buf->data = NULL;
    buf->size = 0;
    buf->capacity = 0;
}

static size_t write_callback(void* ptr, size_t size, size_t nmemb, void* userdata) {
    ResponseBuffer* buf = (ResponseBuffer*)userdata;
    size_t total = size * nmemb;
    buf_append(buf, (const char*)ptr, total);
    return total;
}

// 执行 HTTP GET 请求
// 返回: HTTP 状态码，response_body 由调用者释放
int curl_helper_get(const char* url, const char* auth_header,
                    char** response_body, int* response_body_len) {
    CURL* curl = curl_easy_init();
    if (!curl) return -1;

    ResponseBuffer buf;
    buf_init(&buf);

    struct curl_slist* headers = NULL;
    if (auth_header && auth_header[0]) {
        char header_buf[512];
        snprintf(header_buf, sizeof(header_buf), "Authorization: Bearer %s", auth_header);
        headers = curl_slist_append(headers, header_buf);
    }
    headers = curl_slist_append(headers, "Accept: application/json");

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buf);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);

    CURLcode res = curl_easy_perform(curl);

    long http_code = 0;
    if (res == CURLE_OK) {
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    }

    // 复制响应数据给调用者
    *response_body = (char*)malloc(buf.size + 1);
    memcpy(*response_body, buf.data, buf.size + 1);
    *response_body_len = (int)buf.size;

    buf_free(&buf);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);

    return (int)http_code;
}

// 执行 HTTP POST 请求 (JSON body)
int curl_helper_post_json(const char* url, const char* auth_header,
                          const char* json_body,
                          char** response_body, int* response_body_len) {
    CURL* curl = curl_easy_init();
    if (!curl) return -1;

    ResponseBuffer buf;
    buf_init(&buf);

    struct curl_slist* headers = NULL;
    if (auth_header && auth_header[0]) {
        char header_buf[512];
        snprintf(header_buf, sizeof(header_buf), "Authorization: Bearer %s", auth_header);
        headers = curl_slist_append(headers, header_buf);
    }
    headers = curl_slist_append(headers, "Content-Type: application/json");
    headers = curl_slist_append(headers, "Accept: application/json");

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_body);
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buf);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);

    CURLcode res = curl_easy_perform(curl);

    long http_code = 0;
    if (res == CURLE_OK) {
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    }

    *response_body = (char*)malloc(buf.size + 1);
    memcpy(*response_body, buf.data, buf.size + 1);
    *response_body_len = (int)buf.size;

    buf_free(&buf);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);

    return (int)http_code;
}

// 执行 media upload (POST with binary body)
int curl_helper_upload(const char* url, const char* auth_header,
                       const char* content_type,
                       const unsigned char* data, int data_len,
                       char** response_body, int* response_body_len) {
    CURL* curl = curl_easy_init();
    if (!curl) return -1;

    ResponseBuffer buf;
    buf_init(&buf);

    struct curl_slist* headers = NULL;
    if (auth_header && auth_header[0]) {
        char header_buf[512];
        snprintf(header_buf, sizeof(header_buf), "Authorization: Bearer %s", auth_header);
        headers = curl_slist_append(headers, header_buf);
    }

    char ct_buf[256];
    snprintf(ct_buf, sizeof(ct_buf), "Content-Type: %s", content_type);
    headers = curl_slist_append(headers, ct_buf);
    headers = curl_slist_append(headers, "Accept: application/json");

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)data_len);
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buf);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 60L);

    CURLcode res = curl_easy_perform(curl);

    long http_code = 0;
    if (res == CURLE_OK) {
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    }

    *response_body = (char*)malloc(buf.size + 1);
    memcpy(*response_body, buf.data, buf.size + 1);
    *response_body_len = (int)buf.size;

    buf_free(&buf);
    curl_slist_append(headers, "");
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);

    return (int)http_code;
}

// 释放 curl_helper 返回的字符串
void curl_helper_free(void* ptr) {
    if (ptr) free(ptr);
}

// 返回 stdin 指针（供仓颉 CFFI 调用）
void* cjangjie_get_stdin(void) {
    return (void*)stdin;
}
