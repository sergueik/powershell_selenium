using System.Collections.Generic;

namespace SeleniumParser.Models
{
	public class SeleniumSideModel
	{

		public string Id { get; set; }

		public string Version { get; set; }

		public string Name { get; set; }

		public string Url { get; set; }

		public IEnumerable<SeleniumTestModel> Tests { get; set; }

		public IEnumerable<SeleniumSuiteModel> Suites { get; set; }

		public IEnumerable<string> Urls { get; set; }

	}
}
