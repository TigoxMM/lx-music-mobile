# Android 源码审计清单

> 项目：lx-music-mobile (落雪音乐移动端)
> 原技术栈：React Native 0.73.11 + TypeScript
> 包名：cn.toside.music.mobile
> 审计日期：2026-05-20

---

## 一、所有页面 / 屏幕（含导航关系）

### 1.1 注册的屏幕

| 屏幕常量 | 组件位置 | 说明 |
|----------|----------|------|
| `lxm.HomeScreen` | `src/screens/Home/` | 主页面（含搜索/歌单/排行榜/我的列表/设置子页面） |
| `lxm.PlayDetailScreen` | `src/screens/PlayDetail/` | 播放详情页（横向/竖向两种布局） |
| `lxm.SonglistDetailScreen` | `src/screens/SonglistDetail/` | 歌单详情页 |
| `lxm.CommentScreen` | `src/screens/Comment/` | 评论页（热门评论+最新评论） |
| `lxm.VersionModal` | `src/navigation/components/VersionModal.tsx` | 版本更新弹窗 |
| `lxm.PactModal` | `src/navigation/components/PactModal.tsx` | 用户协议弹窗 |
| `lxm.SyncModeModal` | `src/navigation/components/SyncModeModal.tsx` | 同步模式选择弹窗 |

### 1.2 Home 主页子视图（通过底部导航栏切换）

| 导航ID | 图标 | 对应视图 |
|--------|------|----------|
| `nav_search` | search-2 | 搜索页 (`src/screens/Home/Views/Search/`) |
| `nav_songlist` | album | 歌单页 (`src/screens/Home/Views/SongList/`) |
| `nav_top` | leaderboard | 排行榜页 (`src/screens/Home/Views/Leaderboard/`) |
| `nav_love` | love | 我的列表页 (`src/screens/Home/Views/Mylist/`) |
| `nav_setting` | setting | 设置页 (`src/screens/Home/Views/Setting/`) |

### 1.3 导航关系

```
App 入口
  ├─ HomeScreen (主页)
  │    ├─ 搜索页 → 搜歌曲 / 搜歌单 → SonglistDetailScreen / PlayDetailScreen
  │    ├─ 歌单页 → SonglistDetailScreen → PlayDetailScreen
  │    ├─ 排行榜页 → PlayDetailScreen
  │    ├─ 我的列表 → PlayDetailScreen
  │    └─ 设置页
  ├─ PlayDetailScreen (播放详情)
  │    └─ CommentScreen (评论)
  ├─ SonglistDetailScreen (歌单详情)
  │    └─ PlayDetailScreen
  └─ Modal: VersionModal / PactModal / SyncModeModal
```

### 1.4 布局模式

- **Horizontal（横屏）** 和 **Vertical（竖屏）** 两套布局，根据设备方向自动切换
- 使用 `useDeviceOrientation` Hook 检测屏幕方向

---

## 二、全部 API 端点

### 2.1 音乐源

项目支持 6 个音乐源：

| 源标识 | 名称 | 实现目录 |
|--------|------|----------|
| `wy` | 网易云音乐 | `src/utils/musicSdk/wy/` |
| `kg` | 酷狗音乐 | `src/utils/musicSdk/kg/` |
| `kw` | 酷我音乐 | `src/utils/musicSdk/kw/` |
| `tx` | QQ音乐 | `src/utils/musicSdk/tx/` |
| `mg` | 咪咕音乐 | `src/utils/musicSdk/mg/` |
| `bd` | 百度音乐 | `src/utils/musicSdk/bd/` |

每个源实现的功能模块：`musicSearch`、`songList`、`leaderboard`、`hotSearch`、`comment`、`lyric`、`pic`、`musicInfo`、`tipSearch`

### 2.2 网易云音乐 (wy) API

#### 搜索

