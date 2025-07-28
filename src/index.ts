import { MyContainer, handleContainerRequest } from "./container";

// 必须导出 Durable Object 类名
export { MyContainer };

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    try {
      return await handleContainerRequest(request, env, ctx);
    } catch (err) {
      console.error("Fatal error in fetch:", err);
      return new Response("Internal Error", { status: 500 });
    }
  },
};
