import { Hono } from 'hono'
import { serveStatic } from 'hono/cloudflare-workers'
import { MyContainer } from './container'

export type Env = {
	MY_CONTAINER: DurableObjectNamespace
	KV: KVNamespace
}

const app = new Hono<{ Bindings: Env }>()

// ✅ Middleware：为 .php 设置 Content-Type = text/html
app.use('*', async (c, next) => {
	await next()
	const path = c.req.path
	if (path.endsWith('.php')) {
		c.header('Content-Type', 'text/html')
	}
})

// ✅ 静态首页重定向 / → /index.php
app.get('/', async (c) => {
	return serveStatic({ path: './index.php' })(c)
})

// ✅ 静态资源托管（包括 .php 文件）
app.get('*', serveStatic({ root: './public' }))

// ✅ Durable Object 测试路由（可选）
app.get('/do', async (c) => {
	const id = c.env.MY_CONTAINER.idFromName('a')
	const obj = c.env.MY_CONTAINER.get(id)
	const resp = await obj.fetch(c.req.raw)
	return resp
})

export default app

// ✅ 导出 Durable Object 实现
export { MyContainer }
