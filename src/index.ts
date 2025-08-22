import { Container, getRandom } from "@cloudflare/containers";

export class MyContainer extends Container {
  defaultPort = 80; // 保证与 Dockerfile EXPOSE 80 配套
  sleepAfter = "1m";
}

const INSTANCE_COUNT = 5;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // 获取随机容器实例
    const container = await getRandom(env.MY_CONTAINER, INSTANCE_COUNT);

    // 显式启动容器（必要！否则就会报你看到的错）
    await container.start();

    // 转发请求
    return await container.fetch(request);
  },
};
