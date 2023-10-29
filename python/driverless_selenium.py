# origin: https://github.com/estromenko/driverless-selenium/blob/init-project/driverless_selenium/webdriver.py
import json
import os
import signal
import socket
import subprocess
import time
from pathlib import Path
from types import TracebackType
from typing import Any, Self

import cdp
import cdp.dom
import cdp.input_
import cdp.page
import cdp.runtime
import cdp.target
import requests
from cdp.runtime import ScriptId
from cdp.target import TargetID
from selenium.webdriver import ChromeOptions
from websockets.exceptions import WebSocketProtocolError
from websockets.sync.client import ClientConnection, connect


class Chrome:
    def __init__(self: Self, options: ChromeOptions | None = None) -> None:
        self.conn: ClientConnection
        self.options: ChromeOptions = options or ChromeOptions()
        self.target_id: str | None = None
        self.browser_pid: int | None = None
        self._debugger_address: str | None = None

    def __enter__(self: Self) -> Self:
        return self

    def __exit__(
        self: Self,
        typ: type[BaseException] | None,
        exc: BaseException | None,
        tb: TracebackType | None,
        extra_arg: int = 0,
    ) -> None:
        if self.browser_pid:
            self.conn.close()
            os.kill(self.browser_pid, signal.SIGTERM)

    def __del__(self: Self) -> None:
        if self.browser_pid:
            os.kill(self.browser_pid, signal.SIGTERM)

    @staticmethod
    def _get_random_available_port() -> int:
        sock = socket.socket()
        sock.bind(("", 0))
        return int(sock.getsockname()[1])

    _chrome_location_candidates = (
        "/usr/bin/chromium",
        "/usr/bin/chromium-browser",
        "/usr/local/bin/chromium-browser",
        "/usr/bin/google-chrome",
        "/usr/local/bin/google-chrome",
    )

    def _execute_command(self: Self, command: Any) -> dict[Any, Any]:  # noqa: ANN401
        """Execute provided command and receives its result."""
        request = next(command)
        request["id"] = 0
        self.conn.send(json.dumps(request))

        while result := json.loads(self.conn.recv()):
            if not result.get("method"):
                return dict(result)
        return {}

    def _find_browser_executable_name(self: Self) -> str:
        """Find the path to Chrome installed on the system."""
        for candidate in self._chrome_location_candidates:
            if Path(candidate).exists():
                return candidate
        error_message = "Chrome is not installed"
        raise FileExistsError(error_message)

    def _start_browser(self: Self) -> None:
        browser_executable_name = self._find_browser_executable_name()
        port = self._get_random_available_port()

        self.options.add_argument(f"--remote-debugging-port={port}")

        browser = subprocess.Popen(
            [browser_executable_name, *self.options.arguments],  # noqa: S603
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            close_fds=True,
        )
        self.browser_pid = browser.pid

        self._debugger_address = f"127.0.0.1:{port}"

    def _get_target_id(self: Self) -> str:
        response = requests.get(f"http://{self._debugger_address}/json", timeout=10)
        return str(response.json()[0]["id"])

    def _connect_to_session(self: Self) -> None:
        if not self._debugger_address:
            return

        exception: Exception | None = None
        for _ in range(3):
            try:
                self.target_id = self._get_target_id()
                self.conn = connect(f"ws://{self._debugger_address}/devtools/page/{self.target_id}")
                self._execute_command(cdp.target.activate_target(TargetID(self.target_id)))
            except (WebSocketProtocolError, requests.exceptions.ConnectionError) as exc:
                exception = exc
                time.sleep(2)
            else:
                return

        if exception:
            raise exception

    def get(self: Self, url: str) -> None:
        if not self.browser_pid:
            self._start_browser()
            self._connect_to_session()

        self._execute_command(cdp.page.enable())
        self._execute_command(cdp.page.set_ad_blocking_enabled(enabled=True))

        request = next(cdp.page.navigate(url))
        request["id"] = 0
        self.conn.send(json.dumps(request))

        while result := json.loads(self.conn.recv()):
            if result.get("method") == "Page.loadEventFired":
                return

    def get_html(self: Self, node_id: cdp.dom.NodeId) -> str:
        response = self._execute_command(cdp.dom.get_outer_html(node_id))
        return str(response["result"]["outerHTML"])

    def click(self: Self, node_id: cdp.dom.NodeId) -> None:
        command = cdp.dom.get_content_quads(node_id)
        result = self._execute_command(command)
        coordinates = result["result"]["quads"]

        x, y, _, _, _, _, _, _ = coordinates

        self._execute_command(
            cdp.input_.dispatch_mouse_event(
                "mousePressed", int(x), int(y), button="left", click_count=1,
            ),
        )
        self._execute_command(
            cdp.input_.dispatch_mouse_event(
                "mouseReleased", int(x), int(y), button="left", click_count=1,
            ),
        )

    def find_by_css(self: "Chrome", css_selector: str) -> list[cdp.dom.NodeId]:
        response = self._execute_command(cdp.dom.query_selector_all(self.node_id, css_selector))
        return [cdp.dom.NodeId(node_id) for node_id in response["result"]["nodeIds"]]

    def execute_script(self: Self, script: str) -> str:
        script = script.removeprefix("return ")
        self._execute_command(cdp.runtime.enable())
        script_id = ScriptId(
            self._execute_command(
                cdp.runtime.compile_script(script, self.get_current_url(), persist_script=True),
            )["result"]["scriptId"],
        )
        receive = self._execute_command(cdp.runtime.run_script(script_id))
        return str(receive["result"]["result"]["value"])

    @property
    def node_id(self: Self) -> cdp.dom.NodeId:
        return cdp.dom.NodeId.from_json(
            self._execute_command(cdp.dom.get_document())["result"]["root"]["nodeId"],
        )

    @property
    def page_source(self: Self) -> str:
        return str(
            self._execute_command(cdp.dom.get_outer_html(self.node_id))["result"]["outerHTML"],
        )

    def get_current_url(self: Self) -> str:
        """Возвращает url текущей страницы."""
        return str(self._execute_command(cdp.page.get_app_manifest())["result"]["url"])

