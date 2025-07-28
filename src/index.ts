// index.ts
import { MyContainer } from "./container"; // 与 wrangler.jsonc 中的 class_name 一致
import { Hono } from "hono"; // 如果您使用 hono 框架
import { getDurableObjectStub } from "@cloudflare/workers-types"; // 示例

export default {
  async fetch(request: Request, env: any) {
    const id = env.MY_CONTAINER.idFromName("singleton");
    const stub = env.MY_CONTAINER.get(id);
    const response = await stub.fetch(request);

    return response;
  }
};

// 必须导出 Durable Object classes
export { MyContainer };
