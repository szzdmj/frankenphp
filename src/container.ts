import { runContainer } from "@cloudflare/containers";

export class MyContainer {
  constructor(private readonly state: DurableObjectState) {}

  async fetch(request: Request): Promise<Response> {
    return await runContainer({
      request,
      env: {},
      ctx: this.state,
    });
  }
}
