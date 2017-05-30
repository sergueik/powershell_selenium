using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Fileo.Common;
using Fileo.Import.Base;
using Fileo.Import.DataStructure.FileStructure;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Fileo.Import.ImporterDefinition
{
    internal class ImportFromXlsx : IFileImporter
    {
        public DataStructure.Table.Table GetDataTable(ImportFile importFile, IImportFileStructure importFileStructure)
        {
            var result = new DataStructure.Table.Table();
            try
            {
                List<SharedStringItem> stringValues;
                IList<Row> rows;

                using (var document = SpreadsheetDocument.Open(importFile.FileStream, false))
                {
                    rows = GetRows(document, importFileStructure.SkipRowCount);
                    if (!rows.Any())
                    {
                        return result;
                    }

                    stringValues = document.WorkbookPart.SharedStringTablePart.SharedStringTable.Elements<SharedStringItem>().ToList();
                }

                foreach (var row in rows)
                {
                    var newRow = GetDataFromRow(stringValues, row, importFileStructure.Columns);
                    result.AddRow(newRow);
                }

                return result;
            }
            catch (FileFormatException)
            {
                result.MarkAsInValid(ErrorMessage.IncorrectXlsxFileFormat);   
            }
            catch (Exception ex)
            {
                result.MarkAsInValid(ErrorMessage.UnexpectedError);
                Logs.Logger.Error(ex);
            }

            return result;
        }

        #region Private methods 

        private DataStructure.Table.Row GetDataFromRow(IList<SharedStringItem> stringValues, Row row, IList<DataStructure.Table.Column> columnConfigurations)
        {
            if (row == null)
            {
                throw new ArgumentNullException(nameof(row));
            }

            if (stringValues == null)
            {
                throw new ArgumentNullException(nameof(stringValues));
            }

            var cells = row.Elements<Cell>().ToList();

            var newCells = new List<DataStructure.Table.Cell>();
            
            foreach (var columnConfiguration in columnConfigurations)
            {
                var rowIndex = Convert.ToInt32(row.RowIndex.ToString());
                var cellReference = columnConfiguration.GetCellReference(rowIndex);
                var cellFromFile = cells.FirstOrDefault(x => x.CellReference == cellReference);
                var newCell = GetDataFromCell(stringValues, cellFromFile, rowIndex, columnConfiguration);
                newCells.Add(newCell);
            }

            return new DataStructure.Table.Row(newCells);
        }

        private DataStructure.Table.Cell GetDataFromCell(IList<SharedStringItem> stringValues, Cell cell, int rowIndex, DataStructure.Table.Column columnConfiguration)
        {
            var cellValue = GetCellValue(stringValues, cell);

            return new DataStructure.Table.Cell(columnConfiguration, rowIndex, cellValue);
        }

        private string GetCellValue(IList<SharedStringItem> stringValues, Cell cell)
        {
            if (cell == null)
            {
                return string.Empty;
            }

            var cellValue = cell.CellValue != null ? cell.CellValue.Text : string.Empty;

            if (cell.DataType == null)
            {
                return cellValue;
            }
            if (cell.DataType == CellValues.SharedString)
            {
                var stringValue = GetSharedStringItemById(stringValues, Convert.ToInt32(cellValue));
                return stringValue?.Text?.Text ?? string.Empty;
            }
            if (cell.DataType == CellValues.InlineString)
            {
                return cell.InnerText;
            }

            return cellValue;
        }

        private SharedStringItem GetSharedStringItemById(IList<SharedStringItem> stringValues, int id)
        {
            return stringValues.ElementAt(id);
        }

        private IList<Row> GetRows(SpreadsheetDocument spreadsheetDocument, int skipRowCount)
        {
            if (spreadsheetDocument == null)
            {
                return new List<Row>();
            }

            var sheet = spreadsheetDocument.WorkbookPart.Workbook.GetFirstChild<Sheets>().Elements<Sheet>().FirstOrDefault();

            if (sheet == null)
            {
                return new List<Row>();
            }

            var worksheetPart = (WorksheetPart)spreadsheetDocument.WorkbookPart.GetPartById(sheet.Id.Value);
            var sheetData = worksheetPart.Worksheet.GetFirstChild<SheetData>();

            var rows = sheetData.Elements<Row>().ToList();
            return skipRowCount < rows.Count
                ? rows.Skip(skipRowCount).ToList() 
                : new List<Row>();
        }

        #endregion Private methods
    }
}