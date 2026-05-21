/**
 * 对应 Android 源文件: src/event/appEvent.ts
 *
 * 全局事件总线，用于组件间解耦通信
 * 对齐 Android 版所有事件类型
 */
import { MusicInfo } from '../model/MusicInfo';
import { PlayMusicInfo, PlayerProgress } from '../model/PlayerInfo';
import { UserListInfo } from '../model/ListInfo';

export type Listener = (...args: Object[]) => void;

class EventEmitter {
  private listeners: Map<string, Listener[]> = new Map();

  on(event: string, listener: Listener): void {
    let list = this.listeners.get(event);
    if (!list) {
      list = [];
      this.listeners.set(event, list);
    }
    list.push(listener);
  }

  off(event: string, listener: Listener): void {
    const list = this.listeners.get(event);
    if (!list) {
      return;
    }
    const index = list.indexOf(listener);
    if (index >= 0) {
      list.splice(index, 1);
    }
  }

  emit(event: string, ...args: Object[]): void {
    const list = this.listeners.get(event);
    if (!list) {
      return;
    }
    for (const listener of list) {
      listener(...args);
    }
  }

  removeAll(): void {
    this.listeners.clear();
  }
}

export class AppEventBus extends EventEmitter {
  static readonly EVENT_FOCUS: string = 'focus';

  static readonly EVENT_MYLIST_UPDATED: string = 'mylistUpdated';
  static readonly EVENT_LIST_TOGGLED: string = 'listToggled';
  static readonly EVENT_MUSIC_TOGGLED: string = 'musicToggled';

  static readonly EVENT_SET_PROGRESS: string = 'setProgress';
  static readonly EVENT_SET_VOLUME: string = 'setVolume';

  static readonly EVENT_PLAY: string = 'play';
  static readonly EVENT_PAUSE: string = 'pause';
  static readonly EVENT_STOP: string = 'stop';
  static readonly EVENT_ERROR: string = 'error';

  static readonly EVENT_PLAYER_PLAYING: string = 'playerPlaying';
  static readonly EVENT_PLAYER_PAUSE: string = 'playerPause';
  static readonly EVENT_PLAYER_ENDED: string = 'playerEnded';
  static readonly EVENT_PLAYER_ERROR: string = 'playerError';
  static readonly EVENT_PLAYER_LOADSTART: string = 'playerLoadstart';
  static readonly EVENT_PLAYER_EMPTIED: string = 'playerEmptied';
  static readonly EVENT_PLAYER_WAITING: string = 'playerWaiting';

  static readonly EVENT_PIC_UPDATED: string = 'picUpdated';
  static readonly EVENT_LYRIC_UPDATED: string = 'lyricUpdated';
  static readonly EVENT_LYRIC_OFFSET_UPDATE: string = 'lyricOffsetUpdate';

  static readonly EVENT_MY_LIST_MUSIC_UPDATE: string = 'myListMusicUpdate';
  static readonly EVENT_DOWNLOAD_LIST_UPDATE: string = 'downloadListUpdate';
  static readonly EVENT_MUSIC_INFO_UPDATE: string = 'musicInfoUpdate';

  static readonly EVENT_SEARCH_TYPE_CHANGED: string = 'searchTypeChanged';
  static readonly EVENT_CHANGE_MENU_VISIBLE: string = 'changeMenuVisible';

  static readonly EVENT_JUMP_LIST_POSITION: string = 'jumpListPosition';
  static readonly EVENT_CHANGE_LOVE_LIST_VISIBLE: string = 'changeLoveListVisible';

  static readonly EVENT_SHOW_SONGLIST_TAG_LIST: string = 'showSonglistTagList';
  static readonly EVENT_HIDE_SONGLIST_TAG_LIST: string = 'hideSonglistTagList';
  static readonly EVENT_SONGLIST_TAG_INFO_CHANGE: string = 'songlistTagInfoChange';

  static readonly EVENT_SELECT_SYNC_MODE: string = 'selectSyncMode';
}

export const appEventBus: AppEventBus = new AppEventBus();