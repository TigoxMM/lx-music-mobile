/**
 * 对应 Android 源文件: src/utils/tools.ts
 *
 * 全局上下文管理器，用于在各模块间共享 Context 引用
 */
import { common } from '@kit.AbilityKit';

export class GlobalContext {
  private static instance: GlobalContext;
  private _context: common.UIAbilityContext | null = null;

  private constructor() {
  }

  static getInstance(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  static getContext(): common.UIAbilityContext | null {
    return GlobalContext.getInstance()._context;
  }

  static setContext(context: common.UIAbilityContext): void {
    GlobalContext.getInstance()._context = context;
  }
}