| 项目 | 详情 |
|------|------|
| URL | `POST` eapi: `/api/search/song/list/page` |
| Full URL | `https://interface3.music.163.com/eapi/search/song/list/page` |
| Method | POST |
| Headers | Content-Type: application/x-www-form-urlencoded |
| Body | `{ keyword, needCorrect: "1", channel: "typing", offset, scene: "normal", total, limit }` (eapi 加密) |
| Source | `src/utils/musicSdk/wy/musicSearch.js` |

#### 歌词

| 项目 | 详情 |
|------|------|
| URL | `https://interface3.music.163.com/eapi/song/lyric/v1` |
| Method | POST |
| Headers | Content-Type: application/x-www-form-urlencoded, User-Agent, origin: https://music.163.com |
| Body | `{ id: songmid, cp: false, tv: 0, lv: 0, rv: 0, kv: 0, yv: 0, ytv: 0, yrv: 0 }` (eapi 加密) |
| Source | `src/utils/musicSdk/wy/lyric.js` |

#### 排行榜

| 项目 | 详情 |
|------|------|
| Boards URL | `https://music.163.com/weapi/toplist` |
| Boards Method | POST |
| Boards Body | `{}` (weapi 加密) |
| Detail URL | `https://music.163.com/weapi/v3/playlist/detail` |
| Detail Method | POST |
| Detail Body | `{ id, n: 100000, p: 1 }` (weapi 加密) |
| Source | `src/utils/musicSdk/wy/leaderboard.js` |

#### 歌单

| 项目 | 详情 |
|------|------|
| List URL | `https://music.163.com/weapi/playlist/list` |
| List Method | POST |
| List Body | `{ cat, order, limit: 30, offset, total: true }` (weapi 加密) |
| Detail URL | `https://music.163.com/api/linux/forward` |
| Detail Method | POST |
| Detail Body | linuxapi(`{ method: POST, url: https://music.163.com/api/v3/playlist/detail, params: { id, n: 100000, s: 8 } }`) |
| Tags URL | `https://music.163.com/weapi/playlist/catalogue` + `https://music.163.com/weapi/playlist/hottags` |
| Source | `src/utils/musicSdk/wy/songList.js` |

#### 热搜

| 项目 | 详情 |
|------|------|
| URL | eapi: `/api/search/chart/detail` |
| Method | POST |
| Body | `{ id: "HOT_SEARCH_SONG#@#" }` (eapi 加密) |
| Source | `src/utils/musicSdk/wy/hotSearch.js` |

#### 评论

| 项目 | 详情 |
|------|------|
| Comment URL | `https://music.163.com/weapi/comment/resource/comments/get` |
| Method | POST |
| Body | `{ cursor, offset, orderType, pageNo, pageSize, rid, threadId }` (weapi 加密) |
| HotComment URL | `https://music.163.com/weapi/v1/resource/hotcomments/{R_SO_4_songmid}` |
| Source | `src/utils/musicSdk/wy/comment.js` |

#### 音乐详情

| 项目 | 详情 |
|------|------|
| URL | eapi: `/api/v3/song/detail` |
| Method | POST |
| Body | `{ c: [{ id: songId }] }` (eapi 加密) |
| Source | `src/utils/musicSdk/wy/musicDetail.js` |

### 2.3 酷狗音乐 (kg) API

#### 搜索

| 项目 | 详情 |
|------|------|
| URL | `https://songsearch.kugou.com/song_search_v2?keyword={str}&page={page}&pagesize={limit}&...` |
| Method | GET |
| Source | `src/utils/musicSdk/kg/musicSearch.js` |

#### 歌词

| 项目 | 详情 |
|------|------|
| Search URL | `http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword={name}&hash={hash}&timelength={time}` |
| Download URL | `http://lyrics.kugou.com/download?ver=1&client=pc&id={id}&accesskey={key}&fmt={fmt}&charset=utf8` |
| Headers | KG-RC: 1, KG-THash, User-Agent: KuGou2012-9020-ExpandSearchManager |
| Source | `src/utils/musicSdk/kg/lyric.js` |

#### 排行榜

