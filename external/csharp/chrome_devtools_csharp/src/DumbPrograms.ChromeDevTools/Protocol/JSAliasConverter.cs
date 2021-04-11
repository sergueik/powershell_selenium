using System;
using Newtonsoft.Json;

namespace DumbPrograms.ChromeDevTools.Protocol
{

#pragma warning disable CS1591 // Missing XML comment for publicly visible type or member

    public class JSAliasConverter<TAlias, TNative> : JsonConverter<JSAlias<TNative>> where TAlias : JSAlias<TNative>, new()
    {
        public override JSAlias<TNative> ReadJson(JsonReader reader, Type objectType, JSAlias<TNative> existingValue, bool hasExistingValue, JsonSerializer serializer)
        {
            return JSAlias<TNative>.New<TAlias>((TNative)reader.Value);
        }

        public override void WriteJson(JsonWriter writer, JSAlias<TNative> value, JsonSerializer serializer)
        {
            writer.WriteValue(value.Value);
        }
    }
}
