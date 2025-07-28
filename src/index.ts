import { Hono } from "hono";
import { handleContainerRequest } from "./container";

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    try {
      const url = new URL(request.url);

      // 调试：日志输出路径
      console.log(`📥 Request pathname: ${url.pathname}`);

      // 所有非 API 路径，直接交给 DO 处理
      return await handleContainerRequest(request, env, ctx);
    } catch (e: any) {
      console.error("❌ Worker crashed with error:", e);
      return new Response("Internal Error", { status: 500 });
    }
  }
};
