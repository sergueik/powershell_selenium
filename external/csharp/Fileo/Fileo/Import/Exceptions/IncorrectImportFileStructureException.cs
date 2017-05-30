using System;

namespace Fileo.Import.Exceptions
{
    internal class IncorrectImportFileStructureException : ApplicationException
    {
        private readonly string _message;

        public IncorrectImportFileStructureException(string message)
        {
            _message = message;
        }

        public override string Message { get { return _message; } }
    }
}
