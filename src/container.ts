// src/container.ts

export class MyContainer {
  constructor(readonly state: DurableObjectState, readonly env: any) {}

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    // 简单示例：尝试从 Caddyfile 提供的静态文件中返回内容
    if (url.pathname.startsWith("/index1.html")) {
      return fetch("http://localhost:80/index1.html", {
        method: request.method,
        headers: request.headers,
      });
    }

    // 默认返回信息
    return new Response("Hello from Durable Object!", {
      headers: { "Content-Type": "text/plain" },
    });
  }
}
