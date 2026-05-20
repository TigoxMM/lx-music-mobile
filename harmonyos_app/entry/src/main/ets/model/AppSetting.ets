/**
 * 对应 Android 源文件: src/types/app_setting.d.ts
 *
 * 应用设置类型定义
 */

import { OnlineSource, Quality } from './MusicInfo';
import { TogglePlayMethod } from './PlayerInfo';

export type AddMusicLocationType = 'top' | 'bottom'

export interface AppSetting {
  version: string
  'common.isAutoTheme': boolean
  'common.langId': string | null
  'common.apiSource': string
  'common.sourceNameType': 'alias' | 'real'
  'common.shareType': 'system' | 'clipboard'
  'common.isAgreePact': boolean
  'common.autoHidePlayBar': boolean
  'common.drawerLayoutPosition': 'left' | 'right'
  'common.homePageScroll': boolean
  'common.allowProgressBarSeek': boolean
  'common.showBackBtn': boolean
  'common.showExitBtn': boolean
  'common.useSystemFileSelector': boolean
  'common.alwaysKeepStatusbarHeight': boolean

  'theme.id': string
  'theme.lightId': string
  'theme.darkId': string
  'theme.hideBgDark': boolean
  'theme.dynamicBg': boolean
  'theme.fontShadow': boolean

  'player.startupAutoPlay': boolean
  'player.startupPushPlayDetailScreen': boolean
  'player.togglePlayMethod': TogglePlayMethod
  'player.playQuality': Quality
  'player.isSavePlayTime': boolean
  'player.volume': number
  'player.playbackRate': number
  'player.cacheSize': string
  'player.timeoutExit': string
  'player.timeoutExitPlayed': boolean
  'player.isAutoCleanPlayedList': boolean
  'player.isHandleAudioFocus': boolean
  'player.isEnableAudioOffload': boolean
  'player.isShowLyricTranslation': boolean
  'player.isShowLyricRoma': boolean
  'player.isShowNotificationImage': boolean
  'player.isS2t': boolean
  'player.isShowBluetoothLyric': boolean
  'player.isShowBluetoothFullLyric': boolean

  'playDetail.style.align': 'center' | 'left' | 'right'
  'playDetail.vertical.style.lrcFontSize': number
  'playDetail.horizontal.style.lrcFontSize': number
  'playDetail.isShowLyricProgressSetting': boolean

  'desktopLyric.enable': boolean
  'desktopLyric.isLock': boolean
  'desktopLyric.width': number
  'desktopLyric.maxLineNum': number
  'desktopLyric.isSingleLine': boolean
  'desktopLyric.showToggleAnima': boolean
  'desktopLyric.position.x': number
  'desktopLyric.position.y': number
  'desktopLyric.textPosition.x': 'left' | 'center' | 'right'
  'desktopLyric.textPosition.y': 'top' | 'center' | 'bottom'
  'desktopLyric.style.fontSize': number
  'desktopLyric.style.opacity': number
  'desktopLyric.style.lyricUnplayColor': string
  'desktopLyric.style.lyricPlayedColor': string
  'desktopLyric.style.lyricShadowColor': string

  'search.isShowHotSearch': boolean
  'search.isShowHistorySearch': boolean

  'list.isClickPlayList': boolean
  'list.isShowSource': boolean
  'list.isShowAlbumName': boolean
  'list.isShowInterval': boolean
  'list.isSaveScrollLocation': boolean
  'list.addMusicLocationType': AddMusicLocationType

  'download.fileName': '歌名 - 歌手' | '歌手 - 歌名' | '歌名'

  'sync.enable': boolean
}