using NUnit.Framework;
using NSelene;
// using static NSelene.Selene;

namespace NSeleneTests
{
	[TestFixture]
	public class SElementXPathTextCssTest : BaseTest
	{
		[Test]
		public void SElementAlternativeCssSearch()
		{

			Given.OpenedPageWithBody("<h1 name='hello'>Hello Babe!</h1>");
			Selene.S("css = h1[name='hello']").Should(Have.Attribute("name", "hello"));
			Selene.S("h1:nth-of-type(1)").Should(Have.Text("Hello"));		
			// TODO:  
			// Selene.S("unknown=h1:nth-of-type(1)").Should(Have.Text("Hello"));		
		}

	
		[Test]
		public void SElementXpathSearch()
		{
			Given.OpenedPageWithBody("<h1>Hello Babe!</h1>");
			Selene.S("xpath = //h1").ShouldNot(Have.Text("Hello world!"));
			Selene.S("xpath = /h1[1]").ShouldNot(Have.Text("Hello world!"));

		}
		[Test]
		public void SElementTextSearch()
		{
			Given.OpenedPageWithBody("<h1>Hello Babe!</h1>");
			Selene.S("text = Hello").ShouldNot(Have.ExactText("Hello"));
			Selene.S("text = world!").ShouldNot(Have.ExactText("Hello"));
		}
	}
}