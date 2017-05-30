using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Fileo.Tests
{
    [TestClass]
    public class FileXlsTests : BaseTest
    {
        public override string FilePath => @"Files\Examples\Test1FileXls.xls";
        public override string ContentType => "application/vnd.ms-exce";
        public override string FileName => "Test1FileXls.xls";
    }
}
