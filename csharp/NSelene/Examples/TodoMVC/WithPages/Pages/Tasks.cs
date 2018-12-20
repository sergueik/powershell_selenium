using System;
using OpenQA.Selenium;
using NSelene;
// using static NSelene.Selene;

namespace NSeleneExamples.TodoMVC.WithPages.Pages {
    public static class Tasks {
        public static SeleneCollection List = Selene.SS("#todo-list>li");

        public static void Visit() {
            Selene.GoToUrl("https://todomvc4tasj.herokuapp.com/");
            Selene.WaitFor (Selene.GetWebDriver (), Have.JSReturnedTrue (
                "return " +
                "$._data($('#new-todo').get(0), 'events').hasOwnProperty('keyup')&& " +
                "$._data($('#toggle-all').get(0), 'events').hasOwnProperty('change') && " +
                "$._data($('#clear-completed').get(0), 'events').hasOwnProperty('click')"));
        }

        public static void FilterActive() {
            Selene.S(By.LinkText("Active")).Click();
        }

        public static void FilterCompleted() {
            Selene.S(By.LinkText("Completed")).Click();
        }

        public static void Add(params string[] taskTexts) {
            foreach (var text in taskTexts) {
                Selene.S("#new-todo").Should(Be.Enabled).SetValue(text).PressEnter();
            }
        }

        public static void Toggle(string taskText) {
            List.FindBy(Have.ExactText(taskText)).Find(".toggle").Click();
        }

        public static void ShouldBe(params string[] names) {
            List.FilterBy(Be.Visible).Should(Have.Texts(names));
        }
    }

}
