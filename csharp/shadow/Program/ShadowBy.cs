using System;
using OpenQA.Selenium;

namespace ShadowDriver
{
    /// <summary>
    /// Mechanism used to locate elements within Shadow DOM - work in progress
    /// </summary>
    public static class ShadowBy
    {
        public static By ShadowDOMPath(string cssSelector, string searchText)
        {
            return new JavaScriptBy(ClientSideScripts.FindShadowDOMElements, searchText, cssSelector);
        }
   }
}