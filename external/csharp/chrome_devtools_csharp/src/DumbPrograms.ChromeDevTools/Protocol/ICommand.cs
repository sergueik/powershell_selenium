namespace DumbPrograms.ChromeDevTools.Protocol
{
    /// <summary>
    /// A command that instructs Chrome do something.
    /// </summary>
    public interface ICommand
    {
        /// <summary>
        /// The name of the command used to send in message.
        /// </summary>
        string Name { get; }
    }

    /// <summary>
    /// A command that instructs Chrome do something and gets some result back.
    /// </summary>
    /// <typeparam name="TResponse">The type represents the command result.</typeparam>
    public interface ICommand<TResponse> : ICommand
    {
    }
}
