using Fileo.Common;
using Fileo.Import.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Fileo.Import.DataStructure.Table
{
    public class Row
    {
        public int RowIndex { get; private set; }
        public Cell Identifier { get; }
        public IList<Cell> Cells { get; }

        public bool IsValid 
        {
            get
            {
                return Cells != null && Cells.All(x => x.IsValid);
            }
        }

        #region Constructors

        public Row(int rowIndex, IList<Cell> cell) : this(cell)
        {
            this.RowIndex = rowIndex;
        }

        public Row(IList<Cell> cells)
        {
            Cells = cells;
            Validate();
            Identifier = Cells.Single(x => x.Column.IsIdentity);
        }

        #endregion Constructors

        #region Methods

        public string GetStringValue(string column, bool isRequired)
        {
            var cell = GetCell(column, isRequired);
            if (cell == null || !cell.HasValue)
            {
                return string.Empty;
            }

            return cell.GetStringValue();
        }

        public string GetStringValue(string column)
        {
            var cell = GetCell(column);
            if (cell == null || !cell.HasValue)
            {
                return string.Empty;
            }

            return cell.GetStringValue();
        }

        public bool? GetNullableBoolValue(string column)
        {
            var cell = GetCell(column);
            if (cell == null || !cell.HasValue)
            {
                return null;
            }

            return cell.GetBoolValue();
        }

        public int? GetNullableIntValue(string column)
        {
            var cell = GetCell(column);
            if (cell == null || !cell.HasValue)
            {
                return null;
            }

            return cell.GetIntValue();
        }

        public decimal? GetNullableDecimalValue(string column)
        {
            var cell = GetCell(column);
            if (cell == null || !cell.HasValue)
            {
                return null;
            }

            return cell.GetDecimalValue();
        }

        public DateTime? GetNullableDateValue(string column)
        {
            var cell = GetCell(column);
            if (cell == null || !cell.HasValue)
            {
                return null;
            }
            return cell.GetDateTimeValue();
        }

        public bool GetBoolValue(string column)
        {
            var cell = GetCell(column, true);
            return cell.GetBoolValue();
        }

        public int GetIntValue(string column)
        {
            var cell = GetCell(column, true);
            return cell.GetIntValue();
        }

        public decimal GetDecimalValue(string column)
        {
            var cell = GetCell(column, true);
            return cell.GetDecimalValue();
        }

        public DateTime GetDateValue(string column)
        {
            var cell = GetCell(column, true);
            return cell.GetDateTimeValue();
        }

        public int GetColumnIndexForErrors(string column)
        {
            var cell = GetCell(column, true);
            return cell.Column.ColumnIndexForErrors;
        }

        private void Validate()
        {
            if (Cells == null)
            {
                throw new ArgumentException("cells");
            }

            const int maxCountOfIdentityColumns = 1;
            if (Cells.Count(x => x.Column.IsIdentity) != maxCountOfIdentityColumns)
            {
                throw new IncorrectImportFileStructureException(ErrorMessage.IncorrectImportFileStructureException);
            }
        }

        private Cell GetCell(string column, bool? isRequired = null)
        {
            if (!IsValid)
            {
                if (isRequired.HasValue && isRequired.Value)
                {
                    throw new IncorrectRowException(Identifier.RowIndex);
                }
                return null;
            }

            var cell = Cells.FirstOrDefault(x => x.Column.ColumnName == column);
            if (cell == null)
            {
                throw new IncorrectColumnNameException();
            }

            if ((isRequired ?? cell.Column.IsRequired) && !cell.HasValue)
            {
                throw new IncorrectValueException(cell.RowIndex, cell.Column.ColumnIndexForErrors, cell.Column.ColumnName);
            }

            return cell;
        }

        #endregion Methods
    }
}
