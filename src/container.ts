import type { Env } from "./index";

export class MyContainer {
  state: DurableObjectState;
  env: Env;

  constructor(state: DurableObjectState, env: Env) {
    this.state = state;
    this.env = env;
    console.log("⚙️ MyContainer Durable Object initialized");
  }

  async fetch(request: Request): Promise<Response> {
    console.log("🔄 DO fetch() called with URL:", request.url);

    return new Response("✅ Hello from Durable Object!");
  }
}
