import { MyContainer } from "./container";

// 必须这样导出 Durable Object 类，Cloudflare 才能识别
export { MyContainer };
