using Fileo.Import.DataStructure.Table;
using System.Collections.Generic;

namespace Fileo.Import.DataStructure.FileStructure
{
    public interface IImportFileStructure
    {
        int SkipRowCount { get; }
        IList<Column> Columns { get; }
        string Delimeter { get; }
    }
}
