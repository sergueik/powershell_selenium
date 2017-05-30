using Fileo.Import.DataStructure.Table;
using Fileo.Tests.Base;
using System.Collections.Generic;
using System.Globalization;

namespace Fileo.Tests.Imports.Test1
{
    internal class Test1ImportFileStructure : ImportFileStructureBase
    {
        private readonly string[] _dateTimeFormats = { "dd/MM/yyyy"};
        private readonly CultureInfo _cultureInfo = new CultureInfo("en-GB");
        private const string CustomRegularExpression = @"^(Y|N)+$";

        public override IList<Column> Columns => new List<Column>
        {
            Column.CreateIdentityStringColumn(Test1Columns.Col1String, 0, 5),
            Column.CreateStringColumn(Test1Columns.Col2StringNull, 1, false, 5),
            Column.CreateIntColumn(Test1Columns.Col3Int, 2, true),
            Column.CreateIntColumn(Test1Columns.Col4IntNull, 3, false, -90, 90),
            Column.CreateDateTimeColumn(Test1Columns.Col5DateTime, 4, true, _dateTimeFormats),
            Column.CreateDateTimeColumn(Test1Columns.Col6DateTimeNull, 5, false, _dateTimeFormats),
            Column.CreateDecimalColumn(Test1Columns.Col7Decimal, 6, true, _cultureInfo, 0, 10),
            Column.CreateDecimalColumn(Test1Columns.Col8DecimalNull, 7, false, _cultureInfo, 0, 100),
            Column.CreateBoolColumn(Test1Columns.Col9Bool, 8, true),
            Column.CreateBoolColumn(Test1Columns.Col10BoolNull, 9, false),
            Column.CreateStringColumn(Test1Columns.Col11Email, 10, true, 100, RegexValidation.Email),
            Column.CreateStringColumnWithCustomRegex(Test1Columns.Col12CustomRegex, 11, true, 1, CustomRegularExpression),
        };
    }
}
