using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.Support.UI;
using Excel = Microsoft.Office.Interop.Excel;
using NUnit.Demo99.config;
using NUnit.Demo99.executionengine;
using RelevantCodes.ExtentReports;

namespace NUnit.Demo99.utility
{
	public class ExcelUtils
	{
		public static Excel.Application ExcelApp;
		public static Excel.Workbook ExcelWBook;
		private static Excel.Worksheet ExcelWSheet;

		//This method is to set the File path and to open the Excel file
		//Pass Excel Path and SheetName as Arguments to this method
		public static void setExcelFile(String path)
		{
			try {
				ExcelApp = new Excel.Application();
				ExcelApp.Visible = false;

				// Opening Excel file
				ExcelWBook = ExcelApp.Workbooks.Open(Constants.Path_TestData);
			} catch (Exception e) {
				Log._test.Log(LogStatus.Fail, "Class Utils | Method setExcelFile | Exception desc : " + e.Message);
				DriverScript.bResult = false;
			}
		}
		//This method is to read the test data from the Excel cell
		//In this we are passing parameters/arguments as Row Num and Col Num & Sheet Name
		public static string getCellData(int rowNum, int colNum, String sheetName)
		{
			Log.getTest();
			try {
				ExcelWSheet = ExcelWBook.Sheets[sheetName] as Excel.Worksheet;
				var cellValue = (ExcelWSheet.Cells[rowNum + 1, colNum + 1] as Excel.Range).Value as string;
				return cellValue;
			} catch (Exception) {
				return null;
			}
		}

		// This method is to get the row count used of the excel sheet
		public static int getRowCount(String sheetName)
		{
			int number = 0;
			try {
				ExcelWSheet = ExcelWBook.Sheets[sheetName] as Excel.Worksheet;
				number = ExcelWSheet.UsedRange.Rows.Count;
			} catch (Exception e) {
				Log._test.Log(LogStatus.Fail, "Class Utils | Method getRowCount | Exception desc : " + e.Message);
				DriverScript.bResult = false;
			}
			return number;
		}

		// This method is to get the Row number of the test case
		// This method takes three arguments (Test case name, Column Number & Sheet Name)
		public static int getRowContains(String testCaseName, int colNum, String sheetName)
		{
			int rowNum = 0;
			try {
				ExcelWSheet = ExcelWBook.Sheets[sheetName] as Excel.Worksheet;
				int rowCount = getRowCount(sheetName);

				for (; rowNum < rowCount; rowNum++) {
					if (getCellData(rowNum + 1, colNum, sheetName).Equals(testCaseName)) {
						rowNum++;
						break;
					}
				}
			} catch (Exception e) {
				Log._test.Log(LogStatus.Fail, "Class Utils | Method getRowContains | Exception desc : " + e.Message);
				DriverScript.bResult = false;
			}
			return rowNum;
		}

		// This method is to get the count of the test steps of test case
		// This method takes three arguments (Sheet name, Test Case Id & Test case row number)
		public static int getTestStepsCount(String sheetName, String testCaseID, int testCaseStart)
		{
			int number = 0;
			try {
				for (int i = testCaseStart; i <= ExcelUtils.getRowCount(sheetName); i++) {
					if (!testCaseID.Equals(ExcelUtils.getCellData(i, Constants.Col_TestCaseID, sheetName))) {
						number = i;
					}
				}
				ExcelWSheet = ExcelWBook.Sheets[sheetName] as Excel.Worksheet;
				number = ExcelWSheet.UsedRange.Rows.Count + 1;
			} catch (Exception e) {
				Log._test.Log(LogStatus.Fail, "Class Utils | Method getRowContains | Exception desc : " + e.Message);
				DriverScript.bResult = false;
				number = 0;
			}
			return number;
		}

		// This method is used to write value in excel cell
		// Four arguments are accepted (Result, Row Number, Column Number & Sheet Name)
		public static void setCellData(String Result, int rowNum, int colNum, String sheetName)
		{

			try {
				ExcelWSheet = ExcelWBook.Sheets[sheetName] as Excel.Worksheet;
				string vv = (ExcelWSheet.Cells[rowNum + 1, colNum + 1] as Excel.Range).Value as string;
				(ExcelWSheet.Cells[rowNum + 1, colNum + 1] as Excel.Range).Value = Result;
			} catch (Exception) {
				DriverScript.bResult = false;
			}

		}
	}
}
