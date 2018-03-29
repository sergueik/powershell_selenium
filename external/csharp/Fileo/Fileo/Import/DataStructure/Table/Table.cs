using Fileo.Common;
using System.Collections.Generic;
using System.Linq;

namespace Fileo.Import.DataStructure.Table
{
    public class Table
    {
        public IList<Row> AllRows { get; }

        public IList<Row> CorrectRows { get; }

        public IList<Row> IncorrectRows { get; }

        #region Constructors

        public Table()
        {
            AllRows = new List<Row>();
            CorrectRows = new List<Row>();
            IncorrectRows = new List<Row>();
            IsValid = true;
        }

        public static Table CreateTableWithExceptionIncorrectFileFormat(params FileFormat[] correctFormats)
        {
            var table = new Table();
            table.MarkAsInValid(string.Format(ErrorMessage.IncorrectFormat, string.Join(", ", correctFormats)));
            return table;
        }

        #endregion Constructors

        #region Methods

        public void AddRow(Row row)
        {
            if (row == null)
            {
                return;
            }

            AllRows.Add(row);

            if (row.IsValid)
            {
                CorrectRows.Add(row);
                return;
            }

            IncorrectRows.Add(row);
        }

        public void SetAsIncorrect(Row row)
        {
            CorrectRows.Remove(row);
            IncorrectRows.Add(row);
        }

        public IList<string> GetErrors()
        {
            return IncorrectRows.SelectMany(x => x.Cells.Where(xx => !xx.IsValid).Select(xx => xx.Error)).ToList();
        }

        #endregion Methods

        #region Validation

        public bool IsValid { get; private set; }
        public string Error { get; private set; }

        public void MarkAsInValid(string errorMessage)
        {
            IsValid = false;
            Error = errorMessage;
        }

        #endregion Validation
    }
}
