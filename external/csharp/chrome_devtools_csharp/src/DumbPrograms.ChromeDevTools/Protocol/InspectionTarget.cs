namespace DumbPrograms.ChromeDevTools.Protocol
{

#pragma warning disable CS1591 // Missing XML comment for publicly visible type or member

    public class InspectionTarget
    {
        public string Id { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public string DevtoolsFrontendUrl { get; set; }
        public string WebSocketDebuggerUrl { get; set; }
    }
}
