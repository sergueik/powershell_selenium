using Fileo.Common;
using Fileo.Extensions;
using Fileo.Import.Exceptions;
using System;
using System.Globalization;
using ValueType = Fileo.Common.ValueType;

namespace Fileo.Import.DataStructure.Table
{
    public class Cell
    {
        public Column Column { get; }
        public int RowIndex { get; }
        public string Value { get; }
        public bool IsValid { get; private set; }
        public string Error { get; private set; }

        private int _intValue;
        private string _stringValue;
        private decimal _decimalValue;
        private bool _boolValue;
        private DateTime _dateTimeValue;
        public bool HasValue { get; private set; }

        #region Constructors

        public Cell(Column column, int rowIndex, string value)
        {
            Column = column;
            RowIndex = rowIndex;
            Value = value;

            Validate();
        }

        #endregion Constructors

        #region Validations

        private void Validate()
        {
            IsValid = true;
            if (Column == null)
            {
                throw new ArgumentNullException("Column");
            }

            if (Column.IsRequired && !Value.HasValue())
            {
                Error = string.Format(ErrorMessage.ValueIsRequired, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName);
                IsValid = false;
                return;
            }

            switch (Column.ValueType)
            {
                case ValueType.String:
                    ValidateString();
                    break;
                case ValueType.Int:
                    ValidateInt();
                    break;
                case ValueType.Decimal:
                    ValidateDecimal();
                    break;
                case ValueType.DateTime:
                    ValidateDateTime();
                    break;
                case ValueType.Bool:
                    ValidateBool();
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private void ValidateBool()
        {
            if (!Value.HasValue())
            {
                return;
            }

            if (Value == "1" || Value.ToLower() == "true")
            {
                _boolValue = true;
                HasValue = true;
                return;
            }

            if (Value == "0" || Value.ToLower() == "false")
            {
                _boolValue = false;
                HasValue = true;
                return;
            }

            Error = string.Format(ErrorMessage.IncorrectValueToConvert, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, typeof(bool));
            IsValid = false;
        }

        private void ValidateDateTime()
        {
            if (!Value.HasValue())
            {
                return;
            }

            if (Column.DateTimeFormats.IsNullOrEmpty())
            {
                throw new IncorrectImportFileStructureException(ErrorMessage.IncorrectImportFileStructureDateFormatsException);
            }

            try
            {
                _dateTimeValue = DateTime.ParseExact(Value, Column.DateTimeFormats, CultureInfo.InvariantCulture, DateTimeStyles.None);
                HasValue = true;
            }
            catch (Exception ex)
            {
                Error = string.Format(ErrorMessage.IncorrectValueToConvert, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, typeof(DateTime));
                IsValid = false;
            }
        }

        private void ValidateDecimal()
        {
            if (!Value.HasValue())
            {
                return;
            }

            if (Column.CultureInfos.IsNullOrEmpty())
            {
                throw new IncorrectImportFileStructureException(ErrorMessage.IncorrectImportFileStructureCultureInfosException);
            }

            foreach (var cultureInfo in Column.CultureInfos)
            {
                HasValue = decimal.TryParse(Value, NumberStyles.Float, cultureInfo, out _decimalValue);

                if (HasValue)
                {
                    break;
                }
            }
            
            if (!HasValue)
            {
                HasValue = decimal.TryParse(Value, NumberStyles.Float, CultureInfo.InvariantCulture, out _decimalValue);
            }

            if (!HasValue)
            {
                Error = string.Format(ErrorMessage.IncorrectValueToConvert, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, typeof(decimal));
                IsValid = false;
                return;
            }

            if(_decimalValue >= Column.MinValue && _decimalValue <= Column.MaxValue)
            {
                return;
            }

            Error = string.Format(ErrorMessage.IncorrectRangeValue, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, Column.MinValue, Column.MaxValue);
            IsValid = false;
            HasValue = false;
        }

        private void ValidateInt()
        {
            if (!Value.HasValue())
            {
                return;
            }

            if (!int.TryParse(Value, out _intValue))
            {
                Error = string.Format(ErrorMessage.IncorrectValueToConvert, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, typeof(int));
                IsValid = false;
                return;
            }

            if (_intValue >= Column.MinValue && _intValue <= Column.MaxValue)
            {
                HasValue = true;
                return;
            }

            Error = string.Format(ErrorMessage.IncorrectRangeValue, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, (int)Column.MinValue, (int)Column.MaxValue);
            IsValid = false;
        }

        private void ValidateString()
        {
            if (!Value.HasValue())
            {
                return;
            }

            if(Value.Length > Column.StringMaxLenght)
            {
                Error = string.Format(ErrorMessage.IncorrectStringLenght, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, Value.Length, Column.StringMaxLenght);
                IsValid = false;
            }

            if(Column.RegexValidation != RegexValidation.None && !Column.Regex.IsMatch(Value))
            {
                Error = string.Format(ErrorMessage.IncorrectRegexValue, RowIndex, Column.ColumnIndexForErrors, Column.ColumnName, Value, Column.RegexValidation);
                IsValid = false;
                return;
            }

            _stringValue = Value;
            HasValue = true;
        }
        
        #endregion Validations
        
        #region Methods

        public string GetStringValue()
        {
            if(Column.ValueType != ValueType.String)
            {
                throw new IncorrectActionException(Column.ColumnName, Column.ValueType, ValueType.String);
            }

            return _stringValue;
        }

        public int GetIntValue()
        {
            if (Column.ValueType != ValueType.Int)
            {
                throw new IncorrectActionException(Column.ColumnName, Column.ValueType, ValueType.Int);
            }

            return _intValue;
        }

        public decimal GetDecimalValue()
        {
            if (Column.ValueType != ValueType.Decimal)
            {
                throw new IncorrectActionException(Column.ColumnName, Column.ValueType, ValueType.Decimal);
            }

            return _decimalValue;
        }

        public DateTime GetDateTimeValue()
        {
            if (Column.ValueType != ValueType.DateTime)
            {
                throw new IncorrectActionException(Column.ColumnName, Column.ValueType, ValueType.DateTime);
            }

            return _dateTimeValue;
        }

        public bool GetBoolValue()
        {
            if (Column.ValueType != ValueType.Bool)
            {
                throw new IncorrectActionException(Column.ColumnName, Column.ValueType, ValueType.Bool);
            }

            return _boolValue;
        }

        #endregion Methods
    }
}
