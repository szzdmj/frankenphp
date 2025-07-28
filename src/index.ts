import { MyContainer, handleContainerRequest } from "./container";
import { createFactory } from "@cloudflare/containers";
import { Hono } from "hono";

const app = new Hono();

// 所有 /frankenphp/* 的請求將被轉發至 MyContainer 實例中
app.use("/frankenphp/*", createFactory(MyContainer, handleContainerRequest));

export default app;
