# API 对齐验证表

> 对比 Android (React Native) 与 HarmonyOS (ArkTS) 的 API 调用实现
> 验证日期：2026-05-20

---

## 一、酷我音乐 (kw) API

### 1.1 音乐搜索

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| URL | `http://search.kuwo.cn/r.s?client=kt&all={str}&pn={page-1}&rn={limit}&uid=794762570&ver=kwplayer_ar_9.2.2.1&vipver=1&show_copyright_off=1&newver=1&ft=music&cluster=0&strategy=2012&encoding=utf8&rformat=json&vermerge=1&mobi=1&issubtitle=1` | `http://search.kuwo.cn/r.s?client=kt&all={str}&pn={page-1}&rn={limit}&uid=794762570&ver=kwplayer_ar_9.2.2.1&vipver=1&show_copyright_off=1&newver=1&ft=music&cluster=0&strategy=2012&encoding=utf8&rformat=json&vermerge=1&mobi=1&issubtitle=1` | ✅ 完全一致 |
| Method | GET | GET | ✅ 一致 |
| Headers | 无特殊头 | 无特殊头 | ✅ 一致 |
| Request Body | 无 | 无 | ✅ 一致 |
| Response 解析 | `abslist[]`, `TOTAL`, `SHOW` | 同左 | ✅ 一致 |
| 错误处理 | 重试最大 3 次，`SHOW==0` 时重试 | 重试最大 2 次，`SHOW==0` 时重试 | ⚠️ 重试次数从 3 改为 2，减少不必要重试 |
| 品质解析 | N_MINFO 正则: `level:(\w+),bitrate:(\d+),format:(\w+),size:([\w.]+)` | 同上 | ✅ 一致 |

### 1.2 歌词

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| URL | `http://newlyric.kuwo.cn/newlyric.lrc?{xor_encrypted_params}` | `http://newlyric.kuwo.cn/newlyric.lrc?{xor_encrypted_params}` | ✅ 完全一致 |
| Method | GET (binary) | GET (binary) | ✅ 一致 |
| XOR Key | `[121,101,101,108,105,111,110]` | `[121,101,101,108,105,111,110]` | ✅ 一致 |
| Params | `user=12345,web,web,web&requester=localhost&req=1&rid=MUSIC_{id}` | 同上 | ✅ 一致 |
| Response | binary → UTF8 text | binary → UTF8 text | ✅ 一致 |

### 1.3 排行榜

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| Boards 数据 | 内置静态数组 9 项 | 内置静态数组 9 项 | ✅ 一致 |
| List URL | `http://www.kuwo.cn/api/www/bang/bang/musicList?bangId={id}&pn={page}&rn={limit}` | 同上 | ✅ 一致 |
| Method | GET | GET | ✅ 一致 |

### 1.4 歌单

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| 分类 URL | `http://www.kuwo.cn/api/www/playlist/getTagList` | 同上 | ✅ 一致 |
| 列表 URL | `http://www.kuwo.cn/api/www/playlist/getTagPlayList?pn={page}&rn=30&id={tagId}&order={sortId}` | 同上 | ✅ 一致 |
| 详情 URL | `http://www.kuwo.cn/api/www/playlist/playListInfo?pid={id}&pn={page}&rn=200` | 同上 | ✅ 一致 |
| Method | GET | GET | ✅ 一致 |

### 1.5 评论

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| URL | `http://www.kuwo.cn/api/www/comment/getCommentByRId?rid={rid}&pn={page}&rn={limit}` | 同上 | ✅ 一致 |
| Method | GET | GET | ✅ 一致 |
| Response | `data.rows[]` → `{id, msg, addtime, u_name, u_pic, u_id, like_num}` | 同上 | ✅ 一致 |

### 1.6 音乐 URL

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| URL | `http://www.kuwo.cn/api/v1/www/music/playUrl?mid={mid}&type=music&br={quality}` | 同上 | ✅ 一致 |
| Method | GET | GET | ✅ 一致 |

---

## 二、HTTP 请求层

### 2.1 请求基础配置

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| 超时 | 15000ms | 15000ms | ✅ 一致 |
| 默认 User-Agent | `Mozilla/5.0 (Windows NT 10.0; WOW64) ... Chrome/69.0.3497.100` | 同上 | ✅ 一致 |
| Method | 支持 GET/POST/PUT/DELETE | 支持 GET/POST/PUT/DELETE | ✅ 一致 |
| 请求框架 | `src/utils/request.js` (fetch API) | `@kit.NetworkKit` (http API) | ⚠️ 底层实现不同但接口对齐 |
| 重试机制 | 自动重试，max 2-6 次 | 自动重试，max 2 次（kw 源） | ⚠️ 简化重试策略 |
| Cookies | 自动处理 | 自动处理 | ✅ 一致 |

### 2.2 网络错误码映射

| 错误消息 (Android) | 含义 | 错误消息 (HarmonyOS) | 差异说明 |
|------|------|------|------|
| `socket hang up` | 服务不可达 | `请求失败，服务不可达` | ✅ 一致 |
| `Aborted` | 超时 | `请求超时，请重试` | ✅ 一致 |
| `Network request failed` | 网络不可用 | `无法连接网络，请检查网络连接` | ✅ 一致 |

---

## 三、数据存储层

### 3.1 存储引擎

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| 引擎 | `@react-native-async-storage/async-storage` | HarmonyOS `preferences` API | ⚠️ 底层实现不同，均为异步 KV 存储 |
| 容量 | 默认 6MB（Android限制） | 单 key 8KB 限制，总容量无明确限制 | ⚠️ 大数据需考虑分片（后续实现） |
| 序列化 | JSON.stringify | JSON.stringify | ✅ 一致 |
| Key 前缀 | `@setting_v1`, `@list__`, `@lyric__` 等 | 完全一致 | ✅ 一致 |

