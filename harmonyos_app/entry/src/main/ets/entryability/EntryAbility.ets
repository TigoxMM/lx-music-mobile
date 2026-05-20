/**
 * 对应 Android 源文件: android/app/src/main/java/cn/toside/music/mobile/MainActivity.java
 * 对应 Android 源文件: android/app/src/main/java/cn/toside/music/mobile/MainApplication.java
 * 对应 Android 源文件: src/app.ts index.js
 *
 * 应用入口 Ability，负责应用生命周期管理和全局初始化
 */
import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { GlobalContext } from '../utils/GlobalContext';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');

    GlobalContext.setContext(this.context);

    // 全局初始化将在此处进行:
    // - 数据初始化 (对应 src/core/init/dataInit.ts)
    // - 主题初始化 (对应 src/core/init/theme.ts)
    // - 语言初始化 (对应 src/core/init/i18n.ts)
    // - 播放器初始化 (对应 src/core/init/player/index.ts)
    // - 用户API初始化 (对应 src/core/init/userApi/index.ts)
    // - 同步服务初始化 (对应 src/core/init/sync.ts)
    // - DeepLink 初始化 (对应 src/core/init/deeplink/index.ts)
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'onDestroy');
    // 保存播放状态 (对应 src/core/player/playInfo.ts savePlayInfo)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, TAG, 'onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, TAG, 'onBackground');
  }
}