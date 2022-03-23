﻿using System;
using OpenQA.Selenium;

namespace Protractor
{
    /// <summary>
    /// Mechanism used to locate elements within Angular applications by binding, model, repeater, options etc.
    /// </summary>
    public static class NgBy
    {
        /// <summary>
        /// Gets a mechanism to find elements by their Angular binding.
        /// </summary>
        /// <param name="binding">The binding, e.g. '{{cat.name}}'.</param>
        /// /// <param name="exactMatch">exact match</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By Binding(string binding, bool exactMatch = true, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindBindings, binding, rootSelector, exactMatch);
        }

        /// <summary>
        /// Gets a mechanism to find input elements by their model name.
        /// </summary>
        /// <param name="model">The model name.</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        [Obsolete("Use Model instead.")]
        public static By Input(string model, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model, rootSelector);
        }

        /// <summary>
        /// Gets a mechanism to find elements by their model name.
        /// </summary>
        /// <param name="model">The model name.</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By Model(string model, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model, rootSelector);
        }

        /// <summary>
        /// Gets a mechanism to find textarea elements by their model name.
        /// </summary>
        /// <param name="model">The model name.</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        [Obsolete("Use Model instead.")]
        public static By TextArea(string model, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model, rootSelector);
        }

        /// <summary>
        /// Gets a mechanism to find select elements by their model name.
        /// </summary>
        /// <param name="model">The model name.</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        [Obsolete("Use Model instead.")]
        public static By Select(string model, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model, rootSelector);
        }


        /// <summary>
        /// Gets a mechanism to find all rows of an ng-repeat.
        /// </summary>
        /// <param name="repeat">The text of the repeater, e.g. 'cat in cats'.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By Repeater(string repeat)
        {
            return new JavaScriptBy(ClientSideScripts.FindAllRepeaterRows, repeat);
        }

        /// <summary>
        /// Gets a mechanism to find  the elements in a column of an ng-repeat.
        /// </summary>
        /// <param name="repeat">The text of the repeater, e.g. 'cat in cats'.</param>
        /// <param name="binding">The text of the repeater, e.g. '{{cat.name}}'.</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By RepeaterColumn(string repeat, string binding, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindRepeaterColumn, repeat, binding, rootSelector);
        }

        /// <summary>
        /// Gets a mechanism to find  the elements in a column of an ng-repeat.
        /// </summary>
        /// <param name="repeat">The partial text of the repeater, e.g. 'cat in cats'.</param>
        /// <param name="index">The row index.</param>
        /// <param name="binding">The text of the repeater, e.g. '{{cat.name}}'.</param>
        /// <param name="rootSelector"> Optional selector of the ng-app element, default is 'body', often used values: '[ng-app]','[data-ng-app]'</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By Repeaterelement(string repeat, int index, string binding, string rootSelector = null)
        {
            return new JavaScriptBy(ClientSideScripts.FindRepeaterElement, repeat, index, binding, rootSelector);
        }

        /// <summary>
        /// Gets a mechanism to find buttons by textual content.
        /// </summary>
        /// <param name="buttonText">TThe exact text to match.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By ButtonText(string buttonText)
        {
            return new JavaScriptBy(ClientSideScripts.FindByButtonText, buttonText);
        }

        /// <summary>
        /// Gets a mechanism to find buttons by textual content.
        /// </summary>
        /// <param name="buttonText">The partial text to match.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By PartialButtonText(string buttonText)
        {
            return new JavaScriptBy(ClientSideScripts.FindByPartialButtonText, buttonText);
        }

        /// <summary>
        /// Gets a mechanism to find select option elements by their model name.
        /// </summary>
        /// <param name="option">The descriptor for the option e.g. fruit for fruit in fruits.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By Options(string option)
        {
            return new JavaScriptBy(ClientSideScripts.FindByOptions, option);
        }

        /// <summary>
        /// Gets a mechanism to find selected option elements in the select element
        /// implemented via repeater without a model, by the repeater attribute.
        /// </summary>
        /// <param name="repeater">The repeater attribute.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By SelectedRepeaterOption(string repeater)
        {
            return new JavaScriptBy(ClientSideScripts.FindSelectedRepeaterOption, repeater);
        }

        /// <summary>
        /// Gets a mechanism to find select option elements by their model name.
        /// </summary>
        /// <param name="model">The model name.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By SelectedOption(string model)
        {
            return new JavaScriptBy(ClientSideScripts.FindSelectedOption, model);
        }

        /// <summary>
        /// Gets a mechanism to find select option elements by their model name.
        /// </summary>
        /// <param name="cssSelector">The css selector to match.</param>
        /// <param name="searchText">The exact text to match.</param>
        /// <returns>A <see cref="By"/> object the driver can use to find the elements.</returns>
        public static By CssContainingText(string cssSelector, string searchText)
        {
            return new JavaScriptBy(ClientSideScripts.FindByCssContainingText, searchText, cssSelector);
        }
    }
}