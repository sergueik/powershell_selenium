using NUnit.Framework;
// using static NSelene.Selene;
using OpenQA.Selenium.Chrome;
using NSelene;

namespace NSeleneExamples
{
    [TestFixture()]
    public class BaseTest
    {
        [SetUp]
        public void SetupTest()
        {
            Selene.SetWebDriver(new ChromeDriver());
            Configuration.Timeout = 6;
        }

        [TearDown]
        public void TeardownTest()
        {
            Selene.GetWebDriver().Quit();
        }
    }
}