| 项目 | 详情 |
|------|------|
| Boards URL | `http://mobilecdnbj.kugou.com/api/v5/rank/list?version=9108&plat=0&...` |
| Detail URL | `http://mobilecdnbj.kugou.com/api/v3/rank/song?version=9108&ranktype=1&plat=0&pagesize={limit}&page={p}&rankid={id}` |
| Method | GET |
| Source | `src/utils/musicSdk/kg/leaderboard.js` |

#### 歌单

| 项目 | 详情 |
|------|------|
| List URL | `http://www2.kugou.kugou.com/yueku/v9/special/getSpecial?...` |
| Detail URL | `http://www2.kugou.kugou.com/yueku/v9/special/single/{id}-5-9999.html` |
| MusicInfo URL | `http://gateway.kugou.com/v2/album_audio/audio` (POST, 含签名) |
| Recommend URL | `http://everydayrec.service.kugou.com/guess_special_recommend` (POST) |
| Source | `src/utils/musicSdk/kg/songList.js` |

### 2.4 酷我音乐 (kw) API

#### 搜索

| 项目 | 详情 |
|------|------|
| URL | `http://search.kuwo.cn/r.s?client=kt&all={str}&pn={page-1}&rn={limit}&...` |
| Method | GET |
| Source | `src/utils/musicSdk/kw/musicSearch.js` |

#### 歌词

| 项目 | 详情 |
|------|------|
| URL | `http://newlyric.kuwo.cn/newlyric.lrc?{xor_encrypted_params}` |
| Method | GET (binary) |
| Source | `src/utils/musicSdk/kw/lyric.js` |

#### 音乐信息

| 项目 | 详情 |
|------|------|
| URL | `http://www.kuwo.cn/api/www/music/musicInfo?mid={songmid}` |
| Method | GET |
| Source | `src/utils/musicSdk/kw/index.js` |

### 2.5 QQ音乐 (tx) API

搜索/歌词/排行榜/歌单/评论均通过加密请求发送到 QQ音乐 API。
- Crypto: `src/utils/musicSdk/tx/utils/crypto.js`
- 请求模块: `src/utils/musicSdk/tx/index.js`

### 2.6 咪咕音乐 (mg) API

使用 Migu Music API，具体实现在 `src/utils/musicSdk/mg/` 中。

### 2.7 百度音乐 (bd) API

实现在 `src/utils/musicSdk/bd/` 中。

### 2.8 同步服务 API

| 项目 | 详情 |
|------|------|
| 连接地址 | 用户自定义 syncHost |
| 认证方式 | syncAuthKey |
| Source | `src/plugins/sync/client/` |

### 2.9 版本更新 API

检查更新：通过 `src/core/version.ts` → 在线获取最新版本信息

### 2.10 通用 HTTP 请求规范

| 项目 | 详情 |
|------|------|
| 默认 Headers | User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) ... |
| 超时 | 15000ms |
| 缓存策略 | no-store |
| 重试机制 | 自动重试，max 2-6次 |
| 网络错误映射 | `socket hang up` → unachievable, `Aborted` → timeout, `Network request failed` → notConnectNetwork |
| Source | `src/utils/request.js` |

### 2.11 用户自定义 API（UserApi）

允许用户导入自定义 JS 脚本作为音乐源，通过 WebView 执行并调用全局 `lx.apis` 对象提供数据。

---

## 三、数据存储 Schema

### 3.1 存储引擎

使用 `@react-native-async-storage/async-storage` (React Native AsyncStorage)，所有数据以 Key-Value 形式 JSON 序列化存储。大数据 (>500KB) 自动分片存储。

### 3.2 存储 Key 前缀表

