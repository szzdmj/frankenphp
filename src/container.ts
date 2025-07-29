// src/container.ts
export class MyContainer {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname === "/__probe") {
      try {
        const containerResp = await fetch("http://frankenphp:8080/");
        const text = await containerResp.text();
        console.log("[PROBE] Container root responded with:", text.slice(0, 200));
        return new Response("Container responded:\n" + text, { status: 200 });
      } catch (err) {
        console.error("[PROBE] Error probing container:", err);
        return new Response("Error probing container: " + err, { status: 500 });
      }
    }

    // 其它转发逻辑
    return fetch("http://frankenphp:8080" + url.pathname, request);
  }
}
