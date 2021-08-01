from aioselenium.command import Command


class SwitchTo(Command):

    def __init__(self, url):
        self.url = url

    async def frame(self, frame):  # Not tested
        payload = {
            'id': frame
        }
        return await self.command('POST', '/frame', json=payload)

    async def window(self, window):
        payload = {
            'handle': window
        }
        return await self.command('POST', '/window', json=payload)

    async def new_window(self):  # not tested
        pass

    async def command(self, method, endpoint, **kw):
        return await super().command(method, self.api+endpoint, **kw)

    async def close_window(self):
        return await self.command('DELETE', endpoint='/window')

