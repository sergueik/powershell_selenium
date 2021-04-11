using System;
using System.Net.Http;
using System.Threading.Tasks;
using DumbPrograms.ChromeDevTools.Protocol;
using Newtonsoft.Json;

namespace DumbPrograms.ChromeDevTools
{
    /// <summary>
    /// The entry point to query info from the DevTools protocol.
    /// </summary>
    public class DevToolsClient
    {
        readonly HttpClient HttpClient;

        /// <summary>
        /// Creates a client to query DevTools info from the browser.
        /// </summary>
        /// <param name="port">The debugging port opens by the browser.</param>
        public DevToolsClient(int port)
        {
            HttpClient = new HttpClient
            {
                BaseAddress = new Uri($"http://localhost:{port}/json/")
            };
        }

        /// <summary>
        /// Gets the information about the browser.
        /// </summary>
        /// <returns></returns>
        public Task<BrowserVersion> GetBrowserVersion() => Get<BrowserVersion>("version");

        /// <summary>
        /// Gets the inspectable targets from the browser.
        /// </summary>
        /// <returns></returns>
        public Task<InspectionTarget[]> GetInspectableTargets() => Get<InspectionTarget[]>("list");

        /// <summary>
        /// Opens a new tab on the browser.
        /// </summary>
        /// <param name="url">The url of the new tab.</param>
        /// <returns>The <see cref="InspectionTarget"/> of the new tab.</returns>
        public Task<InspectionTarget> NewTab(string url) => Get<InspectionTarget>($"new?{Uri.EscapeDataString(url)}");

        /// <summary>
        /// Activates a tab of the browser.
        /// </summary>
        /// <param name="id">The id of the tab to activate.</param>
        /// <returns></returns>
        public Task<string> ActivateTab(string id) => HttpClient.GetStringAsync($"activate/{Uri.EscapeUriString(id)}");

        /// <summary>
        /// Closes a tab of the browser.
        /// </summary>
        /// <param name="id">The id of the tab to close.</param>
        /// <returns></returns>
        public Task<string> CloseTab(string id) => HttpClient.GetStringAsync($"close/{Uri.EscapeUriString(id)}");

        private async Task<T> Get<T>(string url) => JsonConvert.DeserializeObject<T>(await HttpClient.GetStringAsync(url));

        /// <summary>
        /// Creates an <see cref="InspectorClient"/> to inspect the <paramref name="target"/>.
        /// </summary>
        /// <param name="target">The target to inspect.</param>
        /// <returns>The inspector.</returns>
        public async Task<InspectorClient> Inspect(InspectionTarget target)
        {
            var client = new InspectorClient(target);

            await client.Connect();

            return client;
        }
    }
}
