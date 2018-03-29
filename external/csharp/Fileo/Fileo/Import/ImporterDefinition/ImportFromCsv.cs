using Fileo.Common;
using Fileo.Import.Base;
using Fileo.Import.DataStructure.FileStructure;
using Fileo.Import.DataStructure.Table;
using Microsoft.VisualBasic.FileIO;
using System;
using System.IO;
using System.Linq;

namespace Fileo.Import.ImporterDefinition
{
    internal class ImportFromCsv : IFileImporter
    {
        public Table GetDataTable(ImportFile importFile, IImportFileStructure importFileStructure)
        {
            var result = new Table();
            try
            {
                using (var csvReader = new TextFieldParser(importFile.FileStream))
                {
                    csvReader.SetDelimiters(importFileStructure.Delimeter);
                    csvReader.HasFieldsEnclosedInQuotes = true;
                    while (!csvReader.EndOfData)
                    {
                        var lineNumber = (int)csvReader.LineNumber;
                        if (lineNumber <= importFileStructure.SkipRowCount)
                        {
                            csvReader.ReadFields();
                            continue;
                        }
                        var row = csvReader.ReadFields() ?? new string[importFileStructure.Columns.Count];                        
                        
                        var cells = importFileStructure.Columns.Select(column => new Cell(column, lineNumber, row[column.ColumnIndexInFile])).ToList();
                        result.AddRow(new Row(lineNumber, cells));
                    }
                }
                return result;
            }
            catch (FileFormatException)
            {
                result.MarkAsInValid(ErrorMessage.IncorrectCsvFileFormat);
            }
            catch (Exception ex)
            {
                result.MarkAsInValid(ErrorMessage.UnexpectedError);
                Logs.Logger.Error(ex);
            }

            return result;
        }
    }
}
