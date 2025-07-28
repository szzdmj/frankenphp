import type { ExecutionContext } from "@cloudflare/workers-types";

// Durable Object 实现
export class MyContainer {
  private state: DurableObjectState;
  private env: Env;

  constructor(state: DurableObjectState, env: Env) {
    this.state = state;
    this.env = env;
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    console.log(`[DO] Incoming request to: ${url.pathname}`);

    if (url.pathname === "/robots.txt") {
      return new Response("User-agent: *\nDisallow:", {
        status: 200,
        headers: { "content-type": "text/plain" },
      });
    }

    return new Response("Hello from Durable Object!", {
      status: 200,
      headers: { "content-type": "text/plain" },
    });
  }
}

// Worker 主函数用于转发请求到 Durable Object
export async function handleContainerRequest(
  request: Request,
  env: Env,
  ctx: ExecutionContext
): Promise<Response> {
  const id = env.MY_CONTAINER.idFromName("default");
  const stub = env.MY_CONTAINER.get(id);

  try {
    return await stub.fetch(request);
  } catch (err) {
    console.error("Error forwarding to DO:", err);
    return new Response("Internal Error", { status: 500 });
  }
}
