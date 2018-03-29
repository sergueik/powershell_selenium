using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Fileo.Tests
{
    [TestClass]
    public class FileCsvTests : BaseTest
    {
        public override string FilePath => @"Files\Examples\Test1FileCsv.csv";
        public override string ContentType => "text/csv";
        public override string FileName => "Test1FileCsv.csv";
    }
}
