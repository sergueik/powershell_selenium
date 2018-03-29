using Fileo.Common;
using Fileo.Import.DataStructure.FileStructure;
using Fileo.Import.DataStructure.Table;
using Fileo.Import.Exceptions;
using Fileo.Import.ImporterDefinition;
using System;
using System.Linq;

namespace Fileo.Import.Base
{
    internal class FileImporterFactory
    {
        private readonly ImportFile _importFile;
        private readonly IImportFileStructure _importFileStructure;

        #region Constructor

        public FileImporterFactory(ImportFile importFile, IImportFileStructure importFileStructure)
        {
            _importFile = importFile;
            _importFileStructure = importFileStructure;
            
            Validate();
        }

        #endregion Constructor

        #region Methods

        private void Validate()
        {
            if (_importFile == null)
            {
                throw new ArgumentNullException("_importFile");
            }

            if (_importFileStructure == null)
            {
                throw new ArgumentNullException("_importFileStructure");
            }

            const int maxIdentityColumn = 1;
            if (_importFileStructure.Columns.Count(x => x.IsIdentity) != maxIdentityColumn)
            {
                throw new IncorrectImportFileStructureException(ErrorMessage.IncorrectImportFileStructureException);
            }
        }

        public Table GetDataTable()
        {
            IFileImporter fileImporter;

            switch (_importFile.FileFormat)
            {
                case FileFormat.Xls:
                    fileImporter = new ImportFromXls();
                    break;
                case FileFormat.Xlsx:
                    fileImporter = new ImportFromXlsx();
                    break;
                case FileFormat.Csv:
                    fileImporter = new ImportFromCsv();
                    break;
                default:
                    return Table.CreateTableWithExceptionIncorrectFileFormat(FileFormat.Xls, FileFormat.Xlsx, FileFormat.Csv);
            }

            using (_importFile)
            {
                return fileImporter.GetDataTable(_importFile, _importFileStructure);
            }
        }

        #endregion Methods
    }
}
