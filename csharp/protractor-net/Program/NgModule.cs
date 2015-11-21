namespace Protractor
{
    public class NgModule
    {
        public string Name { get; protected set; }

        public string Script { get; protected set; }

        public NgModule(string name, string script)
        {
            this.Name = name;
            this.Script = script;
        }
    }
}
