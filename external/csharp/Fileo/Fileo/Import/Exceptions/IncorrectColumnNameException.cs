using Fileo.Common;
using System;

namespace Fileo.Import.Exceptions
{
    internal class IncorrectColumnNameException : ApplicationException
    {
        public override string Message { get { return ErrorMessage.IncorrectColumnNameException; } }
    }
}
