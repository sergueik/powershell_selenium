using Fileo.Common;
using System;

namespace Fileo.Import.Exceptions
{
    internal class IncorrectColumnNumberException : ApplicationException
    {
        public override string Message { get { return ErrorMessage.IncorrectColumnNumberException; } }
    }
}
