/**
 * 对应 Android 源文件: src/core/player/player.ts
 * 对应 Android 源文件: src/core/player/playInfo.ts
 * 对应 Android 源文件: src/core/player/playStatus.ts
 * 对应 Android 源文件: src/core/player/playProgress.ts
 *
 * 播放器核心服务
 * 使用 AVPlayer 替代 react-native-track-player
 * 播放模式对齐 Android 版
 */
import { media } from '@kit.MediaKit';
import { appEventBus } from './AppEventBus';
import { MusicInfo } from '../model/MusicInfo';
import { PlayMusicInfo, PlayInfo, PlayerMusicInfo, PlayerProgress, TogglePlayMethod } from '../model/PlayerInfo';
import { formatPlayTime } from '../utils/CommonUtils';
import { getData, saveData } from '../database/PreferencesStore';
import { storageDataPrefix } from '../constants/Constant';
import { BusinessError } from '@kit.BasicServicesKit';

export class PlayerService {
  private static instance: PlayerService;
  private avPlayer: media.AVPlayer | null = null;
  private isInitialized: boolean = false;

  // 播放状态
  playMusicInfo: PlayMusicInfo | null = null;
  isPlay: boolean = false;
  volume: number = 1;
  playRate: number = 1;
  statusText: string = '';

  togglePlayMethod: TogglePlayMethod = 'listLoop';
  playQuality: string = '128k';

  // 播放信息
  playInfo: PlayInfo = {
    playIndex: -1,
    playerListId: null,
    playerPlayIndex: -1,
  };

  musicInfo: PlayerMusicInfo = {
    id: null,
    pic: null,
    lrc: null,
    tlrc: null,
    rlrc: null,
    lxlrc: null,
    rawlrc: null,
    name: '',
    singer: '',
    album: '',
  };

  progress: PlayerProgress = {
    nowPlayTime: 0,
    maxPlayTime: 0,
    progress: 0,
    nowPlayTimeStr: '00:00',
    maxPlayTimeStr: '00:00',
  };

  playedList: PlayMusicInfo[] = [];
  tempPlayList: PlayMusicInfo[] = [];

  private constructor() {
  }

  static getInstance(): PlayerService {
    if (!PlayerService.instance) {
      PlayerService.instance = new PlayerService();
    }
    return PlayerService.instance;
  }

  async init(): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      this.registerCallbacks();
      this.isInitialized = true;
    } catch (err) {
      const businessErr = err as BusinessError;
      console.error('PlayerService init failed: ' + businessErr.message);
    }
  }

  private registerCallbacks(): void {
    if (!this.avPlayer) {
      return;
    }

    this.avPlayer.on('stateChange', (state: media.AVPlayerState) => {
      switch (state) {
        case 'initialized':
          break;
        case 'prepared':
          appEventBus.emit(AppEventBus.EVENT_PLAYER_LOADSTART);
          this.avPlayer?.play();
          break;
        case 'playing':
          this.isPlay = true;
          appEventBus.emit(AppEventBus.EVENT_PLAYER_PLAYING);
          this.startProgressTimer();
          break;
        case 'paused':
          this.isPlay = false;
          appEventBus.emit(AppEventBus.EVENT_PLAYER_PAUSE);
          break;
        case 'completed':
          this.isPlay = false;
          appEventBus.emit(AppEventBus.EVENT_PLAYER_ENDED);
          this.onTrackEnded();
          break;
        case 'stopped':
          this.isPlay = false;
          break;
        case 'released':
          this.isPlay = false;
          break;
        case 'error':
          appEventBus.emit(AppEventBus.EVENT_PLAYER_ERROR);
          break;
      }
    });

    this.avPlayer.on('error', () => {
      appEventBus.emit(AppEventBus.EVENT_PLAYER_ERROR);
    });
  }

  private progressTimer: number | null = null;

  private startProgressTimer(): void {
    this.stopProgressTimer();
    this.progressTimer = setInterval(() => {
      this.updateProgress();
    }, 500);
  }

  private stopProgressTimer(): void {
    if (this.progressTimer !== null) {
      clearInterval(this.progressTimer);
      this.progressTimer = null;
    }
  }

  private updateProgress(): void {
    if (!this.avPlayer || !this.isPlay) {
      return;
    }

    const nowPlayTime = this.avPlayer.currentTime;
    const maxPlayTime = this.avPlayer.duration;

    this.progress.nowPlayTime = nowPlayTime;
    this.progress.maxPlayTime = maxPlayTime;
    this.progress.progress = maxPlayTime > 0 ? nowPlayTime / maxPlayTime : 0;
    this.progress.nowPlayTimeStr = formatPlayTime(nowPlayTime / 1000);
    this.progress.maxPlayTimeStr = formatPlayTime(maxPlayTime / 1000);
  }

  async playMusic(music: PlayMusicInfo): Promise<void> {
    if (!this.avPlayer) {
      console.error('Player not initialized');
      return;
    }

    this.playMusicInfo = music;
    const musicData = music.musicInfo;

    // 更新当前播放信息
    this.musicInfo = {
      id: musicData.id,
      pic: (musicData as MusicInfo).meta?.picUrl ?? null,
      lrc: null,
      tlrc: null,
      rlrc: null,
      lxlrc: null,
      rawlrc: null,
      name: musicData.name,
      singer: musicData.singer,
      album: (musicData as MusicInfo).meta?.albumName ?? '',
    };

    this.statusText = '';

    // TODO: 获取音乐URL后设置
    // const url = await getMusicPlayUrl(musicData);
    // await this.avPlayer.reset();
    // this.avPlayer.url = url;

    appEventBus.emit(AppEventBus.EVENT_MUSIC_TOGGLED);
    appEventBus.emit(AppEventBus.EVENT_PIC_UPDATED);
  }

  play(): void {
    this.avPlayer?.play();
    appEventBus.emit(AppEventBus.EVENT_PLAY);
  }

  pause(): void {
    this.avPlayer?.pause();
    appEventBus.emit(AppEventBus.EVENT_PAUSE);
  }

  stop(): void {
    this.avPlayer?.stop();
    appEventBus.emit(AppEventBus.EVENT_STOP);
  }

  setVolume(volume: number): void {
    this.volume = Math.max(0, Math.min(1, volume));
    appEventBus.emit(AppEventBus.EVENT_SET_VOLUME, this.volume);
  }

  seekTo(timeMs: number): void {
    if (this.avPlayer) {
      this.avPlayer.seek(timeMs);
    }
  }

  setProgress(progress: number, maxPlayTime?: number): void {
    this.seekTo(progress * 1000);
    appEventBus.emit(AppEventBus.EVENT_SET_PROGRESS, progress);
  }

  private onTrackEnded(): void {
    this.playNext(false);
  }

  async playNext(isAutoPlay: boolean = true): Promise<void> {
    // TODO: 根据播放模式决定下一首
    console.log('playNext, mode: ' + this.togglePlayMethod);
  }

  async savePlayInfo(): Promise<void> {
    if (this.playMusicInfo) {
      const savedInfo = {
        time: this.progress.nowPlayTime,
        maxTime: this.progress.maxPlayTime,
        listId: this.playMusicInfo.listId,
        index: this.playInfo.playIndex,
      };
      await saveData(storageDataPrefix.playInfo, savedInfo);
    }
  }

  async destroy(): Promise<void> {
    this.stopProgressTimer();
    await this.savePlayInfo();
    if (this.avPlayer) {
      await this.avPlayer.release();
      this.avPlayer = null;
    }
    this.isInitialized = false;
  }
}

export const playerService: PlayerService = PlayerService.getInstance();