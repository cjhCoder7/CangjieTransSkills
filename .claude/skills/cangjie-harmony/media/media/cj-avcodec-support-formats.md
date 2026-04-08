# AVCodec支持的格式

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

## 媒体编解码

### 视频解码

当前支持的解码能力如下：

| 视频硬解类型       | 视频软解类型   |
| --------------------- | ---------------- |
| AVC(H.264)、HEVC(H.265)<!--RP14--><!--RP14End--> | MPEG2、MPEG4、H.263、AVC(H.264)<!--RP12--><!--RP12End--> |

### 视频编码

当前支持的编码能力如下：

| 视频编码类型                 |
| ---------------------------- |
| HEVC(H.265)、 AVC(H.264) |

### 音频解码

当前支持的解码能力：

AAC、MPEG(MP3)、Flac、Vorbis、AMR(amrnb、amrwb)、G711mu、APE<!--RP1--><!--RP1End-->。

### 音频编码

当前支持的编码能力：

AAC、Flac、MP3、G711mu<!--RP3--><!--RP3End-->。

## 媒体数据封装与解析

### 媒体数据解析

支持的解封装格式如下：

| 媒体格式  | 封装格式                      | 码流格式                      |
| -------- | :----------------------------| :----------------------------|
| 音视频     | mp4                        |<!--RP4-->视频码流：AVC(H.264)、MPEG4，音频码流：AAC、MPEG(MP3)，字幕流：WEBVTT<!--RP4End-->|
| 音视频     | fmp4                       |<!--RP5-->视频码流：AVC(H.264)，音频码流：AAC、MPEG(MP3)<!--RP5End-->|
| 音视频     | mkv                        |<!--RP6-->视频码流：AVC(H.264)，音频码流：AAC、MPEG(MP3)、OPUS<!--RP6End-->|
| 音视频     | mpeg-ts                    |<!--RP7-->视频码流：AVC(H.264)、MPEG2、MPEG4，音频码流：AAC、MPEG(MP3)<!--RP7End-->|
| 音视频     | flv                        |<!--RP8-->视频码流：AVC(H.264)，音频码流：AAC<!--RP8End-->|
| 音视频     | mpeg-ps                    |视频码流：AVC(H.264)、MPEG2，音频码流：MPEG(MP2、MP3)|
| 音视频     | avi                        |视频码流：H.263、AVC(H.264)、MPEG2、MPEG4，音频码流：AAC、MPEG(MP2、MP3)、PCM|
| 音频       | m4a                        |<!--RP9-->音频码流：AAC<!--RP9End-->|
| 音频       | aac                        |音频码流：AAC|
| 音频       | mp3                        |音频码流：MPEG(MP3)|
| 音频       | ogg                        |音频码流：Vorbis|
| 音频       | flac                       |音频码流：Flac|
| 音频       | wav                        |音频码流：PCM、G711mu|
| 音频       | amr                        |音频码流：AMR(amrnb、amrwb)|
| 音频       | ape                        |音频码流：APE|
| 外挂字幕   | srt                        |字幕流：SRT|
| 外挂字幕   | webvtt                     |字幕流：WEBVTT|

### 媒体数据封装

当前支持的封装能力如下：

| 封装格式 | 视频编解码类型        | 音频编解码类型   | 封面类型       |
| -------- | --------------------- | ---------------- | -------------- |
| mp4      | AVC（H.264）<!--RP11--><!--RP11End-->    | AAC、MPEG（MP3） | jpeg、png、bmp |
| m4a      | -                     | AAC              | jpeg、png、bmp |
| mp3      | -                     | MPEG（MP3）      | -              |
| amr      | -                     | AMR(amrnb、amrwb) | -             |
| wav      | -                     | G711mu(pcm-mulaw) | -             |
| aac      | -                     | AAC               | -             |

> **说明：**
>
> - 封装格式为mp4，音频编解码类型为MPEG（MP3）时采样率需大于等于16000Hz。
> - 封装格式为mp4/m4a，音频编解码类型为AAC时声道数范围为1~7。
