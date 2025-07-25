import { Container, loadBalance, getContainer } from "@cloudflare/containers";
import { Hono } from "hono";

export class MyContainer extends Container {
  defaultPort = 8085;
  sleepAfter = "2m";
  envVars = {
    MESSAGE: "I was passed in via the container class!",
  };

  override onStart() {
    console.log("Container successfully started");
  }

  override onStop() {
    console.log("Container successfully shut down");
  }

  override onError(error: unknown) {
    console.log("Container error:", error);
  }
}

const app = new Hono<{
  Bindings: {
    MY_CONTAINER: DurableObjectNamespace<MyContainer>;
    ORIGIN: string; // Optional: if you use a fixed FrankenPHP backend URL
  };
}>();

app.get("/", (c) => {
  return c.text(
    "Available endpoints:\n" +
      "GET /container/:id - Start a container for that ID\n" +
      "GET /lb - Load-balanced container routing\n" +
      "GET /singleton - Singleton container\n" +
      "Other paths -> forwarded to FrankenPHP backend"
  );
});

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

app.get("/error", async (c) => {
  const container = getContainer(c.env.MY_CONTAINER, "error-test");
  return await container.fetch(c.req.raw);
});

app.all("*", async (c) => {
  // Fallback route: f
