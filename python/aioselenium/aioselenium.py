# dependencies
import aiohttp

# Local imports
from aioselenium.command import Command
from aioselenium.element import Element
from aioselenium.switch_to import SwitchTo
from aioselenium.keys import Keys

# typing
from typing import (
    Dict, List, Optional, Union, Type
)


class Remote(Command):
    """ Selenium remote webdriver:
        Uses a basic implementation of
        the json wire protocol
        with asyncio.
        https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol
    """

    @classmethod
    async def create(cls,
                     command_executor: str,
                     desired_capabilities: Dict,
                     session: Type[aiohttp.ClientSession],
                     reconnect: Optional[Union[str, None]]=None):

        self = Remote()
        self.session = session
        self.command_executor = command_executor
        self.desired_capabilities = {
            'desiredCapabilities': desired_capabilities
        }

        # Create new session or reconnect to existing one
        if reconnect is None:
            async with self.session.post(self.command_executor+'/session', json=self.desired_capabilities) as resp:
                r = await resp.json()
            self.session_id = r['value'].get("sessionId") or r.get('sessionId')
        else:
            self.session_id = reconnect

        self.url = f'{self.command_executor}/session/{self.session_id}'
        self.switch_to = SwitchTo(self.url)
        return self

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        await self.quit()

    def __repr__(self) -> str:
        return f'Remote WebDriver (session={self.session_id}, title={self.get_title()})'

    async def command(self, method: str, endpoint: str, **kw) -> Dict:
        return await super().command(method, self.url+endpoint, self.session, **kw)

    async def get(self, url: str) -> Dict:
        payload = {
            'url': url
        }
        return await self.command('POST', endpoint='/url', json=payload)

    async def execute_script(self, script: str, args=[]) -> None:
        payload = {
            'script': script,
            'args': args
        }
        return await self.command('POST', endpoint='/execute/sync', json=payload)

    async def execute_script_async(self, script, args=[]):  # Not tested
        payload = {
            'script': script,
            'args': args
        }
        return await self.command('POST', endpoint='/execute/sync/async', json=payload)

    async def add_cookie(self, cookies):  # not tested
        payload = {
            'cookie': cookies
        }
        return await self.command('POST', endpoint='/cookie', json=payload)

    async def _find_elements(self, value: str, strategy: str, endpoint='/elements'):
        payload = {
            'using': strategy,
            'value': value,
        }
        element = await self.command('POST', endpoint=endpoint, json=payload)
        return [Element(ele, self.url, self.session) for ele in element]

    async def _find_element(self, value: str, strategy: str, endpoint='/element'):
        payload = {
            'using': strategy,
            'value': value,
        }
        element = await self.command('POST', endpoint=endpoint, json=payload)
        return Element(element, self.url, self.session)

    async def set_window_size(self, width, height):
        payload = {
            'width': width,
            'height': height
        }
        return await self.command('POST', endpoint='/window/rect', json=payload)

    async def current_url(self) -> str:
        return await self.command('GET', endpoint='/url')

    async def get_capabilities(self) -> Dict:
        return await self.command('GET', endpoint='')

    async def source(self) -> str:
        return await self.command('GET', endpoint='/source')

    async def get_title(self) -> str:
        return await self.command('GET', endpoint='/title')

    async def screenshot(self) -> str:
        return await self.command('GET', endpoint='/screenshot')

    async def find_element_by_id(self, value) -> Element:
        return await self._find_element(value=f'//*[@id="{value}"]', strategy='xpath', endpoint='/element')

    async def find_element_by_xpath(self, value) -> Element:
        return await self._find_element(value=value, strategy='xpath', endpoint='/element')

    async def find_element_by_name(self, value) -> Element:
        return await self._find_element(value=value, strategy='tag name', endpoint='/element')

    async def find_elements_by_id(self, value) -> Element:
        return await self._find_element(value=f'//*[@id="{value}"]', strategy='xpath', endpoint='/elements')

    async def find_elements_by_xpath(self, value) -> Element:
        return await self._find_elements(value=value, strategy='xpath', endpoint='/elements')

    async def find_elements_by_name(self, value) -> Element:
        return await self._find_elements(value=value, strategy='tag name', endpoint='/elements')

    async def get_window_size(self) -> Dict:
        return await self.command('GET', endpoint='/window/rect')

    async def quit(self) -> None:
        return await self.command('DELETE', endpoint='')

    async def get_cookies(self) -> Dict:
        return await self.command('GET', endpoint='/cookie')

    async def delete_cookies(self):
        return await self.command('DELETE', endpoint='/cookie') # not tested

    async def window_handles(self) -> List:
        return await self.command('GET', endpoint='/window/handles')

