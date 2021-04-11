using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.IO;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using DumbPrograms.ChromeDevTools.Protocol;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;

namespace DumbPrograms.ChromeDevTools
{
    /// <summary>
    /// The client to inspect <see cref="InspectionTarget"/>s.
    /// </summary>
    public partial class InspectorClient : IDisposable
    {
        private readonly string InspectionTargetUrl;
        private readonly ClientWebSocket WebSocket;
        private readonly JsonSerializerSettings JsonSerializerSettings;

        private int Started;
        private event Func<InspectionMessage, Task> MessageReceived;
        private ConcurrentDictionary<string, EventDispatcher> EventDispatchers;
        private CancellationTokenSource MessageLoopCanceller;

        private int CommandId = 0;

        /// <summary>
        /// Creates a client to inspect <paramref name="inspectionTarget"/>.
        /// </summary>
        /// <param name="inspectionTarget"></param>
        public InspectorClient(InspectionTarget inspectionTarget)
        {
            WebSocket = new ClientWebSocket();
            InspectionTargetUrl = inspectionTarget.WebSocketDebuggerUrl;
            JsonSerializerSettings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                ContractResolver = new CamelCasePropertyNamesContractResolver()
            };

            EventDispatchers = new ConcurrentDictionary<string, EventDispatcher>();
            MessageReceived += DispatchSubscribedEvents;
        }

        /// <summary>
        /// Connects to the server url defined within the inspection target.
        /// </summary>
        /// <param name="cancellation"></param>
        /// <returns>True when the connection is successful, otherwise false.</returns>
        public async Task<bool> Connect(CancellationToken cancellation = default)
        {
            if (Interlocked.CompareExchange(ref Started, 1, 0) == 0)
            {
                await WebSocket.ConnectAsync(new Uri(InspectionTargetUrl), cancellation)
                               .ConfigureAwait(false);

                MessageLoopCanceller = new CancellationTokenSource();
                _ = StartMessageLoop(MessageLoopCanceller.Token).ConfigureAwait(false);

                return true;
            }

            return false;
        }

        /// <summary>
        /// Disconnects to the server url defined within the inspection target.
        /// </summary>
        /// <param name="cancellation"></param>
        /// <returns>True when the disconnection was made, false when the client was already disconnected.</returns>
        public async Task<bool> Disconnect(CancellationToken cancellation = default)
        {
            if (Interlocked.CompareExchange(ref Started, 0, 1) == 1)
            {
                MessageLoopCanceller.Cancel();

                if (WebSocket.State == WebSocketState.Open || WebSocket.State == WebSocketState.CloseReceived)
                {
                    try
                    {
                        await WebSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "", cancellation)
                                       .ConfigureAwait(false);
                    }
                    catch (WebSocketException)
                    {
                        // Chrome just close the connection without completing the close handshake.
                    }
                }

                return true;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            MessageReceived = null;

            _ = Disconnect();

            MessageLoopCanceller.Dispose();
            WebSocket.Dispose();
        }

        /// <summary>
        /// Sends a message to the server indicating we are invoking a command.
        /// </summary>
        /// <typeparam name="TResponse">The type that wraps the expected info to return.</typeparam>
        /// <param name="command">The command to invoke.</param>
        /// <param name="cancellation"></param>
        /// <returns>The expected info represents by <typeparamref name="TResponse"/>.</returns>
        public async Task<TResponse> InvokeCommand<TResponse>(ICommand<TResponse> command, CancellationToken cancellation = default)
        {
            if (command == null)
            {
                throw new ArgumentNullException(nameof(command));
            }

            return await InvokeCommandCore(command, cancellation).ConfigureAwait(false);
        }

        /// <summary>
        /// Signals the client to fire an event to <paramref name="handler"/> when a specific message is received.
        /// </summary>
        /// <typeparam name="TEvent">The type that contains the event data.</typeparam>
        /// <param name="name">The name of the event.</param>
        /// <param name="handler">The action to perform when the message is received. It's async and does not block the browser.</param>
        public void AddEventHandler<TEvent>(string name, Func<TEvent, Task> handler)
        {
            if (String.IsNullOrWhiteSpace(name))
            {
                throw new ArgumentException("The name of the event must be specified.", nameof(name));
            }

            AddEventHandlerCore(name, handler);
        }

        /// <summary>
        /// Removes the handler to an event.
        /// </summary>
        /// <typeparam name="TEvent">The type that contains the event data.</typeparam>
        /// <param name="name">The name of the event.</param>
        /// <param name="handler">The action to perform when the message is received.</param>
        public void RemoveEventHandler<TEvent>(string name, Func<TEvent, Task> handler)
        {
            if (String.IsNullOrWhiteSpace(name))
            {
                throw new ArgumentException("The name of the event must be specified.", nameof(name));
            }

            RemoveEventHandlerCore(name, handler);
        }

