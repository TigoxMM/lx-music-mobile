/**
 * 对应 Android 源文件: src/plugins/storage.ts
 * 对应 Android 源文件: src/utils/data.ts
 *
 * 数据持久化层 - 基于 HarmonyOS Preferences API
 * 对齐 Android AsyncStorage 的 Key-Value 存储模式
 */
import { preferences } from '@kit.ArkData';
import { GlobalContext } from '../utils/GlobalContext';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'PreferencesStore';

const PREFERENCES_NAME: string = 'lx_music_store';

let dataPreferences: preferences.Preferences | null = null;

async function getPreferences(): Promise<preferences.Preferences> {
  if (dataPreferences !== null) {
    return dataPreferences;
  }

  const context = GlobalContext.getContext();
  if (!context) {
    throw new Error('Context not initialized');
  }

  try {
    dataPreferences = await preferences.getPreferences(context, PREFERENCES_NAME);
    return dataPreferences;
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'Failed to get preferences: code=%{public}d, msg=%{public}s',
      businessErr.code, businessErr.message);
    throw err;
  }
}

export async function saveData(key: string, value: Object): Promise<void> {
  try {
    const pref = await getPreferences();
    const valueStr = JSON.stringify(value);
    await pref.put(key, valueStr);
    await pref.flush();
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'saveData error: key=%{public}s, msg=%{public}s', key, businessErr.message);
    throw err;
  }
}

export async function getData<T>(key: string): Promise<T | null> {
  try {
    const pref = await getPreferences();
    const valueStr = await pref.get(key, '') as string;
    if (!valueStr) {
      return null;
    }
    return JSON.parse(valueStr) as T;
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'getData error: key=%{public}s, msg=%{public}s', key, businessErr.message);
    return null;
  }
}

export async function removeData(key: string): Promise<void> {
  try {
    const pref = await getPreferences();
    await pref.delete(key);
    await pref.flush();
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'removeData error: key=%{public}s, msg=%{public}s', key, businessErr.message);
    throw err;
  }
}

export async function getAllKeys(): Promise<string[]> {
  try {
    const pref = await getPreferences();
    const allEntries = await pref.getAll();
    const keys: string[] = [];
    allEntries.forEach((_value: preferences.ValueType, key: string) => {
      keys.push(key);
    });
    return keys;
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'getAllKeys error: %{public}s', businessErr.message);
    return [];
  }
}

export async function saveDataMultiple(datas: Array<[string, Object]>): Promise<void> {
  try {
    const pref = await getPreferences();
    for (const [key, value] of datas) {
      await pref.put(key, JSON.stringify(value));
    }
    await pref.flush();
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'saveDataMultiple error: %{public}s', businessErr.message);
    throw err;
  }
}

export async function getDataMultiple(keys: string[]): Promise<Array<[string, unknown | null]>> {
  try {
    const pref = await getPreferences();
    const results: Array<[string, unknown | null]> = [];
    for (const key of keys) {
      const valueStr = await pref.get(key, '') as string;
      if (valueStr) {
        try {
          results.push([key, JSON.parse(valueStr)]);
        } catch (_) {
          results.push([key, valueStr]);
        }
      } else {
        results.push([key, null]);
      }
    }
    return results;
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'getDataMultiple error: %{public}s', businessErr.message);
    return [];
  }
}

export async function removeDataMultiple(keys: string[]): Promise<void> {
  try {
    const pref = await getPreferences();
    for (const key of keys) {
      await pref.delete(key);
    }
    await pref.flush();
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'removeDataMultiple error: %{public}s', businessErr.message);
    throw err;
  }
}

export async function clearAll(): Promise<void> {
  try {
    const pref = await getPreferences();
    await pref.clear();
    await pref.flush();
  } catch (err) {
    const businessErr = err as BusinessError;
    hilog.error(0x0000, TAG, 'clearAll error: %{public}s', businessErr.message);
    throw err;
  }
}