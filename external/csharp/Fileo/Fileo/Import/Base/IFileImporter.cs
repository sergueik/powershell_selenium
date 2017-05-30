using Fileo.Import.DataStructure.FileStructure;
using Fileo.Import.DataStructure.Table;

namespace Fileo.Import.Base
{
    internal interface IFileImporter
    {
        Table GetDataTable(ImportFile importFile, IImportFileStructure importFileStructure);
    }
}
