import { handleContainerRequest } from "./container";

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    try {
      const url = new URL(request.url);
      console.log(`📥 Request pathname: ${url.pathname}`);

      // 所有请求统一转发给 DO
      return await handleContainerRequest(request, env, ctx);
    } catch (e: any) {
      console.error("❌ Worker crashed with error:", e);
      return new Response("Internal Error", { status: 500 });
    }
  }
};
