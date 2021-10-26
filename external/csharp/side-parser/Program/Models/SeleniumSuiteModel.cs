using System.Collections.Generic;

namespace SeleniumParser.Models
{
	public class SeleniumSuiteModel
	{

		public string Id { get; set; }

		public string Name { get; set; }

		public bool PersistSession { get; set; }

		public bool Parallel { get; set; }

		public int Timeout { get; set; }

		public IEnumerable<string> Tests { get; set; }

	}
}