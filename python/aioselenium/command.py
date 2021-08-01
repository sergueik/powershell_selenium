class Command():
    """ Send requests using the JSON
        Wire Protocol and return the value
    """

    async def command(self, method: str, url: str, session, **kw):
        async with session.request(method, url, **kw) as resp:
            response = await resp.json()
            return response.get('value')

