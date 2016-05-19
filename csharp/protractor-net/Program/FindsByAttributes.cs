// Decorated NgBy to serve in FindsBy annotations 
namespace Protractor
{
    public class NgByRepeater : JavaScriptBy
    {
        public NgByRepeater(string repeat)
            : base(ClientSideScripts.FindAllRepeaterRows, repeat)
        {
        }
    }

    public class NgByModel : JavaScriptBy
    {
        public NgByModel(string model)
            : base(ClientSideScripts.FindModel, model)
        {
        }
    }

    public class NgByBinding : JavaScriptBy
    {
        public NgByBinding(string binding)
            : base(ClientSideScripts.FindBindings, binding)
        {
        }
    }

    public class NgBySelectedOption : JavaScriptBy
    {
        public NgBySelectedOption(string model)
            : base(ClientSideScripts.FindSelectedOption, model)
        {
        }
    }

    public class NgBySelectedRepeaterOption : JavaScriptBy
    {
        public NgBySelectedRepeaterOption(string repeater)
            : base(ClientSideScripts.FindSelectedRepeaterOption, repeater)
        {
        }
    }

    public class NgByPartialButtonText : JavaScriptBy
    {
        public NgByPartialButtonText(string buttonText)
            : base(ClientSideScripts.FindByPartialButtonText, buttonText)
        {
        }
    }

    public class NgByButtonText : JavaScriptBy
    {
        public NgByButtonText(string buttonText)
            : base(ClientSideScripts.FindByButtonText, buttonText)
        {
        }
    }

    public class NgByOptions : JavaScriptBy
    {
        public NgByOptions(string option)
            : base(ClientSideScripts.FindByOptions, option)
        {
        }
    }

    public class NgByCssContainingText : JavaScriptBy
    {
        public NgByCssContainingText(string cssSelector, string searchText)
            : base(ClientSideScripts.FindByCssContainingText, cssSelector, searchText)
        {
        }
    }

    public class NgByRepeaterColumn : JavaScriptBy
    {
        public NgByRepeaterColumn(string repeat, string binding)
            : base(ClientSideScripts.FindRepeaterColumn, repeat, binding)
        {
        }
    }
}