using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

namespace DumbPrograms.ChromeDevTools.Generator
{
    class Program
    {
        static void Main(string[] args)
        {
            var workingDir = Environment.CurrentDirectory;
            if (args?.Length > 0)
            {
                workingDir = Path.Combine(Environment.CurrentDirectory, args[0]);
            }

            var descriptors = new List<(string filename, ProtocolDescriptor protocol)>();

            Console.WriteLine($"Parsing json files..");

            var settings = new JsonSerializerSettings
            {
                MetadataPropertyHandling = MetadataPropertyHandling.Ignore
            };

            foreach (var path in Directory.EnumerateFiles(workingDir, "*.json"))
            {
                var filename = Path.GetFileNameWithoutExtension(path);
                var jsonText = File.ReadAllText(path);
                var protocol = JsonConvert.DeserializeObject<ProtocolDescriptor>(jsonText, settings);

                descriptors.Add((filename, protocol));
            }

            Console.WriteLine("Generating mapping types..");

            foreach (var (filename, protocol) in descriptors)
            {
                using (var writer = File.CreateText(Path.Combine(workingDir, filename + ".json.cs")))
                {
                    new MappingTypesGenerator().GenerateCode(writer, protocol);
                }
            }

            Console.WriteLine("Generating client APIs..");

            foreach (var (filename, protocol) in descriptors)
            {
                using (var writer = File.CreateText(Path.Combine(workingDir, filename + ".api.cs")))
                {
                    new InspectorClientApiGenerator().GenerateCode(writer, protocol);
                }
            }
        }
    }
}
