using NUnit.Framework;
using OpenQA.Selenium.Chrome;
// using static NSelene.Selene;
using NSelene;

namespace NSeleneTests
{

    [TestFixture]
    public class BaseTest {
//         [OneTimeSetUp]
        [SetUp]
        public void initDriver() {
            Selene.SetWebDriver(new ChromeDriver());
        }

        // [OneTimeTearDown]
        [TearDown]
        public void disposeDriver(){
            Selene.GetWebDriver().Quit();
        }
    }
}
