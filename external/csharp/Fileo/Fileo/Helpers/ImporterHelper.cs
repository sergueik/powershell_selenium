using Fileo.Import.Base;
using Fileo.Import.DataStructure.FileStructure;
using Fileo.Import.DataStructure.Table;
using System.Web;

namespace Fileo.Helpers
{
    public static class ImporterHelper
    {
        public static Table ImportFromFile(HttpPostedFileBase httpPostedFileBase, IImportFileStructure importFileStructure)
        {
            var file = new ImportFile(httpPostedFileBase);
            var fileImporterFactory = new FileImporterFactory(file, importFileStructure);
            return fileImporterFactory.GetDataTable();
        }
    }
}
