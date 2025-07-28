// src/container.ts

export class MyContainer {
  async fetch(request: Request): Promise<Response> {
    return new Response("Hello from FrankenPHP container!");
  }
}
