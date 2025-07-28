export class MyContainer {
  constructor(private state: DurableObjectState, private env: Env) {}

  async fetch(request: Request): Promise<Response> {
    try {
      const url = new URL(request.url);
      console.log(`📦 DO Handling ${url.pathname}`);
      return new Response("✅ Hello from Durable Object!");
    } catch (e) {
      console.error("❌ DO crashed with error:", e);
      return new Response("Internal Error (DO)", { status: 500 });
    }
  }
}

// ✅ 添加这个导出函数，让 index.ts 能调用
export async function handleContainerRequest(
  request: Request,
  env: Env,
  ctx: ExecutionContext
): Promise<Response> {
  const id = env.MY_CONTAINER.idFromName("frankenphp");
  const stub = env.MY_CONTAINER.get(id);
  return await stub.fetch(request);
}