| 前缀 | 用途 | 数据类型 |
|------|------|----------|
| `@setting_v1` | 应用设置 | `LX.AppSetting` |
| `@user_list` | 用户自定义列表信息数组 | `LX.List.UserListInfo[]` |
| `@view_prev_state` | 上次浏览状态 | `{ id: NAV_ID_Type }` |
| `@list__{id}` | 列表歌曲数据 | `LX.Music.MusicInfo[]` |
| `@list_scroll_position` | 列表滚动位置 | `Record<string, number>` |
| `@list_prev_select_id` | 上次选择的列表ID | `string` |
| `@list_update_info` | 列表更新信息 | `Record<string, {updateTime, isAutoUpdate}>` |
| `@lyric__{id}` | 歌词缓存 | `LX.Music.LyricInfo` |
| `@lyric__{id}_edited` | 编辑过的歌词 | `LX.Music.LyricInfo` |
| `@music_url__{id}_{quality}` | 音乐URL缓存 | `string` |
| `@music_other_source__{id}` | 其他源音乐信息 | `LX.Music.MusicInfoOnline[]` |
| `@play_info` | 上次播放信息 | `LX.Player.SavedPlayInfo` |
| `@sync_auth_key` | 同步认证密钥 | `Record<string, LX.Sync.KeyInfo>` |
| `@sync_host` | 同步主机地址 | `string` |
| `@sync_host_history` | 同步主机历史 | `string[]` |
| `@open_storage_path` | 上次打开存储路径 | `string` |
| `@selected_managed_folder` | 安全存储选中的文件夹URI | `string` |
| `@search_history_list` | 搜索历史 | `string[]` |
| `@ignore_version` | 忽略的版本号 | `string` |
| `@leaderboard_setting` | 排行榜设置 | `{ source, boardId }` |
| `@songist_setting` | 歌单设置 | `{ source, sortId, tagName, tagId }` |
| `@search_setting` | 搜索设置 | `{ temp_source, source, type }` |
| `@font_size` | 字体大小 | `number` |
| `@theme` | 用户主题 | `LX.Theme[]` |
| `@dislike_list` | 不喜欢列表规则 | `string` (格式化文本) |
| `@user_api__` | 用户API列表 | `LX.UserApi.UserApiInfo[]` |
| `@user_api__{id}` | 用户API脚本 | `string` (JS脚本) |

### 3.3 核心数据结构

#### MusicInfo (歌曲信息)

```typescript
interface MusicInfo {
  id: string                    // 唯一ID (source + songmid + quality)
  name: string                  // 歌曲名
  singer: string                // 歌手名
  source: LX.Source             // 来源: 'kw'|'wy'|'kg'|'tx'|'mg'|'local'
  interval: string | null       // 时长 "03:55"
  meta: {
    songId: string              // 平台歌曲ID
    albumName: string           // 专辑名
    picUrl?: string             // 封面URL
    qualitys: MusicQualityType[] // 可用音质
    _qualitys: Record<Quality, {size, hash?}>
    // 不同源有不同扩展字段
  }
}
```

#### AppSetting (应用设置 - 含 60+ 配置项)

主要分组：
- `common.*` (15项): 主题/语言/API源/分享/UI行为
- `player.*` (20项): 播放策略/音质/缓存/定时/蓝牙/歌词
- `playDetail.*` (4项): 歌词对齐/字体大小/进度
- `desktopLyric.*` (12项): 桌面歌词样式/位置/颜色
- `search.*` (2项): 热搜/搜索历史显示
- `list.*` (8项): 列表显示/添加位置/滚动恢复
- `download.*` (1项): 文件命名
- `sync.*` (1项): 同步开关
- `theme.*` (6项): 主题设置

#### Player State

```typescript
{
  playMusicInfo: { musicInfo, listId, isTempPlay }
  playInfo: { playIndex, playerListId, playerPlayIndex }
  musicInfo: { id, pic, lrc, tlrc, rlrc, lxlrc, rawlrc, name, singer, album }
  isPlay: boolean
  volume: number
  playRate: number
  statusText: string
  playedList: PlayMusicInfo[]
  tempPlayList: PlayMusicInfo[]
  progress: { nowPlayTime, maxPlayTime, progress, nowPlayTimeStr, maxPlayTimeStr }
}
```

#### List State