        /// <summary>
        /// Listen for the messages of an event once, or <paramref name="until"/> the handler returns true.
        /// </summary>
        /// <typeparam name="TEvent">The type that contains the event data.</typeparam>
        /// <param name="name">The name of the event.</param>
        /// <param name="until">The action to perform when the message is received. It's async and does not block the browser.</param>
        /// <returns>The last event data received.</returns>
        public async Task<TEvent> SubscribeUntil<TEvent>(string name, Func<TEvent, Task<bool>> until = null)
        {
            if (String.IsNullOrWhiteSpace(name))
            {
                throw new ArgumentException("The name of the event must be specified.", nameof(name));
            }

            return await SubscribeUntilCore(name, until).ConfigureAwait(false);
        }

        private async Task StartMessageLoop(CancellationToken cancellation)
        {
            var buffer = new byte[1024];
            var stream = new MemoryStream();

            while (!cancellation.IsCancellationRequested)
            {
                if (stream.Length > 1024 * 4)
                {
                    stream = new MemoryStream();
                }
                else
                {
                    stream.SetLength(0);
                }

                while (true)
                {
                    WebSocketReceiveResult receive;
                    try
                    {
                        receive = await WebSocket.ReceiveAsync(new ArraySegment<byte>(buffer), cancellation).ConfigureAwait(false);
                    }
                    catch (WebSocketException)
                    {
                        goto exit;
                    }

                    if (receive.MessageType == WebSocketMessageType.Close)
                    {
                        goto exit;
                    }

                    Debug.Assert(receive.MessageType == WebSocketMessageType.Text);

                    stream.Write(buffer, 0, receive.Count);

                    if (receive.EndOfMessage)
                    {
                        stream.Position = 0;

                        var reader = new StreamReader(stream, Encoding.UTF8);
                        var messageText = reader.ReadToEnd();
                        var message = JsonConvert.DeserializeObject<InspectionMessage>(messageText);

                        MessageReceived?.Invoke(message);

                        break;
                    }
                }
            }

            exit:
            await Disconnect().ConfigureAwait(false);
        }

        private async Task<TResponse> InvokeCommandCore<TResponse>(ICommand<TResponse> command, CancellationToken cancellation)
        {
            if (WebSocket.State == WebSocketState.Open)
            {
                var id = Interlocked.Increment(ref CommandId);

                var frame = new InspectionMessage
                {
                    Id = id,
                    Method = command.Name,
                    Params = JObject.Parse(JsonConvert.SerializeObject(command, JsonSerializerSettings))
                };

                var frameText = JsonConvert.SerializeObject(frame, JsonSerializerSettings);
                var bytes = Encoding.UTF8.GetBytes(frameText);

                try
                {
                    var response = RegisterCommandResponseHandler<TResponse>(id, command, cancellation);

                    await WebSocket.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, endOfMessage: true, cancellation)
                                   .ConfigureAwait(false);

                    return await response.ConfigureAwait(false);
                }
                catch (WebSocketException)
                {
                }
            }

            await Disconnect().ConfigureAwait(false);

            throw new CommandFailedException(command, -1, "The inspector is disconnected.");
        }

        private Task<TResponse> RegisterCommandResponseHandler<TResponse>(int id, ICommand command, CancellationToken cancellation)
        {
            var tcs = new TaskCompletionSource<TResponse>();

            MessageReceived += CommandResponseHandler;

            return tcs.Task;

            Task CommandResponseHandler(InspectionMessage message)
            {
                if (message.Id != id)
                {
                    return Task.FromResult(false);
                }

                if (message.Result is JObject result)
                {
                    tcs.SetResult(result.ToObject<TResponse>());
                }
                else
                {
                    tcs.SetException(new CommandFailedException(command, message.Error.Code, message.Error.Message));
                }

                MessageReceived -= CommandResponseHandler;

                return Task.FromResult(true);
            }
        }

        private Task DispatchSubscribedEvents(InspectionMessage message)
        {
            EventDispatcher dispatcher = null;

            if (message.Method != null && EventDispatchers?.TryGetValue(message.Method, out dispatcher) == true)
            {
                Debug.Assert(dispatcher != null);

                dispatcher.Dispatch(message.Params);
            }

            return Task.FromResult(true);
        }

        private void AddEventHandlerCore<TEvent>(string name, Func<TEvent, Task> handler)
        {
            var dispatcher = GetEventDispatcher<TEvent>(name);
            dispatcher.Handlers += handler;
        }

        private void RemoveEventHandlerCore<TEvent>(string name, Func<TEvent, Task> handler)
        {
            var dispatcher = GetEventDispatcher<TEvent>(name);
            dispatcher.Handlers -= handler;
        }

        private Task<TEvent> SubscribeUntilCore<TEvent>(string name, Func<TEvent, Task<bool>> until)
        {
            var tcs = new TaskCompletionSource<TEvent>();

            var dispatcher = GetEventDispatcher<TEvent>(name);
            dispatcher.Handlers += UntilHandler;

            return tcs.Task;

            async Task UntilHandler(TEvent e)
            {
                if (until == null || await until(e).ConfigureAwait(false))
                {
                    dispatcher.Handlers -= UntilHandler;
                    tcs.SetResult(e);
                }
            }
        }

        private EventDispatcher<TEvent> GetEventDispatcher<TEvent>(string name)
            => (EventDispatcher<TEvent>)EventDispatchers.GetOrAdd(name, n => new EventDispatcher<TEvent>());

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return InspectionTargetUrl;
        }
    }
}