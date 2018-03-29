using Fileo.Import.DataStructure.Table;
using Fileo.Tests.Base;
using System;
using System.Linq;

namespace Fileo.Tests.Imports.Test1
{
    internal class Test1Import
    {
        private readonly Table _fileDataInternal;

        public Test1Import(Table fileData)
        {
            _fileDataInternal = fileData;
            Validate();
        }

        public ImportResult<Test1ImportResult> Import()
        {
            var objects = _fileDataInternal.CorrectRows.Select(row => new Test1ImportResult
            {
                Col1String = row.GetStringValue(Test1Columns.Col1String, true),
                Col2StringNull = row.GetStringValue(Test1Columns.Col2StringNull, false),
                Col3Int = row.GetIntValue(Test1Columns.Col3Int),
                Col4IntNull = row.GetNullableIntValue(Test1Columns.Col4IntNull),
                Col5DateTime = row.GetDateValue(Test1Columns.Col5DateTime),
                Col6DateTimeNull = row.GetNullableDateValue(Test1Columns.Col6DateTimeNull),
                Col7Decimal = row.GetDecimalValue(Test1Columns.Col7Decimal),
                Col8DecimalNull = row.GetNullableDecimalValue(Test1Columns.Col8DecimalNull),
                Col9Bool = row.GetBoolValue(Test1Columns.Col9Bool),
                Col10BoolNull = row.GetNullableBoolValue(Test1Columns.Col10BoolNull),
                Col11Email = row.GetStringValue(Test1Columns.Col11Email, true),
                Col12CustomRegex = row.GetStringValue(Test1Columns.Col12CustomRegex, true)
            }).ToList();

            var result = new ImportResult<Test1ImportResult>(objects, _fileDataInternal.GetErrors());
            return result;
        }

        private void Validate()
        {
            if (_fileDataInternal == null)
            {
                throw new ArgumentNullException("fileData");
            }
        }
    }
}
