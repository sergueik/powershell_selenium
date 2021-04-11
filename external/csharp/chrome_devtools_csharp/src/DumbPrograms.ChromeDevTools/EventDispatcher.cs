using System;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace DumbPrograms.ChromeDevTools
{
    abstract class EventDispatcher
    {
        public abstract void Dispatch(JObject eventArgs);
    }

    class EventDispatcher<TEvent> : EventDispatcher
    {
        public event Func<TEvent, Task> Handlers;

        public override void Dispatch(JObject eventArgs)
        {
            Handlers?.Invoke(eventArgs == null ? default : eventArgs.ToObject<TEvent>());
        }
    }
}