import { Container, getRandom } from "@cloudflare/containers";

export class MyContainer extends Container {
  defaultPort = 80; // 容器监听端口
  sleepAfter = "1m";
}

const INSTANCE_COUNT = 5;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // 获取可用容器实例
    const container = await getRandom(env.MY_CONTAINER, INSTANCE_COUNT);

    // 启动容器（Cloudflare API 支持 start 方法时）
    if (container.start) {
      await container.start();
    }

    // 转发请求
    return await container.fetch(request);
  },
};
