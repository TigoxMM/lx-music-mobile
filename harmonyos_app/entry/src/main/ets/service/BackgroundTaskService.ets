/**
 * 对应 Android 源文件: android/src/main/java/.../BackgroundTaskManager
 *
 * 后台长时任务管理器
 * 用于音乐后台播放保持
 */
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { GlobalContext } from '../utils/GlobalContext';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'BackgroundTaskService';

export class BackgroundTaskService {
  private static instance: BackgroundTaskService;
  private isRunning: boolean = false;
  private myWantAgent: WantAgent | null = null;

  private constructor() {
  }

  static getInstance(): BackgroundTaskService {
    if (!BackgroundTaskService.instance) {
      BackgroundTaskService.instance = new BackgroundTaskService();
    }
    return BackgroundTaskService.instance;
  }

  async startBackgroundRunning(): Promise<void> {
    if (this.isRunning) {
      return;
    }

    try {
      const context = GlobalContext.getContext();
      if (!context) {
        console.error(TAG + ': context is null');
        return;
      }

      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: context.abilityInfo.bundleName,
            abilityName: context.abilityInfo.name,
          },
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
      };

      this.myWantAgent = await wantAgent.getWantAgent(wantAgentInfo);

      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        this.myWantAgent
      );

      this.isRunning = true;
      console.info(TAG + ': background task started');
    } catch (err) {
      const businessErr = err as BusinessError;
      console.error(TAG + ': start failed, code=' + businessErr.code + ', msg=' + businessErr.message);
    }
  }

  async stopBackgroundRunning(): Promise<void> {
    if (!this.isRunning) {
      return;
    }

    try {
      const context = GlobalContext.getContext();
      if (!context) {
        return;
      }

      await backgroundTaskManager.stopBackgroundRunning(context);
      this.isRunning = false;
      console.info(TAG + ': background task stopped');
    } catch (err) {
      const businessErr = err as BusinessError;
      console.error(TAG + ': stop failed, code=' + businessErr.code + ', msg=' + businessErr.message);
    }
  }
}

export const backgroundTaskService: BackgroundTaskService = BackgroundTaskService.getInstance();