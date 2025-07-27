import { Router } from "hono";
import { createContainerWorker, Container } from "@cloudflare/containers";

// Durable Object 类
export class MyContainer {
  fetch(request: Request) {
    return new Response("Hello from Durable Object container", { status: 200 });
  }
}

// 导出 Durable Object
export { MyContainer };

// 创建 container worker
const app = new Router();

app.get("/", (c) => c.text("Hello world"));

export default createContainerWorker({
  container: new Container({
    namespace: MY_CONTAINER, // 与 wrangler binding 一致
    maxConcurrency: 10
  }),
  router: app
});
