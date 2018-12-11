using NUnit.Framework;
using NSelene;
// using static NSelene.Selene;

namespace NSeleneTests {
	[TestFixture]
	public class SElementConditionsTests : BaseTest{

		// TODO: TBD

		[Test]
		public void SElementShouldBeVisible() {
			Given.OpenedPageWithBody("<h1 style='display:none'>ku ku</h1>");
			Selene.S("h1").ShouldNot(Be.Visible);
			When.WithBody("<h1 style='display:block'>ku ku</h1>");
			var e = Selene.S("h1");
			e.Should(Be.Visible);
		}

		[Test]
		public void SElementShouldBeEnabled() {
			Given.OpenedPageWithBody("<input type='text' disabled/>");
			Selene.S("input").ShouldNot(Be.Enabled);
			When.WithBody("<input type='text'/>");
			Selene.S("input").Should(Be.Enabled);
		}

		[Test]
		public void SElementShouldBeInDOM() {
			Given.OpenedEmptyPage();
			Selene.S("h1").ShouldNot(Be.InDom);
			When.WithBody("<h1 style='display:none'>ku ku</h1>");
			Selene.S("h1").Should(Be.InDom);
		}

		[Test]
		public void SElementShouldHaveText() {
			Given.OpenedPageWithBody("<h1>Hello Babe!</h1>");
			Selene.S("h1").Should(Have.Text("Hello"));
			Selene.S("h1").ShouldNot(Have.Text("Hello world!"));
			Selene.S("h1").ShouldNot(Have.ExactText("Hello"));
			Selene.S("h1").Should(Have.ExactText("Hello Babe!"));
		}

		[Test]
		public void SElementShouldHaveCssClass() {
			Given.OpenedPageWithBody("<h1 class='big-title'>Hello Babe!</h1>");
			Selene.S("h1").ShouldNot(Have.CssClass("title"));
			When.WithBody("<h1 class='big title'>Hello world!</h1>");
			Selene.S("h1").Should(Have.CssClass("title"));
		}

		[Test]
		public void SElementShouldHaveAttribute() {
			Given.OpenedPageWithBody("<h1 class='big-title'>Hello Babe!</h1>");
			Selene.S("h1").ShouldNot(Have.Attribute("class", "big title"));
			When.WithBody("<h1 class='big title'>Hello world!</h1>");
			Selene.S("h1").Should(Have.Attribute("class", "big title"));
		}

		[Test]
		public void SElementShouldHaveValue() {
			Given.OpenedEmptyPage();
			Selene.S("input").ShouldNot(Have.Value("Yo"));
			When.WithBody("<input value='Yo'></input>");
			Selene.S("input").ShouldNot(Have.Value("o_O"));
			Selene.S("input").Should(Have.Value("Yo"));
		}

		[Test]
		public void SElementShouldBeBlank()
		{
			Given.OpenedEmptyPage();
			Selene.S("input").ShouldNot(Be.Blank); // TODO: sounds crazy, no? :)
			When.WithBody("<input type='text' value='Yo'/>");
			Selene.S("input").ShouldNot(Be.Blank);
			When.WithBody("<input type='text'/>");
			Selene.S("input").Should(Be.Blank);
		}

		// TODO: add tests for ShouldNot with non-existent element itself... what should the behaviour be? :)
	}
}

