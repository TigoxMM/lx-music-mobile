/**
 * 对应 Android 源文件: src/types/list.d.ts
 *
 * 列表相关类型定义
 */

import { MusicInfo } from './MusicInfo';

export interface UserListInfo {
  id: string
  name: string
  source?: string
  sourceListId?: string
  locationUpdateTime: number | null
}

export interface MyDefaultListInfo {
  id: 'default'
  name: '试听列表'
}

export interface MyLoveListInfo {
  id: 'love'
  name: '我的收藏'
}

export interface MyTempListInfo {
  id: 'temp'
  name: '临时列表'
  meta: {
    id?: string
  }
}

export type MyListInfo = MyDefaultListInfo | MyLoveListInfo | UserListInfo

export interface MyAllList {
  defaultList: MyDefaultListInfo
  loveList: MyLoveListInfo
  userList: UserListInfo[]
  tempList: MyTempListInfo
}

export interface ListPositionInfo {
  [key: string]: number
}

export interface ListUpdateInfoEntry {
  updateTime: number
  isAutoUpdate: boolean
}

export interface ListUpdateInfo {
  [key: string]: ListUpdateInfoEntry
}