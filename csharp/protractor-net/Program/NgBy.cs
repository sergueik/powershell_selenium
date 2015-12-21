using System;
using OpenQA.Selenium;

namespace Protractor
{
    public static class NgBy
    {
        /// <summary>
        ///
        /// </summary>    	
        public static By Binding(string binding, bool exactMatch = true)
        {
            return new JavaScriptBy(ClientSideScripts.FindBindings, binding, null, exactMatch);
        }

        /// <summary>
        ///
        /// </summary>    	
        [Obsolete("Use Model instead.")]
        public static By Input(string model)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model);
        }

        /// <summary>
        ///
        /// </summary>    	
        public static By Model(string model)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model);
        }

        /// <summary>
        ///
        /// </summary>    	
        [Obsolete("Use Model instead.")]
        public static By TextArea(string model)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model);
        }

        /// <summary>
        ///
        /// </summary>    	
        [Obsolete("Use Model instead.")]
        public static By Select(string model)
        {
            return new JavaScriptBy(ClientSideScripts.FindModel, model);
        }

        
        /// <summary>
        ///
        /// </summary>    	
        public static By RepeaterColumn(string repeat, string binding)
        {
            return new JavaScriptBy(ClientSideScripts.FindRepeaterColumn, repeat, binding);
        }


        /// <summary>
        ///
        /// </summary>    	
        public static By Repeater(string repeat)
        {
            return new JavaScriptBy(ClientSideScripts.FindAllRepeaterRows, repeat);
        }

        /// <summary>
        ///
        /// </summary>    	
        public static By ButtonText(string repeat)
        {
            return new JavaScriptBy(ClientSideScripts.FindByButtonText, repeat);
        }

        /// <summary>
        ///
        /// </summary>    	
        public static By PartialButtonText(string repeat)
        {
            return new JavaScriptBy(ClientSideScripts.FindByPartialButtonText, repeat);
        }

        /// <summary>
        ///
        /// </summary>    	
        public static By Options(string option)
        {
            return new JavaScriptBy(ClientSideScripts.FindByOptions, option);
        }

        /// <summary>
        ///
        /// </summary>    	
        public static By SelectedOption(string model)
        {
            return new JavaScriptBy(ClientSideScripts.FindSelectedOption , model);
        }

    }
}
