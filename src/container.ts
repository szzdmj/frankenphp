import { createContainer } from "@cloudflare/containers";

export default {
async fetch(request: Request) {
return new Response("MyContainer is alive", {
headers: { "content-type": "text/plain" },
});
},
};

export const MyContainer = createContainer({
// 默认端口 8080，会读取容器内 /public/Caddyfile
// Durable Object will proxy requests here
// 也支持 process: ["frankenphp", "-c", "/public/Caddyfile"]
});

📄 同时，确保 src/index.ts 正确绑定：

src/index.ts:

expo
