using System.Collections.Generic;

namespace SeleniumParser.Models
{
	public class SeleniumCommandModel
	{

		public string Id { get; set; }

		public string Comment { get; set; }

		public string Command { get; set; }

		public string Target { get; set; }

		public IEnumerable<string[]> Targets { get; set; }

		public string Value { get; set; }

	}
}