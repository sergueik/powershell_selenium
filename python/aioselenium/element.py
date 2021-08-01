from aioselenium.command import Command

class Element(Command):

    def __init__(self, element, url, session):
        self.element = list(element.values())[0]
        self.url = url
        self.api = f'{self.url}/element/{self.element}'
        self.session_id = self.url.split("/")[-1]
        self.session = session

    def __repr__(self):
        return f'AioRemoteWebDriver-Element (session="{self.session_id}", element="{self.element}")'

    async def action(self, endpoint):
        payload = {
            'id': self.element,
            'sessionId': self.session_id
        }
        return await self.command('POST', endpoint=endpoint, json=payload)

    async def send_keys(self, *keys):
        payload = {
            'text': ''.join(keys)
        }
        return await self.command('POST', endpoint='/value', json=payload)

    async def text(self):
        params = {
            'id': self.element,
            'sessionId': self.session_id
        }
        return await self.command('GET', endpoint='/text', params=params)

    async def command(self, method, endpoint, **kw):
        return await super().command(method, self.api+endpoint, self.session, **kw)

    async def click(self):
        return await self.action(endpoint='/click')

    async def clear(self):
        return await self.action(endpoint='/clear')

