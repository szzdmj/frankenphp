import { serve } from "@cloudflare/containers";

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
