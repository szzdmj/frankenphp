import { Container } from "@cloudflare/containers";

export class MyContainer extends Container {
  async fetch(request: Request): Promise<Response> {
    // 所有请求都转发给容器（Docker 镜像）
    return await this.run(request);
  }
}
