using System;
using NSelene;
// using static NSelene.Selene;
using NUnit.Framework;

namespace NSeleneTests
{
    [TestFixture]
    public class SElementActionsTests : BaseTest
    {
        //TODO: consider not using shoulds here...

        //TODO: check "waiting InDom/Visible" aspects 

        [Test]
        public void SElementClear()
        {
            Given.OpenedPageWithBody("<input type='text' value='ku ku'/>");
            Selene.S("input").Clear().Should(Be.Blank);
        }

        [Test]
        public void SElementGetAttribute()
        {
            Given.OpenedPageWithBody("<input type='text' value='ku ku'/>");
            Assert.AreEqual("text", Selene.S("input").GetAttribute("type"));
        }

        [Test]
        public void SElementGetValue()
        {
            Given.OpenedPageWithBody("<input type='text' value='ku ku'/>");
            Assert.AreEqual("ku ku", Selene.S("input").Value);
        }

        [Test]
        public void SElementGetCssValue()
        {
            Given.OpenedPageWithBody("<input type='text' value='ku ku' style='display:none'/>");
            Assert.AreEqual("none", Selene.S("input").GetCssValue("display"));
        }

        [Test]
        public void SElementIsDisplayed()
        {
            Given.OpenedPageWithBody("<input type='text' value='ku ku' style='display:none'/>");
            Assert.AreEqual(false, Selene.S("input").Displayed);
        }

        [Test]
        public void SElementIsEnabled()
        {
            Given.OpenedPageWithBody("<input type='text' value='ku ku'/>");
            Assert.AreEqual(true, Selene.S("input").Enabled);
        }

        // TODO: TBD
    }

}

