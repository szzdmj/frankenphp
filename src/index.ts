import { MyContainer } from "./container";

export { MyContainer }; // durable object 必须这么导出

export default {
  async fetch(request: Request): Promise<Response> {
    return new Response("Worker is live. Durable Object will respond via fetch().");
  }
};
