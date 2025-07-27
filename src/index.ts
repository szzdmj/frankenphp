import { Container, loadBalance, getContainer } from "@cloudflare/containers";
import { Hono } from "hono";

export class MyContainer extends Container {
  defaultPort = 8080;
  sleepAfter = "2m";
  envVars = {
    MESSAGE: "I was passed in via the container class!",
  };

  override onStart() {
    console.log("Container started");
  }

  override onStop() {
    console.log("Container stopped");
  }

  override onError(error: unknown) {
    console.log("Container error:", error);
  }
}

const app = new Hono<{
  Bindings: {
    MY_CONTAINER: DurableObjectNamespace<MyContainer>;
    ORIGIN: string;
  };
}>();

app.get("/", (c) =>
  c.text(
    "Endpoints:\n" +
      "/container/:id\n" +
      "/lb\n" +
      "/singleton\n" +
      "Unmatched paths → proxied to FrankenPHP container"
  )
);

app.get("/container/:id", async (c) => {
  const id = c.req.param("id");
  const containerId = c.env.MY_CONTAINER.idFromName(`/container/${id}`);
  const container = c.env.MY_CONTAINER.get(containerId);
  return await container.fetch(c.req.raw);
});

app.get("/lb", async (c) => {
  const container = await loadBalance(c.env.MY_CONTAINER, 3);
  return await container.fetch(c.req.raw);
});

app.get("/singleton", async (c) => {
  const container = getContainer(c.env.MY_CONTAINER);
  return await container.fetch(c.req.raw);
});

app.all("*", async (c) => {
  const container = getContainer(c.env.MY_CONTAINER, "fallback");
  return await container.fetch(c.req.raw);
});

export default app;
