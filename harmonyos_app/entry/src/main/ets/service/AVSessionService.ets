/**
 * 对应 Android 源文件: src/core/player/notification.ts (MediaSession)
 *
 * AVSession 通知栏播放控制
 * HarmonyOS NEXT 使用 AVSession 替代 Android MediaSession
 */
import { avSession } from '@kit.AVSessionKit';
import { common } from '@kit.AbilityKit';
import { playerService } from './PlayerService';
import { GlobalContext } from '../utils/GlobalContext';

const TAG = 'AVSessionService';

export class AVSessionService {
  private static instance: AVSessionService;
  private session: avSession.AVSession | null = null;

  private constructor() {
  }

  static getInstance(): AVSessionService {
    if (!AVSessionService.instance) {
      AVSessionService.instance = new AVSessionService();
    }
    return AVSessionService.instance;
  }

  async createSession(): Promise<void> {
    const context = GlobalContext.getContext();
    if (!context) {
      console.error(TAG + ': context is null');
      return;
    }

    try {
      this.session = await avSession.createAVSession(
        context,
        'LxMusic',
        'audio'
      );

      await this.session.activate();

      // 设置元数据
      const metadata: avSession.AVMetadata = {
        assetId: '0',
        title: '落雪音乐',
        artist: '',
        author: '',
        album: '',
        duration: 0,
        mediaImage: undefined,
      };
      await this.session.setAVMetadata(metadata);

      // 设置播放状态
      await this.session.setAVPlaybackState({
        state: avSession.AVPlaybackState.PLAYBACK_STATE_INITIAL,
      });

      // 注册控制命令
      this.session.on('play', () => {
        playerService.play();
      });

      this.session.on('pause', () => {
        playerService.pause();
      });

      this.session.on('stop', () => {
        playerService.stop();
      });

      this.session.on('playNext', () => {
        playerService.playNext();
      });

      this.session.on('playPrevious', () => {
        // 上一首
        console.log('play previous');
      });

      this.session.on('seek', (time: number) => {
        playerService.seekTo(time);
      });

      console.info(TAG + ': AVSession created successfully');
    } catch (err) {
      console.error(TAG + ': create AVSession failed: ' + JSON.stringify(err));
    }
  }

  async updatePlaybackState(isPlaying: boolean): Promise<void> {
    if (!this.session) {
      return;
    }
    try {
      await this.session.setAVPlaybackState({
        state: isPlaying ?
          avSession.AVPlaybackState.PLAYBACK_STATE_PLAY :
          avSession.AVPlaybackState.PLAYBACK_STATE_PAUSE,
      });
    } catch (err) {
      console.error(TAG + ': updatePlaybackState failed');
    }
  }

  async updateMetadata(
    title: string,
    artist: string,
    album: string,
    duration: number
  ): Promise<void> {
    if (!this.session) {
      return;
    }
    try {
      const metadata: avSession.AVMetadata = {
        assetId: '1',
        title: title,
        artist: artist,
        author: '',
        album: album,
        duration: duration,
        mediaImage: undefined,
      };
      await this.session.setAVMetadata(metadata);
    } catch (err) {
      console.error(TAG + ': updateMetadata failed');
    }
  }

  async destroy(): Promise<void> {
    if (this.session) {
      await this.session.deactivate();
      await this.session.destroy();
      this.session = null;
    }
  }
}

export const avSessionService: AVSessionService = AVSessionService.getInstance();