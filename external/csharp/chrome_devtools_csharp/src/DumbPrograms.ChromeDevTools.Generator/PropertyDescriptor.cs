using System.Text;
using Newtonsoft.Json;

namespace DumbPrograms.ChromeDevTools.Generator
{
    public class PropertyDescriptor
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public bool Optional { get; set; }
        public JsonTypes? Type { get; set; }
        [JsonProperty("enum")]
        public string[] EnumValues { get; set; }
        [JsonProperty("$ref")]
        public string TypeReference { get; set; }
        [JsonProperty("items")]
        public PropertyDescriptor ArrayType { get; set; }

        public override string ToString()
        {
            var sb = new StringBuilder(Name);

            if (Optional)
            {
                sb.Append('?');
            }

            return sb.ToString();
        }
    }
}