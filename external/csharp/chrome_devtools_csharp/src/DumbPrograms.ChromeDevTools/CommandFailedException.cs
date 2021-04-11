using System;
using DumbPrograms.ChromeDevTools.Protocol;

namespace DumbPrograms.ChromeDevTools
{
    /// <summary>
    /// The invoked command returned a failure.
    /// </summary>
    [Serializable]
    public class CommandFailedException : Exception
    {
        /// <summary>
        /// The command that was failed.
        /// </summary>
        public ICommand Command { get; }

        /// <summary>
        /// </summary>
        public int ErrorCode { get; }

        internal CommandFailedException(ICommand command, int code, string message) : base(message)
        {
            Command = command;
            ErrorCode = code;
        }
    }
}
