export class MyContainer {
  state: DurableObjectState;

  constructor(state: DurableObjectState, env: any) {
    this.state = state;
  }

  async fetch(request: Request) {
    console.log("→ Durable Object received request");
    return fetch(request); // 转发请求给容器实例
  }
}

export async function handleContainerRequest(request: Request, env: any) {
  const id = env.MY_CONTAINER.idFromName("singleton");
  const stub = env.MY_CONTAINER.get(id);
  return stub.fetch(request);
}
