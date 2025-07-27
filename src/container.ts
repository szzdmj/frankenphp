export class MyContainer {
  async fetch(request: Request) {
    return new Response("Hello from Durable Object container", { status: 200 });
  }
}
