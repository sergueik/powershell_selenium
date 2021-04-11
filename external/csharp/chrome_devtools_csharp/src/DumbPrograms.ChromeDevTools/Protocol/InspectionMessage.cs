using Newtonsoft.Json.Linq;

namespace DumbPrograms.ChromeDevTools.Protocol
{
    class InspectionMessage
    {
        public int? Id { get; set; }
        public string Method { get; set; }
        public JObject Params { get; set; }
        public JObject Result { get; set; }
        public ErrorDescription Error { get; set; }
    }
}
