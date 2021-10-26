using System;

namespace SeleniumParser.Driver
{
	public static class CommandFactory
	{

		public static ICommand Create(Context context, string command)
		{
			var commandType = "SeleniumParser.Commands." + command + "Command";
			if (!(typeof(CommandFactory).Assembly.CreateInstance(commandType, ignoreCase: true) is Command instance))
				throw new NotImplementedException(command);
			instance.Current = context;
			return instance;
		}

	}
}
