using Fileo.Common;
using System;
using ValueType = Fileo.Common.ValueType;

namespace Fileo.Import.Exceptions
{
    internal class IncorrectActionException : ApplicationException
    {
        private readonly string _columnName;
        private readonly ValueType _columnValueType;
        private readonly ValueType _tryToGetValueType;

        public IncorrectActionException(string columnName, ValueType columnValueType, ValueType tryToGetValueType)
        {
            _columnName = columnName;
            _columnValueType = columnValueType;
            _tryToGetValueType = tryToGetValueType;
        }

        public override string Message { get { return String.Format(ErrorMessage.IncorrectAction, _columnName, _columnValueType, _tryToGetValueType); } }
    }
}
