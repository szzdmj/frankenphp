import { createContainerWorker, Container } from "@cloudflare/containers";

// 简单容器类，实现必须和 wrangler.jsonc 中的 class_name 一致
export class MyContainer extends Container {}

export default {
  fetch: createContainerWorker(MyContainer)
};
