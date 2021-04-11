using Newtonsoft.Json;

namespace DumbPrograms.ChromeDevTools.Protocol
{

#pragma warning disable CS1591 // Missing XML comment for publicly visible type or member

    public class BrowserVersion
    {
        [JsonProperty("Browser")]
        public string Browser { get; set; }
        [JsonProperty("Protocol-Version")]
        public string ProtocolVersion { get; set; }
        [JsonProperty("User-Agent")]
        public string UserAgent { get; set; }
        [JsonProperty("V8-Version")]
        public string V8Version { get; set; }
        [JsonProperty("WebKit-Version")]
        public string WebKitVersion { get; set; }
        [JsonProperty("webSocketDebuggerUrl")]
        public string WebSocketDebuggerUrl { get; set; }
    }
}
