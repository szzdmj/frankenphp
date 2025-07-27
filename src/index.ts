import { getAssetFromKV } from '@cloudflare/kv-asset-handler';
import type { DurableObjectNamespace } from '@cloudflare/workers-types';

export interface Env {
  MyContainer: DurableObjectNamespace;
  KV: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env) {
    // 静态资源优先
    try {
      return await getAssetFromKV(request, { cacheControl: { bypassCache: true } });
    } catch {
      // 转发到 Container Durable Object
      const id = env.MyContainer.idFromName('instance');
      const stub = env.MyContainer.get(id);
      return stub.fetch(request);
    }
  }
};
