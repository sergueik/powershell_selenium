namespace ShadowDriver
{

   public class ShadowDOMElement : JavaScriptBy
    {
        public ShadowDOMElement(string repeat, string binding)
            : base(ClientSideScripts.FindShadowDOMElements, repeat,  binding)
        {
        }
    }

}