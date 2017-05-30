using Fileo.Helpers;
using Fileo.Tests.Base;
using Fileo.Tests.Imports.Test1;
using System.Web;

namespace Fileo.Tests.Imports
{
    public static class Imports
    {
        public static ImportResult<Test1ImportResult> ImportTest1(HttpPostedFileBase httpPostedFileBase)
        {
            var fileData = ImporterHelper.ImportFromFile(httpPostedFileBase, new Test1ImportFileStructure());
            var venuesImport = new Test1Import(fileData);
            return venuesImport.Import();
        }
    }
}
