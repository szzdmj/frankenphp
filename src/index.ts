{
import { MyContainer, handleContainerRequest } from "./container";

export { MyContainer };

export default {
  async fetch(request: Request, env: any, ctx: ExecutionContext) {
    return handleContainerRequest(request, env);
  }
};
