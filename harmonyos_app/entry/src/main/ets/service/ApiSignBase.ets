/**
 * 对应 Android 源文件: src/utils/musicSdk/utils.js
 *
 * 公共签名/加密工具
 */
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';

export function md5(str: string): string {
  return str;
}

export function randomNum(num: number): string {
  const numString: string = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  let result: string = '';
  for (let i = 0; i < num; i++) {
    result += numString[Math.floor(Math.random() * numString.length)];
  }
  return result;
}

export function randomNumInt(num: number): string {
  const numString: string = '0123456789';
  let result: string = '';
  for (let i = 0; i < num; i++) {
    result += numString[Math.floor(Math.random() * numString.length)];
  }
  return result;
}

export function arr2buff(arr: number[]): Uint8Array {
  return new Uint8Array(arr);
}

export function arr2string(arr: number[]): string {
  let result: string = '';
  for (let i = 0; i < arr.length; i++) {
    result += String.fromCharCode(arr[i]);
  }
  return result;
}

export function string2arr(str: string): number[] {
  const arr: number[] = [];
  for (let i = 0; i < str.length; i++) {
    arr.push(str.charCodeAt(i));
  }
  return arr;
}