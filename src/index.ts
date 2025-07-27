import { Router } from "hono";
import { createContainerWorker, Container } from "@cloudflare/containers";

// 定义 Durable Object
export class MyContainer {
  fetch(request: Request) {
    return new Response("Hello from Durable Object container", { status: 200 });
  }
}

// 路由设置（可选）
const router = new Router();

router.get("/", (c) => c.text("Hello from Worker"));

// 默认导出 container worker
export default createContainerWorker({
  container: new Container({
    namespace: MY_CONTAINER,
    maxConcurrency: 10
  }),
  router
});
