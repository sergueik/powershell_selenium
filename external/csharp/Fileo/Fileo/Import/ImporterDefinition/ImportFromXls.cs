using Fileo.Common;
using Fileo.Import.Base;
using Fileo.Import.DataStructure.FileStructure;
using Fileo.Import.DataStructure.Table;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Fileo.Import.ImporterDefinition
{
    internal class ImportFromXls : IFileImporter
    {
        private IFormulaEvaluator _formulaEvaluator;
        private DataFormatter _dataFormatter;


        public Table GetDataTable(ImportFile importFile, IImportFileStructure importFileStructure)
        {
            var result = new Table();
            try
            {
                HSSFWorkbook workbook;
                using (var stream = importFile.FileStream)
                {
                    workbook = new HSSFWorkbook(stream);
                }
                
                _formulaEvaluator = new HSSFFormulaEvaluator(workbook);
                _dataFormatter = new HSSFDataFormatter();

                var rows = GetRows(workbook, importFileStructure);
                if (!rows.Any())
                {
                    return result;
                }

                foreach (var row in rows)
                {
                    result.AddRow(row);
                }

                return result;
            }
            catch (FileFormatException)
            {
                result.MarkAsInValid(ErrorMessage.IncorrectXlsFileFormat);
            }
            catch (Exception ex)
            {
                result.MarkAsInValid(ErrorMessage.UnexpectedError);
                Logs.Logger.Error(ex);
            }

            return result;
        }

        #region Private methods

        private IList<Row> GetRows(HSSFWorkbook workbook, IImportFileStructure importFileStructure)
        {
            if (workbook == null || workbook.NumberOfSheets == 0)
            {
                return new List<Row>();
            }

            var sheet = workbook.GetSheetAt(0);
            var rows = new List<Row>();
            var rowIndex = importFileStructure.SkipRowCount;

            for (; rowIndex <= sheet.LastRowNum; rowIndex++)
            {
                var row = sheet.GetRow(rowIndex);
                if (row == null)
                {
                    continue;
                }
                var newRow = GetDataFromRow(row, importFileStructure.Columns);
                rows.Add(newRow);
            }

            return rows;
        }

        private Row GetDataFromRow(IRow row, IList<Column> columnConfigurations)
        {
            if (row == null)
            {
                throw new ArgumentNullException(nameof(row));
            }

            var newCells = new List<Cell>();
            const int adjustRowNumber = 1;
            var rowIndex = row.RowNum + adjustRowNumber;

            foreach (var columnConfiguration in columnConfigurations)
            {
                var cellFromFile = row.GetCell(columnConfiguration.ColumnIndexInFile);
                var newCell = GetDataFromCell(cellFromFile, rowIndex, columnConfiguration);
                newCells.Add(newCell);
            }

            return new Row(rowIndex, newCells);
        }

        private Cell GetDataFromCell(ICell cell, int rowIndex, Column columnConfiguration)
        {
            var cellValue = GetCellValue(cell);
            return new Cell(columnConfiguration, rowIndex, cellValue);
        }

        private string GetCellValue(ICell cell)
        {
            if (cell == null)
            {
                return string.Empty;
            }

            var value = _dataFormatter.FormatCellValue(cell, _formulaEvaluator);
            return value.Replace(Environment.NewLine, string.Empty);
        }

        #endregion Private methods
    }
}
