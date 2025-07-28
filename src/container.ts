export class MyContainer {
  async fetch(request: Request): Promise<Response> {
    // 這裡可以根據 URL 路徑自訂邏輯，例如處理 POST 請求、回應靜態頁面等
    return new Response("Hello from MyContainer!");
  }
}

// 可在 index.ts 中透過 createFactory 將此函式當作 handler 傳入
export async function handleContainerRequest(request: Request, controller: MyContainer): Promise<Response> {
  return controller.fetch(request);
}
