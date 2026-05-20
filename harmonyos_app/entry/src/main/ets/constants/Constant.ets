/**
 * 对应 Android 源文件: src/config/constant.ts
 *
 * 应用常量定义
 */

export const HEADER_HEIGHT: number = 42
export const LIST_ITEM_HEIGHT: number = 54
export const LIST_SCROLL_POSITION_KEY: string = '__LIST_SCROLL_POSITION_KEY__'

export const LIST_IDS = {
  DEFAULT: 'default',
  LOVE: 'love',
  TEMP: 'temp',
  DOWNLOAD: 'download',
} as const

export enum COMPONENT_IDS {
  home = 'home',
  playDetail = 'playDetail',
  songlistDetail = 'songlistDetail',
  comment = 'comment',
}

export enum NAV_SHEAR_NATIVE_IDS {
  playDetail_pic = 'playDetail_pic',
  playDetail_header = 'playDetail_header',
  playDetail_player = 'playDetail_player',
  songlistDetail_pic = 'songlistDetail_pic',
  songlistDetail_title = 'songlistDetail_title',
}

export const storageDataPrefix = {
  setting: '@setting_v1',
  userList: '@user_list',
  viewPrevState: '@view_prev_state',
  list: '@list__',
  listScrollPosition: '@list_scroll_position',
  listPrevSelectId: '@list_prev_select_id',
  lyric: '@lyric__',
  musicUrl: '@music_url__',
  musicOtherSource: '@music_other_source__',
  playInfo: '@play_info',
  syncAuthKey: '@sync_auth_key',
  syncHost: '@sync_host',
  syncHostHistory: '@sync_host_history',
  openStoragePath: '@open_storage_path',
  selectedManagedFolder: '@selected_managed_folder',
  searchHistoryList: '@search_history_list',
  listUpdateInfo: '@list_update_info',
  ignoreVersion: '@ignore_version',
  leaderboardSetting: '@leaderboard_setting',
  songListSetting: '@songist_setting',
  searchSetting: '@search_setting',
  fontSize: '@font_size',
  theme: '@theme',
  dislikeList: '@dislike_list',
  userApi: '@user_api__',
} as const

export type NavIdType = 'nav_search' | 'nav_songlist' | 'nav_top' | 'nav_love' | 'nav_setting'

export const NAV_MENUS: Array<{ id: NavIdType; icon: string }> = [
  { id: 'nav_search', icon: 'search-2' },
  { id: 'nav_songlist', icon: 'album' },
  { id: 'nav_top', icon: 'leaderboard' },
  { id: 'nav_love', icon: 'love' },
  { id: 'nav_setting', icon: 'setting' },
] as const

export const APP_PROVIDER_NAME: string = 'cn.toside.music.mobile.provider'

export const MUSIC_TOGGLE_MODE = {
  listLoop: 'listLoop',
  random: 'random',
  list: 'list',
  singleLoop: 'singleLoop',
  none: 'none',
} as const

export const MUSIC_TOGGLE_MODE_LIST = [
  MUSIC_TOGGLE_MODE.listLoop,
  MUSIC_TOGGLE_MODE.random,
  MUSIC_TOGGLE_MODE.list,
  MUSIC_TOGGLE_MODE.singleLoop,
  MUSIC_TOGGLE_MODE.none,
] as const

export const LXM_FILE_EXT_RXP: string[] = ['json', 'lxmc', 'bin']
export const USER_API_SOURCE_FILE_EXT_RXP: string[] = ['js']