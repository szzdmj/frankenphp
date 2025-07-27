import { Container } from "@cloudflare/containers";

export class MyContainer extends Container {
  async fetch(request: Request): Promise<Response> {
    return await this.run(request);
  }
}

// 👇 显式导出 Durable Object 类（这是 ES Module Worker 关键）
export default {
  fetch(request: Request, env: Env, ctx: ExecutionContext) {
    return new Response("FrankenPHP container is set up!");
  }
}
