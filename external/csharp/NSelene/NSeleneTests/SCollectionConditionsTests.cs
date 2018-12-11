using NUnit.Framework;
using NSelene;
// using static NSelene.Selene;

namespace NSeleneTests
{
    [TestFixture]
    public class SCollectionConditionTests : BaseTest
    {

        [Test]
        public void SCollectionShouldHaveTextsAndExactTexts()
        { 
            Given.OpenedPageWithBody("<ul>Hello to:<li>Dear Bob</li><li>Lovely Kate</li></ul>");
            Selene.SS("li").ShouldNot(Have.Texts("Kate", "Bob"));
            Selene.SS("li").ShouldNot(Have.Texts("Bob"));
            Selene.SS("li").ShouldNot(Have.Texts("Bob", "Kate", "Joe"));
            Selene.SS("li").Should(Have.Texts("Bob", "Kate"));
            Selene.SS("li").ShouldNot(Have.ExactTexts("Bob", "Kate"));
            Selene.SS("li").ShouldNot(Have.ExactTexts("Lovely Kate", "Dear Bob"));
            Selene.SS("li").ShouldNot(Have.ExactTexts("Dear Bob"));
            Selene.SS("li").ShouldNot(Have.ExactTexts("Dear Bob", "Lovely Kate", "Funny Joe"));
            Selene.SS("li").Should(Have.ExactTexts("Dear Bob", "Lovely Kate"));
        }

        [Test]
        public void SCollectionShouldHaveCountAtLeastAndCount()
        {
            Given.OpenedEmptyPage();
            Selene.SS("li").ShouldNot(Have.Count(2));
            When.WithBody("<ul>Hello to:<li>Dear Bob</li><li>Lovely Kate</li></ul>");
            Selene.SS("li").ShouldNot(Have.CountAtLeast(3));
            Selene.SS("li").Should(Have.Count(2));
            Selene.SS("li").Should(Have.CountAtLeast(1));
        }

        [Test]
        public void SCollectionShouldBeEmpty()
        {
            Given.OpenedEmptyPage();
            Selene.SS("li").Should(Be.Empty);
            When.WithBody("<ul>Hello to:<li>Dear Bob</li><li>Lovely Kate</li></ul>");
            Selene.SS("li").ShouldNot(Be.Empty);
        }
    }
}

