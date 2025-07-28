import { Container } from "@cloudflare/containers";

export class MyContainer extends Container {}
const id = env.frankenphp_container.idFromName("main");
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
