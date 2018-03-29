using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data.OleDb;
using System.Globalization;
using System.IO;
using System.Text;

namespace Importer {
	#region EventArgs specification

	public enum DelimiterType {
		TabDelimited,
		CsvDelimited,
		CustomDelimited
	}

	public class ImportDelimitedEventArgs : EventArgs {
		private ReadOnlyCollection<object> _content;
		private int _lineNr;
		private bool _breakImport;

		public ImportDelimitedEventArgs(OleDbDataReader reader, int number) {
			object[] columns = new object[reader.FieldCount];
			reader.GetValues(columns);
			_content = new ReadOnlyCollection<object>(columns);
			_lineNr = number;
		}

		public bool BreakImport {
			get {
				return _breakImport;
			}
			set {
				_breakImport = value;
			}
		}

		public int LineNumber {
			get {
				return _lineNr;
			}
		}

		public ReadOnlyCollection<object> Content {
			get {
				return _content;
			}
		}
	}

	#endregion

	public class ImportDelimitedFile {
		#region Instance values
		private string _customDelimiter;
		private string _filter;
		private DelimiterType _delimiter = DelimiterType.TabDelimited;
		#endregion

		#region Event handler
		public event EventHandler<ImportDelimitedEventArgs> ProcessLine;
		private bool HandleLine(OleDbDataReader reader, int number)	{
			bool result = true;

			EventHandler<ImportDelimitedEventArgs> temp = ProcessLine;
			if (temp != null) {
				ImportDelimitedEventArgs args = new ImportDelimitedEventArgs(reader, number);
				temp(this, args);
				result = !args.BreakImport;
			}
			return result;
		}

		#endregion

		#region Constructors
		public ImportDelimitedFile()
			:
			this(DelimiterType.TabDelimited, null) {
		}

		public ImportDelimitedFile(DelimiterType delimiter)
			: this(delimiter, null) {
		}

		public ImportDelimitedFile(DelimiterType delimiterType, string delimiter) {
			_delimiter = delimiterType;
			_customDelimiter = delimiter;
		}

		#endregion

		#region Properties

		public Importer.DelimiterType Delimiter {
			get {
				return _delimiter;
			}
			set {
				_delimiter = value;
			}
		}

		public string CustomDelimiter {
			get {
				return _customDelimiter;
			}
			set {
				_customDelimiter = value;
			}
		}

		public string Filter {
			get {
				return _filter;
			}
			set {
				_filter = value;
			}
		}

		#endregion

		public void Import(string fileName) {
			int lineNumber = 0;
			FileInfo file = new FileInfo(fileName);
			WriteSchemaIniFile(file);

			using (OleDbConnection con = JetConnection(file)) {
				using (OleDbCommand cmd = JetCommand(file, con)) {
					con.Open();
					using (OleDbDataReader reader = cmd.ExecuteReader()) {
						while (reader.Read()) {
							lineNumber++;
							if (!HandleLine(reader, lineNumber)) {
								break;
							}
						}
					}
				}
			}
		}

		private OleDbConnection JetConnection(FileInfo file) {
			StringBuilder connection = new StringBuilder("Provider=Microsoft.Jet.OLEDB.4.0");
			connection.AppendFormat(";Data Source=\"{0}\"", file.DirectoryName);
			connection.Append(";Extended Properties='text;HDR=Yes");
			if (_delimiter == DelimiterType.CustomDelimited) {
				if (_customDelimiter == null) {
					throw new InvalidOperationException("Custom delimiter is not specified");
				}
				connection.AppendFormat(";FMT=Delimited({1})", _customDelimiter);
			}
			connection.Append("';");
			return new OleDbConnection(connection.ToString());
		}

		private OleDbCommand JetCommand(FileInfo file, OleDbConnection con) {
			StringBuilder commandText = new StringBuilder("SELECT * FROM ");
			commandText.AppendFormat("[{0}]", file.Name);
			if (_filter != null) {
				commandText.Append(" WHERE ");
				commandText.Append(_filter);
			}
			OleDbCommand cmd = new OleDbCommand(commandText.ToString(), con);
			cmd.CommandTimeout = 60000;
			return cmd;
		}

		private void WriteSchemaIniFile(FileInfo file) {
			string schema = Path.Combine(file.DirectoryName, "Schema.ini");

			if (!File.Exists(schema)) {
				using (StreamWriter writer = new StreamWriter(schema)) {
					writer.WriteLine(string.Format(CultureInfo.InvariantCulture, "[{0}]", file.Name));
					switch (_delimiter) {
						case DelimiterType.CustomDelimited:
							writer.WriteLine(string.Format(CultureInfo.InvariantCulture, "Format=Delimited({0})", _customDelimiter));
							break;
						case DelimiterType.CsvDelimited:
						case DelimiterType.TabDelimited:
						default:
							writer.WriteLine(string.Format(CultureInfo.InvariantCulture, "Format={0}", _delimiter));
							break;
					}
				}
			}
		}

	}
}
