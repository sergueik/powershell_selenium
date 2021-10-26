using System.Collections.Generic;

namespace SeleniumParser.Models
{
	public class SeleniumTestModel
	{

		public string Id { get; set; }

		public string Name { get; set; }

		public IEnumerable<SeleniumCommandModel> Commands { get; set; }

	}
}