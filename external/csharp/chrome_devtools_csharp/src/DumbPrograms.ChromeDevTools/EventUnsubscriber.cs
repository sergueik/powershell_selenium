using System;
using System.Threading;
using System.Threading.Tasks;

namespace DumbPrograms.ChromeDevTools
{
    class EventUnsubscriber<TEvent> : IDisposable
    {
        private EventDispatcher<TEvent> Dispatcher;
        private Func<TEvent, Task> Handler;

        public EventUnsubscriber(EventDispatcher<TEvent> dispatcher, Func<TEvent, Task> handler)
        {
            Dispatcher = dispatcher;
            Handler = handler;
        }

        public void Dispose()
        {
            if (Interlocked.CompareExchange(ref Handler, null, Handler) is Func<TEvent, Task> handler)
            {
                Dispatcher.Handlers -= handler;

                Interlocked.Exchange(ref Dispatcher, null);
            }
        }
    }
}