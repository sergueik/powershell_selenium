using Fileo.Common;
using Fileo.Extensions;
using Fileo.Import.Exceptions;
using System;
using System.Globalization;
using System.Text.RegularExpressions;
using ValueType = Fileo.Common.ValueType;

namespace Fileo.Import.DataStructure.Table
{
    public class Column
    {
        public int ColumnIndexInFile { get; set; }
        public int ColumnIndexForErrors { get { return ColumnIndexInFile + 1; } }
        public string[] DateTimeFormats { get; set; }
        public CultureInfo[] CultureInfos { get; set; }

        public string ColumnName { get; private set; }
        public bool IsRequired { get; private set; }
        public bool IsIdentity { get; private set; }
        public ValueType ValueType { get; private set; }
        public int StringMaxLenght { get; private set; }

        public decimal MinValue { get; private set; }
        public decimal MaxValue { get; private set; }
        public RegexValidation RegexValidation { get; }
        private readonly string _regex;
        public Regex Regex { get; private set; }

        private const decimal MaxValuePrecision10_2 = 99999999.99M;
        private const decimal MinValuePrecision10_2 = -99999999.99M;

        #region Constructors

        private Column(string columnName, int columnIndexInFile, bool isRequired, bool isIdentity, ValueType valueType
            , int stringMaxLenght, string[] dateTimeFormats, CultureInfo[] cultureInfos, decimal minValue, decimal maxValue
            , RegexValidation regexValidation = RegexValidation.None, string regex = "")
        {
            RegexValidation = regexValidation;
            _regex = regex;
            ColumnName = columnName;
            ColumnIndexInFile = columnIndexInFile;
            IsRequired = isRequired;
            IsIdentity = isIdentity;
            ValueType = valueType;
            StringMaxLenght = stringMaxLenght;
            DateTimeFormats = dateTimeFormats;
            CultureInfos = cultureInfos;
            MinValue = minValue;
            MaxValue = maxValue;
            SetRegex();

            Validate();
        }

        public static Column CreateIdentityColumn(string columnName, int columnIndexInFile, int minValue = 0, int maxValue = int.MaxValue)
        {
            return new Column(columnName, columnIndexInFile, true, true, ValueType.Int, 0, null, null, minValue, maxValue);
        }

        public static Column CreateIdentityStringColumn(string columnName, int columnIndexInFile, int stringMaxLenght)
        {
            return new Column(columnName, columnIndexInFile, true, true, ValueType.String, stringMaxLenght, null, null, 0, 0);
        }

        public static Column CreateStringColumn(string columnName, int columnIndexInFile, bool isRequired, int stringMaxLenght, RegexValidation regexValidation = RegexValidation.None)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.String, stringMaxLenght, null, null, 0, 0, regexValidation);
        }

        public static Column CreateStringColumnWithCustomRegex(string columnName, int columnIndexInFile, bool isRequired, int stringMaxLenght, string regex)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.String, stringMaxLenght, null, null, 0, 0, RegexValidation.Custom, regex);
        }

        public static Column CreateIntColumn(string columnName, int columnIndexInFile, bool isRequired, int minValue = 0, int maxValue = int.MaxValue)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.Int, 0, null, null, minValue, maxValue);
        }

        public static Column CreateDecimalColumn(string columnName, int columnIndexInFile, bool isRequired, CultureInfo cultureInfo, decimal minValue = MinValuePrecision10_2, decimal maxValue = MaxValuePrecision10_2)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.Decimal, 0, null, new[] { cultureInfo }, minValue, maxValue);
        }

        public static Column CreateDecimalColumn(string columnName, int columnIndexInFile, bool isRequired, CultureInfo[] cultureInfos, decimal minValue = MinValuePrecision10_2, decimal maxValue = MaxValuePrecision10_2)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.Decimal, 0, null, cultureInfos, minValue, maxValue);
        }

        public static Column CreateDateTimeColumn(string columnName, int columnIndexInFile, bool isRequired, string[] dateTimeFormats)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.DateTime, 0, dateTimeFormats, null, 0, 0);
        }

        public static Column CreateBoolColumn(string columnName, int columnIndexInFile, bool isRequired)
        {
            return new Column(columnName, columnIndexInFile, isRequired, false, ValueType.Bool, 0, null, null, 0, 0);
        }

        #endregion Constructors

        #region Methods

        private void Validate()
        {
            const int minAvailableColumnIndex = 0;
            const int maxAvailableColumnIndex = 256;
            if (ColumnIndexInFile < minAvailableColumnIndex || ColumnIndexInFile > maxAvailableColumnIndex)
            {
                throw new IncorrectColumnNumberException();
            }
        }

        public string GetCellReference(int rowIndex)
        {
            return GetCellReference(ColumnIndexInFile, rowIndex);
        }

        public static string GetCellReference(int cellIndex, int rowIndex)
        {
            var dividend = cellIndex + 1;
            var columnName = string.Empty;

            while (dividend > 0)
            {
                var modulo = (dividend - 1) % 26;
                columnName = Convert.ToChar(65 + modulo).ToString().ToUpper() + columnName;
                dividend = (int)((dividend - modulo) / 26);
            }

            //  return $"{columnName}{rowIndex}";
            return String.Format("{0}{1}", columnName, rowIndex);
        }

        private void SetRegex()
        {
            if (RegexValidation == RegexValidation.None)
            {
                return;
            }

            switch (RegexValidation)
            {
                case RegexValidation.Email:
                    Regex = new Regex(RegexPattern.Email);
                    break;
                case RegexValidation.Custom:
                    if (!_regex.HasValue())
                    {
                        throw new IncorrectImportFileStructureException(ErrorMessage.RegexValueCannotBeNull);
                    }
                    Regex = new Regex(_regex);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        #endregion Methods
    }
}
