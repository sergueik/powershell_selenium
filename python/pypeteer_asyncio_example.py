#!/usr/bin/env python3

# based on: https://github.com/pyppeteer/pyppeteer
# see also: https://qna.habr.com/q/776989
import getopt
import sys
import re
from os import getenv
import asyncio
from pyppeteer import launch

async def text(url = 'https://www.avito.ru/belgorod/nastolnye_kompyutery/sistemnyy_blok_1885815175') -> str:
  browser = await launch()
  page = await browser.newPage()
  await page.goto(url)
  print('+1')
  # await page.screenshot({'path': 'example.png'})
  await browser.close()


async def main():
  tasks = [] 

  for x in range(3): # fork 3 tasks
    task = asyncio.create_task(text())
    tasks.append(task)

  await asyncio.gather(*tasks)

asyncio.run(main())
