using System;
using System.IO;
using System.Xml.Linq;

namespace DumbPrograms.ChromeDevTools.Generator
{
    class InspectorClientApiGenerator : CodeGenerator
    {
        public void GenerateCode(TextWriter writer, ProtocolDescriptor protocol)
        {
            StartTextWriter(writer);

            WIL("using System;");
            WIL("using System.Threading;");
            WIL("using System.Threading.Tasks;");

            WL();

            using (WILBlock("namespace DumbPrograms.ChromeDevTools"))
            {
                const string InspectorClient = nameof(InspectorClient);

                using (WILBlock($"partial class {InspectorClient}"))
                {
                    foreach (var domain in protocol.Domains)
                    {
                        var fieldName = $"__{domain.Name}__";

                        WILSummary(domain.Description);

                        WILObsolete(domain.Deprecated);
                        WIL($"public {domain.Name}{InspectorClient} {domain.Name} => {fieldName} ?? ({fieldName} = new {domain.Name}{InspectorClient}(this));");

                        WILObsolete(domain.Deprecated);
                        WIL($"private {domain.Name}{InspectorClient} {fieldName};");
                    }

                    foreach (var domain in protocol.Domains)
                    {
                        WILSummary($"Inspector client for domain {domain.Name}.");

                        WILObsolete(domain.Deprecated);

                        using (WILBlock($"public class {domain.Name}{InspectorClient}"))
                        {
                            WIL($"private readonly {InspectorClient} {InspectorClient};");

                            WL();

                            using (WILBlock($"internal {domain.Name}{InspectorClient}({InspectorClient} inspectionClient)"))
                            {
                                WIL($"{InspectorClient} = inspectionClient;");
                            }

                            if (domain.Commands != null)
                            {
                                foreach (var command in domain.Commands)
                                {
                                    WILSummary(command.Description);

                                    if (command.Parameters != null)
                                    {
                                        foreach (var parameter in command.Parameters)
                                        {
                                            WILXmlDocElement(new XElement("param", new XAttribute("name", parameter.Name), parameter.Description));
                                        }
                                    }
                                    WILXmlDocElement(new XElement("param", new XAttribute("name", "cancellation")));

                                    WILObsolete(command.Deprecated);

                                    var commandName = GetCSharpIdentifier(command.Name);
                                    var commandType = $"Protocol.{domain.Name}.{commandName}Command";
                                    var commandResponseType = $"Protocol.{domain.Name}.{commandName}Response";
                                    var returnType = command.Returns == null ? "Task" : $"Task<{commandResponseType}>";

                                    WIL($"public {returnType} {commandName}");
                                    using (WILBlock(blockType: BlockType.Brace))
                                    {
                                        WILParameters(domain.Name, command.Parameters);
                                    }
                                    using (WILBlock())
                                    {
                                        using (WILBlock($"return {InspectorClient}.InvokeCommandCore", BlockType.Brace))
                                        {
                                            using (WILBlock($"new {commandType}"))
                                            {
                                                if (command.Parameters != null)
                                                {
                                                    foreach (var parameter in command.Parameters)
                                                    {
                                                        WIL($"{GetCSharpIdentifier(parameter.Name)} = @{parameter.Name},");
                                                    }
                                                }

                                            }
                                            WIL(", cancellation");
                                        }
                                        WIL($";");
                                    }
                                }
                            }

                            if (domain.Events != null)
                            {
                                foreach (var @event in domain.Events)
                                {
                                    var csEventName = GetCSharpIdentifier(@event.Name);

                                    WILSummary(@event.Description);
                                    WILObsolete(@event.Deprecated);

                                    using (WILBlock($"public event Func<Protocol.{domain.Name}.{csEventName}Event, Task> {csEventName}"))
                                    {
                                        WIL($"add => {InspectorClient}.AddEventHandlerCore(\"{domain.Name}.{@event.Name}\", value);");
                                        WIL($"remove => {InspectorClient}.RemoveEventHandlerCore(\"{domain.Name}.{@event.Name}\", value);");
                                    }
                                }

                                foreach (var @event in domain.Events)
                                {
                                    var csEventName = GetCSharpIdentifier(@event.Name);

                                    WILSummary(@event.Description);
                                    WILObsolete(@event.Deprecated);

                                    using (WILBlock($"public Task<Protocol.{domain.Name}.{csEventName}Event> {csEventName}Event(Func<Protocol.{domain.Name}.{csEventName}Event, Task<bool>> until = null)"))
                                    {
                                        WIL($"return {InspectorClient}.SubscribeUntilCore(\"{domain.Name}.{@event.Name}\", until);");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        private void WILParameters(string domain, PropertyDescriptor[] parameters)
        {
            if (parameters != null)
            {
                foreach (var parameter in parameters)
                {
                    string csType;
                    if (parameter.Type != null)
                    {
                        csType = GetCSharpType(parameter.Type.Value, parameter.Optional, parameter.ArrayType);

                        var typeRef = parameter.ArrayType?.TypeReference;
                        if (parameter.Type == JsonTypes.Array && typeRef != null)
                        {
                            csType = $"Protocol.{(typeRef.Contains(".") ? "" : $"{domain}.")}{csType}";
                        }
                    }
                    else if (parameter.TypeReference != null)
                    {
                        var typeRef = parameter.TypeReference;
                        csType = $"Protocol.{(typeRef.Contains(".") ? "" : $"{domain}.")}{typeRef}";
                    }
                    else
                    {
                        throw new NotImplementedException();
                    }

                    WIL($"{csType} @{parameter.Name}{(parameter.Optional ? " = default" : "")}, ");
                }
            }

            WIL("CancellationToken cancellation = default");
        }
    }
}
