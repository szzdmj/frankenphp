import { Container } from "@cloudflare/containers";

export class MyContainer extends Container {}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    return await serve({
      container: {
        entrypoint: [],
      },
      request,
      env,
      ctx,
    });
  },
};
