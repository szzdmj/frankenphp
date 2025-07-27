export class MyContainer {
  async fetch(request: Request) {
    return new Response("Hello from FrankenPHP container", { status: 200 });
  }
}