```typescript
{
  allMusicList: Map<string, MusicInfo[]>    // 所有列表的歌曲缓存
  defaultList: { id: 'default', name: '试听列表' }
  loveList: { id: 'love', name: '我的收藏' }
  tempList: { id: 'temp', name: '临时列表' }
  userList: UserListInfo[]                  // 用户创建的列表
  activeListId: string                      // 当前选中列表
}
```

### 3.4 播放列表

- `defaultList` — 试听列表（内置）
- `loveList` — 我的收藏（内置）
- `tempList` — 临时列表（稍后播放，不持久化）
- `userList` — 用户列表（可自定义创建、导入导出）

---

## 四、所需系统权限

### 4.1 AndroidManifest.xml 声明的权限

| 权限 | 用途 |
|------|------|
| `android.permission.READ_EXTERNAL_STORAGE` | 读取外部存储（本地音乐文件） |
| `android.permission.WRITE_EXTERNAL_STORAGE` | 写入外部存储（导出列表/缓存） |
| `android.permission.INTERNET` | 网络访问（API请求） |
| `android.permission.REQUEST_INSTALL_PACKAGES` | 版本更新安装APK |
| `android.permission.ACCESS_WIFI_STATE` | WiFi状态检测 |
| `android.permission.SYSTEM_ALERT_WINDOW` | 桌面歌词悬浮窗 |
| `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | 忽略电池优化（后台播放） |

### 4.2 HarmonyOS 对应权限

| Android 权限 | HarmonyOS 权限 |
|------|------|
| `READ/WRITE_EXTERNAL_STORAGE` | `ohos.permission.READ_MEDIA` + `ohos.permission.WRITE_MEDIA` |
| `INTERNET` | `ohos.permission.INTERNET` |
| `REQUEST_INSTALL_PACKAGES` | `ohos.permission.INSTALL_BUNDLE` |
| `ACCESS_WIFI_STATE` | `ohos.permission.GET_WIFI_INFO` |
| `SYSTEM_ALERT_WINDOW` | `ohos.permission.SYSTEM_FLOAT_WINDOW` |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | `ohos.permission.KEEP_BACKGROUND_RUNNING` |

---

## 五、使用的第三方 SDK/库

### 5.1 React Native 框架层

| 包名 | 版本 | 用途 | 对应 HarmonyOS 替代 |
|------|------|------|------|
| `react-native` | 0.73.11 | RN框架核心 | 替换为 ArkUI |
| `react-native-navigation` | 7.39.2 | 导航管理 | 替换为 Navigation() 路由 |
| `react-native-track-player` | custom fork | 音频播放 | 替换为 AVPlayer / AudioRenderer |
| `@react-native-async-storage/async-storage` | 2.1.2 | KV存储 | 替换为 Preferences |
| `react-native-fs` | 2.20.0 | 文件系统 | 替换为 fs API |
| `react-native-file-system` | custom fork | SAF 文件访问 | 替换为 FilePicker |
| `react-native-background-timer` | custom fork | 后台定时器 | 替换为 WorkScheduler |
| `react-native-pager-view` | 6.7.1 | 页面滑动 | 替换为 Swiper() |
| `react-native-vector-icons` | 10.2.0 | 图标字体 | 替换为 SymbolGlyph / 自定义 |
| `@react-native-community/slider` | 4.5.7 | 滑块组件 | 替换为 Slider() |
| `@react-native-clipboard/clipboard` | 1.14.3 | 剪贴板 | 替换为 pasteboard |
| `react-native-local-media-metadata` | custom fork | 本地媒体元数据 | 替换为 AudioMetadata |
| `react-native-quick-base64` | 2.2.2 | Base64编解码 | 替换为 util.Base64Helper |
| `react-native-quick-md5` | 3.0.9 | MD5哈希 | 替换为 cryptoFramework |
| `react-native-exception-handler` | 2.10.10 | 异常处理 | 替换为 errorManager |

### 5.2 JS/TS 依赖

| 包名 | 用途 |
|------|------|
| `he` | HTML实体编解码 |
| `iconv-lite` | 字符编码转换 |
| `lrc-file-parser` | 歌词文件解析 |
| `message2call` | 跨上下文消息通信 |
| `pako` | gzip/deflate 压缩解压 |

---

## 六、核心功能模块

### 6.1 播放器

- **音频引擎**: `react-native-track-player` (底层原生音频播放)
- **播放模式**: 列表循环 / 随机 / 顺序 / 单曲循环 / 禁用
- **进度控制**: 进度条拖动/歌词拖动调整进度
- **音量**: 独立音量控制 + 静音
- **播放速率**: 支持变速播放
- **定时停止**: 可设置倒计时自动暂停
- **稍后播放**: tempPlayList 机制
- **已播放列表**: 追踪已播放歌曲

### 6.2 音乐源

- 6个内置音乐源 + 用户自定义脚本源
- 每个源独立实现：搜索/歌单/排行榜/歌词/封面/热搜/评论
- 统一的 API 调用入口 `apis(source).{method}()`

### 6.3 同步服务

- 支持局域网 P2P 同步
- 同步我的列表、不喜欢列表
- 客户端认证 (authKey)
- WebSocket 实时通信

### 6.4 主题

- 亮色/暗色双主题
- 多套内置皮肤 (green, blue_plus, black, happy_new_year 等)
- 动态背景 (专辑封面取色)
- 自定义主题导入

### 6.5 语言

- 简体中文 (zh-cn)
- 繁体中文 (zh-tw)
- 英文 (en-us)

---

## 七、关键事件总线

| 事件 | 触发时机 |
|------|----------|
| `focus` | 应用获得焦点 |
| `mylistUpdated` | 我的列表结构更新 |
| `listToggled` | 切换列表 |
| `musicToggled` | 切换歌曲 |
| `setProgress` | 手动调整进度 |
| `setVolume` | 调整音量 |
| `play/pause/stop/error` | 播放器控制事件 |
| `picUpdated` / `lyricUpdated` | 封面/歌词更新 |
| `myListMusicUpdate` | 列表歌曲变更 |
| `musicInfoUpdate` | 歌曲信息变更 |
| `searchTypeChanged` | 搜索类型切换 |
| `selectSyncMode` | 同步模式选择 |
| `showSonglistTagList` | 歌单标签切换 |

---

## 八、需特殊处理的模块

### 8.1 加密算法（各音乐源）

| 音乐源 | 加密方式 | 文件 |
|--------|----------|------|
| 网易云 | weapi (AES CBC) + eapi + linuxapi | `wy/utils/crypto.js` |
| QQ音乐 | 自定义 crypto | `tx/utils/crypto.js` |
| 酷狗 | infSign + signatureParams | `kg/vendors/infSign.min.js`, `kg/util.js` |
| 酷我 | XOR 加密参数 | `kw/lyric.js` (buildParams) |
| 咪咕 | utils/mrc.js | `mg/utils/mrc.js` |

### 8.2 桌面歌词

- Android 通过 SYSTEM_ALERT_WINDOW 悬浮窗实现
- HarmonyOS 需使用 `ohos.permission.SYSTEM_FLOAT_WINDOW` + WindowComponent

### 8.3 通知栏播放控制

- Android 使用 MediaSession + Notification
- HarmonyOS 需使用 AVSession + MediaControl

### 8.4 歌词解析

- LRC 文件格式解析
- 逐字歌词 (lxlyric) 支持
- 简繁转换 (s2t)
- 歌词偏移调整

---

## 九、审计总结

| 维度 | 数量 |
|------|------|
| 注册屏幕/Modal | 7 |
| Home 子视图 | 5 |
| 音乐源 | 6 |
| API 模块（每源） | 约 8-10 |
| 存储 Key 前缀 | 22 |
| 系统权限 | 7 |
| 核心第三方库 | 15 |
| 应用设置项 | 60+ |
| 事件 | 25+ |
| 语言 | 3 |

---

*审计完成，准备进入 Step 2 · 鸿蒙工程初始化*