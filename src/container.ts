async fetch(request: Request): Promise<Response> {
	const url = new URL(request.url);
	const id = this.env.MY_CONTAINER.idFromName("default");
	const container = await this.env.frankenphp.get(id, {
		fetch: {
			forward: {
				port: 8080
			}
		}
	});
	return container.fetch(request);
}
