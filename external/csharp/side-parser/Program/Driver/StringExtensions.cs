using System;

namespace SeleniumParser.Driver
{
	public static class StringExtensions
	{

		public static bool IsEquals(this string sender, string text)
		{
			return (string.Compare(sender, text, StringComparison.OrdinalIgnoreCase) == 0);
		}

		public static int ToInt(this string sender)
		{
			if (int.TryParse(sender, out int number))
				return number;
			return 0;
		}

		public static bool ContainsText(this string sender, string text)
		{
			return (sender?.IndexOf(text, StringComparison.OrdinalIgnoreCase) > -1);
		}

		public static bool StartsWithText(this string sender, string text)
		{
			return (!string.IsNullOrEmpty(text))
				&& (sender?.StartsWith(text, StringComparison.OrdinalIgnoreCase) == true);
		}

	}
}
