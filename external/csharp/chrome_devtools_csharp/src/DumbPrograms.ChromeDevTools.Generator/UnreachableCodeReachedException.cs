using System;
using System.Runtime.Serialization;

namespace DumbPrograms.ChromeDevTools.Generator
{
    [Serializable]
    internal class UnreachableCodeReachedException : Exception
    {
        public UnreachableCodeReachedException()
        {
        }

        public UnreachableCodeReachedException(string message) : base(message)
        {
        }

        public UnreachableCodeReachedException(string message, Exception innerException) : base(message, innerException)
        {
        }

        protected UnreachableCodeReachedException(SerializationInfo info, StreamingContext context) : base(info, context)
        {
        }
    }
}