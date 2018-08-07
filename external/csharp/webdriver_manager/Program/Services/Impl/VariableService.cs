using System;
using System.IO;

namespace WebDriverManager.Services.Impl
{
    public class VariableService : IVariableService
    {
        public void SetupVariable(string path)
        {
            UpdatePath(path);
        }

        protected void UpdatePath(string path)
        {
            const string name = "PATH";
            var pathVariable = Environment.GetEnvironmentVariable(name, EnvironmentVariableTarget.Process);
            if (pathVariable == null) throw new ArgumentNullException(String.Format("Can't get {0} variable", name));
            path = Path.GetDirectoryName(path);
            var newPathVariable = String.Format("{0};{1}", path , pathVariable);
            if (path != null && !pathVariable.Contains(path))
                Environment.SetEnvironmentVariable(name, newPathVariable, EnvironmentVariableTarget.Process);
        }
    }
}