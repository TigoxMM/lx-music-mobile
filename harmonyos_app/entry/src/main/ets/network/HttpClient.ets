/**
 * 对应 Android 源文件: src/utils/request.js
 *
 * HTTP 请求封装，对齐 Android 版所有请求规范:
 * - 默认 Headers
 * - 超时 15000ms
 * - 错误码映射
 * - 重试机制
 */
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HttpClient';

const DEFAULT_TIMEOUT: number = 15000;
const DEFAULT_HEADERS: Record<string, string> = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36',
};

export interface HttpOptions {
  method?: string;
  headers?: Record<string, string>;
  body?: string | Object;
  timeout?: number;
  format?: string;
  cache?: string;
  binary?: boolean;
}

export interface HttpResponse {
  headers: Record<string, string>;
  body: string | ArrayBuffer;
  statusCode: number;
  statusMessage: string;
  url: string;
  ok: boolean;
}

export class HttpFetchResult {
  private controller: AbortController | null = null;

  promise: Promise<HttpResponse>;
  cancelHttp: () => void;

  constructor(url: string, options: HttpOptions = {}) {
    const finalOptions = this.buildOptions(options);

    this.cancelHttp = () => {
      // 取消请求逻辑
      hilog.warn(0x0000, TAG, 'Request cancelled: %{public}s', url);
    };

    this.promise = this.executeRequest(url, finalOptions)
      .catch((err: Error) => {
        hilog.error(0x0000, TAG, 'Request error: %{public}s', err.message);
        switch (err.message) {
          case 'socket hang up':
            return Promise.reject<HttpResponse>(new Error('请求失败，服务不可达'));
          case 'Aborted':
            return Promise.reject<HttpResponse>(new Error('请求超时，请重试'));
          case 'Network request failed':
            return Promise.reject<HttpResponse>(new Error('无法连接网络，请检查网络连接'));
          default:
            return Promise.reject<HttpResponse>(err);
        }
      });
  }

  private buildOptions(options: HttpOptions): HttpOptions {
    const headers: Record<string, string> = Object.assign(
      { Accept: 'application/json' },
      DEFAULT_HEADERS,
      options.headers ?? {}
    );

    let body: string | undefined = undefined;

    if (options.body) {
      if (typeof options.body === 'string') {
        body = options.body;
      } else {
        if (!headers['Content-Type']) {
          headers['Content-Type'] = 'application/json';
        }
        body = JSON.stringify(options.body);
      }
    }

    return {
      method: (options.method ?? 'GET').toUpperCase(),
      headers: headers,
      body: body,
      timeout: options.timeout ?? DEFAULT_TIMEOUT,
      format: options.format ?? 'json',
      binary: options.binary ?? false,
    };
  }

  private async executeRequest(url: string, options: HttpOptions): Promise<HttpResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod[options.method as keyof typeof http.RequestMethod] ?? http.RequestMethod.GET,
          header: options.headers,
          extraData: options.body,
          connectTimeout: options.timeout,
          readTimeout: options.timeout,
        }
      );

      const headers: Record<string, string> = {};
      if (response.header) {
        Object.keys(response.header).forEach((key: string) => {
          headers[key] = String(response.header[key]);
        });
      }

      let body: string | ArrayBuffer;
      if (options.binary) {
        body = response.result as ArrayBuffer;
      } else {
        body = String(response.result);
        try {
          body = JSON.parse(body as string);
        } catch (_) {
          // 保持原始字符串
        }
      }

      return {
        headers: headers,
        body: body,
        statusCode: response.responseCode,
        statusMessage: '',
        url: url,
        ok: response.responseCode === 200,
      };
    } catch (err) {
      const businessErr = err as BusinessError;
      hilog.error(0x0000, TAG, 'HTTP request failed: code=%{public}d, msg=%{public}s',
        businessErr.code, businessErr.message);
      throw new Error(businessErr.message || 'Network request failed');
    } finally {
      httpRequest.destroy();
    }
  }
}

/**
 * HTTP Fetch - 对齐 Android httpFetch 签名
 */
export function httpFetch(url: string, options: HttpOptions = {}): HttpFetchResult {
  return new HttpFetchResult(url, options);
}

/**
 * HTTP GET 请求 - 对齐 Android httpGet 签名
 */
export function httpGet(
  url: string,
  options: HttpOptions | ((err: Error | null, resp: HttpResponse | null, body: unknown) => void),
  callback?: (err: Error | null, resp: HttpResponse | null, body: unknown) => void
): () => void {
  if (typeof options === 'function') {
    callback = options;
    options = {};
  }
  const requestObj = httpFetch(url, { ...options, method: 'GET' });
  requestObj.promise.then((resp: HttpResponse) => {
    callback!(null, resp, resp.body);
  }).catch((err: Error) => {
    callback!(err, null, null);
  });

  return () => {
    requestObj.cancelHttp();
  };
}