export class MyContainer {
async fetch(request: Request): Promise<Response> {
const url = new URL(request.url);
// 🛠️ 调试接口：测试容器响应
if (url.pathname === "/__probe") {
  const backend = "http://frankenphp:8080/";
  try {
    const init: RequestInit = {
      method: "GET",
      headers: {
        "User-Agent": "Cloudflare-Probe"
      }
    };
    const resp = await fetch(backend, init);
    const text = await resp.text();
    console.log("[__probe] Connected to container, status:", resp.status);
    return new Response(
      `✅ Container responded ${resp.status}:\n\n${text.slice(0, 300)}`,
      { status: 200, headers: { "Content-Type": "text/plain" } }
    );
  } catch (err: any) {
    console.error("[__probe] Container connection failed:", err.stack || err);
    return new Response("❌ Probe error:\n" + (err.stack || err.message || err), {
      status: 502,
      headers: { "Content-Type": "text/plain" }
    });
  }
}

// 🌐 代理所有其他请求
const proxyUrl = "http://frankenphp:8080" + url.pathname;
try {
  const resp = await fetch(proxyUrl, request);
  return resp;
} catch (err) {
  console.error("[Proxy Error] Failed forwarding to frankenphp:", err);
  return new Response("❌ Proxy failed:\n" + String(err), {
    status: 502,
    headers: { "Content-Type": "text/plain" }
  });
}
