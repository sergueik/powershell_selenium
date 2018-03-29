using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Fileo.Tests
{
    [TestClass]
    public class FileXlsxTests : BaseTest
    {
        public override string FilePath => @"Files\Examples\Test1FileXlsx.xlsx";
        public override string ContentType => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet ";
        public override string FileName => "Test1FileXlsx.xlsx";
    }
}
