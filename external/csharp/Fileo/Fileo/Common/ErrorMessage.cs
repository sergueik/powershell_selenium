namespace Fileo.Common
{
	internal static class ErrorMessage
	{
		private const string Error = "Error in line {0}, column {1} ({2}):";
		public static string IncorrectFormat = "Importer. Incorrect file format. Correct formats: {0}";
		public static string ValueIsRequired = "{Error} Value is required.";
		// $"{Error} Value is required."
		public static string IncorrectXlsxFileFormat = "Incorrect file format. Expected file format: .xlsx";
		public static string IncorrectXlsFileFormat = "Incorrect file format. Expected file format: .xls";
		public static string IncorrectCsvFileFormat = "Incorrect file format. Expected file format: .csv";
		public static string UnexpectedError = "Unexpected error";
		public static string IncorrectImportFileStructureException = "Exactly one column must be set as identity.";
		public static string IncorrectImportFileStructureDateFormatsException = "DateFormats must be set in file structure!";
		public static string IncorrectImportFileStructureCultureInfosException = "CultureInfos must be set in file structure!";
		public static string IncorrectColumnNumberException = "Column number must be between <0, 256>";
		public static string IncorrectColumnNameException = "Incorrect column name.";
		public static string IncorrectValue = "{Error} Incorrect value.";
		// $"{Error} Incorrect value."
		private const string RangeValue = "('{3}'). Value has to be between {4} and {5}.";
		public static string IncorrectRangeValue = "{Error} Incorrect value {RangeValue}";
		// $"{Error} Incorrect value {RangeValue}";
		private const string RegexValue = "('{3}'). Does not meet the pattern '{4}'.";
		public static string IncorrectRegexValue = "{Error} Incorrect value {RegexValue}";
		// $"{Error} Incorrect value {RegexValue}";
		private const string MaxLength = "('{3}', length: {4}). Max lenght {5}.";
		public static string IncorrectStringLenght = "{Error} Incorrect value {MaxLength}";
		// $"{Error} Incorrect value {MaxLength}";
		private const string CannotConvert = "Cannot convert '{3}' to {4}.";
		public static string IncorrectValueToConvert = "{Error} {CannotConvert}";
		// $"{Error} {CannotConvert}";
		public static string IncorrectRow = "Incorrect row {0}.";
		public static string IncorrectAction = "[Importer] Incorrect action. In ImportFileStructure column '{0}' is type of '{1}', but you try get type '{2}'.";
		public static string RegexValueCannotBeNull = "Regex value cannot be null in RegexValidation.Custom mode";
	}
}
