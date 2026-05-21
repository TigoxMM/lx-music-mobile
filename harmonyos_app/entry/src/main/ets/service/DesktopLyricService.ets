/**
 * 对应 Android 源文件: src/utils/nativeModules/lyricDesktop.ts
 *
 * 桌面歌词悬浮窗服务
 * 使用 Window API 创建全局悬浮窗口
 */
import { window } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'DesktopLyricService';

export interface DesktopLyricConfig {
  x: number
  y: number
  width: number
  fontSize: number
  opacity: number
  maxLineNum: number
  isSingleLine: boolean
  isLock: boolean
  textPositionX: 'left' | 'center' | 'right'
  textPositionY: 'top' | 'center' | 'bottom'
  lyricUnplayColor: string
  lyricPlayedColor: string
  lyricShadowColor: string
}

export class DesktopLyricService {
  private static instance: DesktopLyricService;
  private floatWindow: window.Window | null = null;
  private isShowing: boolean = false;
  private currentLyricText: string = '';
  private playedLine: number = 0;
  private totalLines: number = 0;

  config: DesktopLyricConfig = {
    x: 0,
    y: 100,
    width: 100,
    fontSize: 18,
    opacity: 100,
    maxLineNum: 5,
    isSingleLine: false,
    isLock: false,
    textPositionX: 'left',
    textPositionY: 'center',
    lyricUnplayColor: 'rgba(255, 255, 255, 1)',
    lyricPlayedColor: 'rgba(7, 197, 86, 1)',
    lyricShadowColor: 'rgba(0, 0, 0, 0.6)',
  };

  private constructor() {
  }

  static getInstance(): DesktopLyricService {
    if (!DesktopLyricService.instance) {
      DesktopLyricService.instance = new DesktopLyricService();
    }
    return DesktopLyricService.instance;
  }

  async show(): Promise<void> {
    if (this.isShowing) {
      return;
    }

    try {
      const displayInfo = display.getDefaultDisplaySync();
      const screenWidth = displayInfo.width;
      const windowWidth = Math.floor(screenWidth * this.config.width / 100);

      this.floatWindow = await window.createWindow(
        'DesktopLyricWindow',
        { windowType: window.WindowType.TYPE_FLOAT }
      );

      await this.floatWindow.moveWindowTo(
        this.config.x,
        this.config.y
      );

      await this.floatWindow.resize(windowWidth, 200);
      await this.floatWindow.setWindowBackgroundColor('rgba(0,0,0,0)');

      // 透明窗口
      await this.floatWindow.setWindowOpacity(this.config.opacity / 100);

      await this.floatWindow.showWindow();
      this.isShowing = true;

      console.info(TAG + ': desktop lyric window shown');
    } catch (err) {
      const businessErr = err as BusinessError;
      console.error(TAG + ': show failed, code=' + businessErr.code + ', msg=' + businessErr.message);
    }
  }

  async hide(): Promise<void> {
    if (!this.isShowing || !this.floatWindow) {
      return;
    }

    try {
      await this.floatWindow.destroyWindow();
      this.floatWindow = null;
      this.isShowing = false;
      console.info(TAG + ': desktop lyric window hidden');
    } catch (err) {
      const businessErr = err as BusinessError;
      console.error(TAG + ': hide failed, code=' + businessErr.code);
    }
  }

  async updateLyric(
    lines: string[],
    currentIndex: number,
    currentTime: number,
    totalTime: number
  ): Promise<void> {
    this.playedLine = currentIndex;
    this.totalLines = lines.length;

    if (currentIndex < lines.length) {
      this.currentLyricText = lines[currentIndex];
    }
  }

  isEnabled(): boolean {
    return this.isShowing;
  }
}

export const desktopLyricService: DesktopLyricService = DesktopLyricService.getInstance();