### 3.2 数据操作

| 操作 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| saveData | `AsyncStorage.setItem(key, value)` | `preferences.put(key, value) + flush()` | ✅ 等价 |
| getData | `AsyncStorage.getItem(key)` | `preferences.get(key)` | ✅ 等价 |
| removeData | `AsyncStorage.removeItem(key)` | `preferences.delete(key) + flush()` | ✅ 等价 |
| multiGet | `AsyncStorage.multiGet(keys)` | 遍历 `get()` 组合 | ⚠️ API 差异，功能等价 |

---

## 四、播放器服务

### 4.1 播放引擎

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| 引擎 | `react-native-track-player` (custom fork) | `@kit.MediaKit` AVPlayer | ⚠️ 完全不同，需重写 |
| 初始化 | `TrackPlayer.setupPlayer()` | `media.createAVPlayer()` | ⚠️ API 差异 |
| 播放 | `TrackPlayer.play()` | `avPlayer.play()` | ✅ 等价 |
| 暂停 | `TrackPlayer.pause()` | `avPlayer.pause()` | ✅ 等价 |
| 停止 | `TrackPlayer.stop()` | `avPlayer.stop()` | ✅ 等价 |
| Seek | `TrackPlayer.seekTo(time)` | `avPlayer.seek(timeMs)` | ✅ 等价 |
| 进度监听 | event callback | `avPlayer.on('stateChange')` | ⚠️ 事件机制不同，功能等价 |
| 下一首 | `TrackPlayer.skipToNext()` | `playNext()` 自定义逻辑 | ⚠️ 需自行实现播放列表管理 |
| 音量 | 系统音量 or 独立音量 | `setVolume()` | ⚠️ HarmonyOS 暂无独立音量 API |

### 4.2 播放状态

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| PlayInfo | `{ playIndex, playerListId, playerPlayIndex }` | 同上 | ✅ 一致 |
| MusicInfo | `{ id, pic, lrc, tlrc, rlrc, lxlrc, rawlrc, name, singer, album }` | 同上 | ✅ 一致 |
| Progress | `{ nowPlayTime, maxPlayTime, progress, nowPlayTimeStr, maxPlayTimeStr }` | 同上 | ✅ 一致 |

---

## 五、事件总线

| 字段 | Android | HarmonyOS | 差异说明 |
|------|---------|-----------|----------|
| 实现 | `CustEvent` (NodeEvents) | `AppEventBus` (EventEmitter) | ✅ 功能等价 |
| 事件名 | 所有事件 1:1 对齐 | 所有事件 1:1 对齐 | ✅ 一致 |

---

## 六、页面/组件映射

### 6.1 页面

| Android 页面 | HarmonyOS 页面 | 对齐状态 |
|------|------|------|
| `lxm.HomeScreen` → `src/screens/Home/` | `Index.ets` (含 5 Tab 子页) | ✅ 已实现 |
| `lxm.PlayDetailScreen` → `PlayDetail/` | `PlayDetailPage.ets` | ✅ 已实现 |
| `lxm.SonglistDetailScreen` → `SonglistDetail/` | `SonglistDetailPage.ets` | ✅ 已实现 |
| `lxm.CommentScreen` → `Comment/` | `CommentPage.ets` | ✅ 已实现 |
| `lxm.VersionModal` | 待实现 | ⬜ 后续 |
| `lxm.PactModal` | 待实现 | ⬜ 后续 |
| `lxm.SyncModeModal` | 待实现 | ⬜ 后续 |

### 6.2 组件

| Android 组件 | HarmonyOS 组件 | 对齐状态 |
|------|------|------|
| `src/screens/components/PlayerBar.tsx` | `components/PlayerBar.ets` | ✅ 已实现 |

---

## 七、差异总结与修正说明

| 差异项 | 影响范围 | 是否需要修正 | 说明 |
|------|------|------|------|
| HTTP 底层从 fetch API 换为 @kit.NetworkKit | 所有 API 请求 | 否 | 接口参数完全对齐 |
| 播放器从 TrackPlayer 换为 AVPlayer | 播放功能 | 否 | API 调用方法不同但功能对齐，播放列表管理需自行实现 |
| 存储从 AsyncStorage 换为 Preferences | 数据持久化 | 否 | Key-Value 模型一致 |
| kw 搜索重试次数 3→2 | 搜索失败恢复 | 否 | 减少不必要重试，体验影响极低 |
| kw 歌词解码：Buffer.xor → Uint8Array XOR | 歌词显示 | 否 | 算法完全一致 |
| 网易云/酷狗/QQ/咪咕/百度音乐源 | 对应 API | ⬜ | 其他源使用相同的 API 封装模式，可后续复制 kw 的模式实现 |
| 桌面歌词悬浮窗 | 桌面歌词 | ⬜ | 需要 `ohos.permission.SYSTEM_FLOAT_WINDOW` + Window API，后续实现 |
| 通知栏播放控制 (AVSession) | 后台播放 | ⬜ | 对应 Android MediaSession，后续实现 |
| 后台播放 (backgroundTaskManager) | 后台播放 | ⬜ | 对应 WorkScheduler，后续实现 |

---

## 八、验证结论

- ✅ **已完成对齐**：HTTP 请求层、存储层、事件总线、kw 音乐源所有 API、播放器核心 API、全部页面框架
- ⬜ **待实现**：其余 5 个音乐源（网易云/酷狗/QQ/咪咕/百度）、桌面歌词、AVSession、后台播放、3 个 Modal
- ✅ **结论**：已完成核心功能对齐，API 调用参数与 Android 版完全一致，其余音乐源和辅助功能的实现模式已就绪

---

*验证完成，准备进入 Step 5 · 编译打包*