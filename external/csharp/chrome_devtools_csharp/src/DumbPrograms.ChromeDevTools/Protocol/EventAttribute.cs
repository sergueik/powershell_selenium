using System;

namespace DumbPrograms.ChromeDevTools.Protocol
{
    /// <summary>
    /// Tags a type contains event data received from Chrome.
    /// </summary>
    [AttributeUsage(AttributeTargets.Class)]
    public class EventAttribute : Attribute
    {
        /// <summary>
        /// Name of the event.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// </summary>
        /// <param name="name">Name of the event.</param>
        public EventAttribute(string name)
        {
            Name = name;
        }
    }
}
