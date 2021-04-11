using Newtonsoft.Json;

namespace DumbPrograms.ChromeDevTools.Generator
{
    public class DomainDescriptor
    {
        [JsonProperty("domain")]
        public string Name { get; set; }
        public string Description { get; set; }
        public string[] Dependencies { get; set; }
        public bool Experimental { get; set; }
        public bool Deprecated { get; set; }
        public TypeDescriptor[] Types { get; set; }
        public CommandDescriptor[] Commands { get; set; }
        public CommandDescriptor[] Events { get; set; }

        public override string ToString()
        {
            return $"{Name}{(Experimental ? " (experimental)" : "")}";
        }
    }
}