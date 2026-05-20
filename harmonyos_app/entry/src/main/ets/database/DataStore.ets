/**
 * 对应 Android 源文件: src/utils/data.ts (部分)
 *
 * 数据访问层 - 封装 Preferences 操作，提供业务级数据读写接口
 * 对应 Android 各 get/save 方法
 */
import {
  saveData, getData, removeData, getAllKeys,
  saveDataMultiple, getDataMultiple, removeDataMultiple
} from './PreferencesStore';
import { storageDataPrefix } from '../constants/Constant';
import { MusicInfo, LyricInfo, MusicInfoOnline } from '../model/MusicInfo';
import { UserListInfo } from '../model/ListInfo';
import { SavedPlayInfo } from '../model/PlayerInfo';

const fontSizeKey: string = storageDataPrefix.fontSize;
const themeKey: string = storageDataPrefix.theme;
const playInfoStorageKey: string = storageDataPrefix.playInfo;
const userListKey: string = storageDataPrefix.userList;
const listPrefix: string = storageDataPrefix.list;
const dislikeListPrefix: string = storageDataPrefix.dislikeList;
const userApiPrefix: string = storageDataPrefix.userApi;

// 歌曲列表
export async function getUserLists(): Promise<UserListInfo[]> {
  const list = await getData<UserListInfo[]>(userListKey) ?? [];
  return list;
}

export async function saveUserList(listInfo: UserListInfo[]): Promise<void> {
  await saveData(userListKey, listInfo);
}

export async function getListMusics(listId: string): Promise<MusicInfo[]> {
  const list = await getData<MusicInfo[]>(listPrefix + listId);
  return list ?? [];
}

export async function saveListMusics(listData: Array<{ id: string; musics: MusicInfo[] }>): Promise<void> {
  if (listData.length > 1) {
    const entries: Array<[string, Object]> = listData.map((list) => [listPrefix + list.id, list.musics]);
    await saveDataMultiple(entries);
  } else {
    const list = listData[0];
    await saveData(listPrefix + list.id, list.musics);
  }
}

export async function removeListMusics(ids: string[]): Promise<void> {
  if (ids.length > 1) {
    await removeDataMultiple(ids.map((id) => listPrefix + id));
  } else {
    await removeData(listPrefix + ids[0]);
  }
}

// 歌词
export async function getLyric(musicInfo: MusicInfo): Promise<LyricInfo> {
  const lrcInfo = await getData<LyricInfo>(`${storageDataPrefix.lyric}${musicInfo.id}`);
  return lrcInfo ?? { lyric: '' };
}

export async function saveLyric(musicInfo: MusicInfo, lyricInfo: LyricInfo): Promise<void> {
  await saveData(`${storageDataPrefix.lyric}${musicInfo.id}`, lyricInfo);
}

// 音乐 URL 缓存
export async function getMusicUrl(musicInfo: MusicInfo, type: string): Promise<string> {
  const url = await getData<string>(`${storageDataPrefix.musicUrl}${musicInfo.id}_${type}`);
  return url ?? '';
}

export async function saveMusicUrl(musicInfo: MusicInfo, type: string, url: string): Promise<void> {
  await saveData(`${storageDataPrefix.musicUrl}${musicInfo.id}_${type}`, url);
}

// 播放信息
export async function savePlayInfo(playInfo: SavedPlayInfo): Promise<void> {
  await saveData(playInfoStorageKey, playInfo);
}

export async function getPlayInfo(): Promise<SavedPlayInfo | null> {
  return getData<SavedPlayInfo | null>(playInfoStorageKey);
}

// 不喜欢列表
export async function getDislikeListRules(): Promise<string> {
  return await getData<string>(dislikeListPrefix) ?? '';
}

export async function saveDislikeListRules(rules: string): Promise<void> {
  await saveData(dislikeListPrefix, rules);
}

// 字体大小
export async function getFontSize(): Promise<number> {
  return await getData<number>(fontSizeKey) ?? 1;
}

export async function saveFontSize(size: number): Promise<void> {
  await saveData(fontSizeKey, size);
}

// 主题
export async function getUserTheme(): Promise<Object[]> {
  return await getData<Object[]>(themeKey) ?? [];
}

export async function saveUserTheme(themes: Object[]): Promise<void> {
  await saveData(themeKey, themes);
}