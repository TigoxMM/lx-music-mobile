/**
 * 对应 Android 源文件: src/utils/common.ts
 *
 * 通用工具函数
 */

export function formatPlayTime(seconds: number): string {
  if (Number.isNaN(seconds) || seconds < 0) {
    return '00:00';
  }
  const m: number = Math.floor(seconds / 60);
  const s: number = Math.floor(seconds % 60);
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

export function formatPlayTimeMs(ms: number): string {
  return formatPlayTime(ms / 1000);
}

export function sizeFormate(size: number): string {
  if (!size || size <= 0) {
    return '0B';
  }
  const units: string[] = ['B', 'KB', 'MB', 'GB'];
  let index: number = 0;
  let displaySize: number = size;
  while (displaySize >= 1024 && index < units.length - 1) {
    displaySize /= 1024;
    index++;
  }
  return `${displaySize.toFixed(2)}${units[index]}`;
}

export function formatPlayCount(count: number): string {
  if (count >= 100000000) {
    return `${(count / 100000000).toFixed(1)}亿`;
  }
  if (count >= 10000) {
    return `${(count / 10000).toFixed(1)}万`;
  }
  return String(count);
}

export function decodeName(str: string): string {
  if (!str) {
    return str;
  }
  try {
    return decodeURIComponent(str);
  } catch (_) {
    return str;
  }
}

export function getRandom(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export function throttle<T extends (...args: Object[]) => void>(fn: T, delay: number): T {
  let timer: number | null = null;
  return ((...args: Object[]) => {
    if (timer !== null) {
      return;
    }
    timer = setTimeout(() => {
      fn(...args);
      timer = null;
    }, delay);
  }) as unknown as T;
}

export function dateFormat(timestamp: number, format: string): string {
  const date = new Date(timestamp);
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();

  return format
    .replace('Y', String(year))
    .replace('M', String(month).padStart(2, '0'))
    .replace('D', String(day).padStart(2, '0'));
}

export function formatSingerName(
  singers: Array<{ name: string }>,
  nameKey: string = 'name'
): string {
  if (!singers || singers.length === 0) {
    return '';
  }
  return singers.map((s: Record<string, string>) => s[nameKey] ?? '').join('、');
}