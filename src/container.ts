// ✅ 新增：探针路径，用于调试容器是否响应
if (url.pathname === "/__probe") {
  try {
    const resp = await fetch("http://frankenphp:8080/");
    const text = await resp.text();
    console.log("[PROBE] Container responded with status:", resp.status);
    console.log("[PROBE] Body preview:", text.slice(0, 200));
    return new Response(
      `✅ Container responded with status ${resp.status}\n\n${text.slice(0, 200)}`,
      { status: 200, headers: { "Content-Type": "text/plain" } }
    );
  } catch (err) {
    console.error("[PROBE] Error contacting container:", err);
    return new Response("❌ Failed to reach container:\n" + String(err), {
      status: 502,
      headers: { "Content-Type": "text/plain" }
    });
  }
}

// 正常转发请求到容器
const backendUrl = "http://frankenphp:8080" + url.pathname;
try {
  const response = await fetch(backendUrl, request);
  return response;
} catch (err) {
  console.error("[ERROR] Request failed to container:", err);
  return new Response("❌ Error forwarding to container:\n" + String(err), {
    status: 502,
    headers: { "Content-Type": "text/plain" }
  });
}
