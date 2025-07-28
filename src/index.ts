import { Hono } from "hono";
import { createFactory } from "@cloudflare/containers";
import { MyContainer, handleContainerRequest } from "./container";

const app = new Hono();

app.use("/frankenphp/*", createFactory(MyContainer, handleContainerRequest));

export default app;
