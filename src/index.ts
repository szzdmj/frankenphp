import { Hono } from 'hono'
import { handle } from '@cloudflare/containers'
import { serveStatic } from 'hono/cloudflare-workers'
import { MyContainer } from './container'

export type Env = {
  MY_CONTAINER: DurableObjectNamespace
  KV: KVNamespace
}

const app = new Hono<{ Bindings: Env }>()

// 所有 .php 请求 → 代理到容器
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

// 根路径 `/` 显式代理到 index.php
app.get('/', async (c) => {
  const url = 'https://hello-containers.xianyue5165.workers.dev/index.php'
  const resp = await fetch(url, {
    headers: c.req.raw.headers,
  })
  return resp
})

// 静态资源（如 robots.txt, .css, .js 等）
app.get('*', serveStatic({ root: './public' }))

// Durable Object 路由（仍保留）
app.get('/do/:id', async (c) => {
  const id = c.req.param('id')
  const stub = c.env.MY_CONTAINER.get(c.env.MY_CONTAINER.idFromName(id))
  const resp = await stub.fetch(c.req.raw)
  return resp
})

// 处理容器请求（默认由 Containers 模块提供）
export default {
  fetch: app.fetch,
  ...handle({
    MyContainer,
  }),
}
