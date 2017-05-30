using System;

namespace Fileo.Tests.Imports.Test1
{
    public class Test1ImportResult
    {
        public string Col1String { get; set; }
        public string Col2StringNull { get; set; }
        public int Col3Int { get; set; }
        public int? Col4IntNull { get; set; }
        public DateTime Col5DateTime { get; set; }
        public DateTime? Col6DateTimeNull { get; set; }
        public decimal Col7Decimal { get; set; }
        public decimal? Col8DecimalNull { get; set; }
        public bool Col9Bool { get; set; }
        public bool? Col10BoolNull { get; set; }
        public string Col11Email { get; set; }
        public string Col12CustomRegex { get; set; }
    }
}
