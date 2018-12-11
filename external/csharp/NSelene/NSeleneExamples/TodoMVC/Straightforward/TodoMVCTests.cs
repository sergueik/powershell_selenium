using NUnit.Framework;
// using static NSelene.Selene;
using NSelene;
using OpenQA.Selenium;
using NSelene.Support.Extensions;

namespace NSeleneExamples.TodoMVC.StraightForward
{
    [TestFixture]
    public class TestTodoMVC : BaseTest
    {
        [Test]
        public void FilterTasks()
        {
            Selene.Open("https://todomvc4tasj.herokuapp.com/");

            Selene.WaitTo(Have.JSReturnedTrue (
                "return " +
                "$._data($('#new-todo').get(0), 'events').hasOwnProperty('keyup')&& " +
                "$._data($('#toggle-all').get(0), 'events').hasOwnProperty('change') && " +
                "$._data($('#clear-completed').get(0), 'events').hasOwnProperty('click')"));

            Selene.S("#new-todo").SetValue("a").PressEnter();
            Selene.S("#new-todo").SetValue("b").PressEnter();
            Selene.S("#new-todo").SetValue("c").PressEnter();
            Selene.SS("#todo-list>li").Should(Have.ExactTexts("a", "b", "c"));

            Selene.SS("#todo-list>li").FindBy(Have.ExactText("b")).Find(".toggle").Click();

            Selene.S(By.LinkText("Active")).Click();
            Selene.SS("#todo-list>li").FilterBy(Be.Visible).Should(Have.ExactTexts("a", "c"));

            Selene.S(By.LinkText("Completed")).Click();
            Selene.SS("#todo-list>li").FilterBy(Be.Visible).Should(Have.ExactTexts("b"));
        }
    }
}
