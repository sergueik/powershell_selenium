using Fileo.Import.DataStructure.FileStructure;
using Fileo.Import.DataStructure.Table;
using System.Collections.Generic;

namespace Fileo.Tests.Base
{
    internal abstract class ImportFileStructureBase : IImportFileStructure
    {
        public abstract IList<Column> Columns { get; }

        public virtual string Delimeter { get { return ";"; } }

        public virtual int SkipRowCount { get { return 1; } }
    }
}
