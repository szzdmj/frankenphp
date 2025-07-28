export { MyContainer } from "./container"; // 👈 必须添加：导出 Durable Object 类

export default {
async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
const id = env.MY_CONTAINER.idFromName("default");
const stub = env.MY_CONTAINER.get(id);
return await stub.fetch(request);
}
};

interface Env {
MY_CONTAINER: DurableObjectNamespace;
}
