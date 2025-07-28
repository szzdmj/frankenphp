import { Hono } from "hono";
import { MyContainer } from "./container";

export interface Env {
  MY_CONTAINER: DurableObjectNamespace;
  KV: KVNamespace;
}

const app = new Hono<Env>();

console.log("✅ Worker started");

app.get("/", async (c) => {
  console.log("📥 Received request to '/'");

  const id = c.env.MY_CONTAINER.idFromName("demo");
  const stub = c.env.MY_CONTAINER.get(id);
  const res = await stub.fetch("http://do/demo");

  console.log("📤 Response received from Durable Object");

  return res;
});

export default {
  fetch: app.fetch,
};

// ✅ 必须导出 Durable Object
export { MyContainer } from "./container";
