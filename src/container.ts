export class MyContainer {
  constructor(private readonly state: DurableObjectState, private readonly env: Env) {}

  async fetch(request: Request): Promise<Response> {
    return new Response("Hello from FrankenPHP container!", {
      headers: { "Content-Type": "text/plain" },
    });
  }
}
