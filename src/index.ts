import { MyContainer } from './container';

export default {
  async fetch(req: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    return env.MY_CONTAINER.fetch(req);
  },
};

export { MyContainer };
