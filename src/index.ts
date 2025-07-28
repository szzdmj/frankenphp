import { Hono } from 'hono'
import { serveStatic } from 'hono/cloudflare-workers'
import { MyContainer } from './container' // ← 必须导入

export type Env = {
  MY_CONTAINER: DurableObjectNamespace
  KV: KVNamespace
}

const app = new Hono<{ Bindings: Env }>()

app.all('/*.php', async (c) => {
  const path = c.req.path
  const url = `https://hello-containers.xianyue5165.workers.dev${path}`
  const resp = await fetch(url, {
    method: c.req.method,
    headers: c.req.raw.headers,
    body: c.req.raw.body,
  })
  return resp
})

app.get('/', async (c) => {
  const url = 'https://hello-containers.xianyue5165.workers.dev/index.php'
  const resp = await fetch(url, {
    headers: c.req.raw.headers,
  })
  return resp
})

app.get('*', serveStatic({ root: './public' }))

app.get('/do/:id', async (c) => {
  const id = c.req.param('id')
  const stub = c.env.MY_CONTAINER.get(c.env.MY_CONTAINER.idFromName(id))
  const resp = await stub.fetch(c.req.raw)
  return resp
})

export default {
  fetch: app.fetch,
}

// ✅ 👇 必须导出 Durable Object 实现，否则部署失败
export { MyContainer }
