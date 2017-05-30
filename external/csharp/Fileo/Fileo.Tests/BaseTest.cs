using Fileo.Tests.Files;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;
using System.Linq;

namespace Fileo.Tests
{
    [TestClass]
    public abstract class BaseTest
    {
        public abstract string FilePath { get; }
        public abstract string ContentType { get; }
        public abstract string FileName { get; }

        [TestMethod]
        public void IsCorrectLoadedFile()
        {
            ActionOnFileXlsx(IsCorrectLoadedFile);
        }

        public void IsCorrectLoadedFile(MemoryFile file)
        {
            Assert.IsNotNull(file);
        }

        [TestMethod]
        public void IsCorrectImportResult()
        {
            ActionOnFileXlsx(IsCorrectImportResult);
        }

        public void IsCorrectImportResult(MemoryFile file)
        {
            var importFile = Imports.Imports.ImportTest1(file);
            Assert.IsNotNull(importFile);
        }

        [TestMethod]
        public void HasCorrectImportObjects()
        {
            ActionOnFileXlsx(HasCorrectImportObjects);
        }

        public void HasCorrectImportObjects(MemoryFile file)
        {
            var importFile = Imports.Imports.ImportTest1(file);
            Assert.AreEqual(importFile.Objects.Count, 3);
        }

        [TestMethod]
        public void HasImportErrors()
        {
            ActionOnFileXlsx(HasImportErrors);
        }

        public void HasImportErrors(MemoryFile file)
        {
            var importFile = Imports.Imports.ImportTest1(file);
            Assert.IsTrue(importFile.HasErrors);
        }

        [TestMethod]
        public void IsCorrectCreatedObject()
        {
            ActionOnFileXlsx(IsCorrectCreatedObject);
        }

        public void IsCorrectCreatedObject(MemoryFile file)
        {
            var importFile = Imports.Imports.ImportTest1(file);
            var row = importFile.Objects.First();
            Assert.AreEqual(row.Col1String, "Id1");
            Assert.AreEqual(row.Col2StringNull, "Green");
            Assert.AreEqual(row.Col3Int, 1);
            Assert.AreEqual(row.Col4IntNull, 11);
            Assert.AreEqual(row.Col5DateTime, new DateTime(2000, 4, 10));
            Assert.AreEqual(row.Col6DateTimeNull, new DateTime(2001, 9, 11));
            Assert.AreEqual(row.Col7Decimal, 1.0m);
            Assert.AreEqual(row.Col8DecimalNull, 11.0m);
            Assert.AreEqual(row.Col9Bool, true);
            Assert.AreEqual(row.Col10BoolNull, false);
            Assert.AreEqual(row.Col11Email, "test.email@gmail.com");
            Assert.AreEqual(row.Col12CustomRegex, "Y");
        }

        [TestMethod]
        public void IsExpectedErrors()
        {
            ActionOnFileXlsx(IsExpectedErrors);
        }

        public void IsExpectedErrors(MemoryFile file)
        {
            var importFile = Imports.Imports.ImportTest1(file);
            Assert.AreEqual(importFile.Errors.Count, 19);
            Assert.AreEqual("Error in line 5, column 3 (Col3Int): Incorrect value ('-1'). Value has to be between 0 and 2147483647.", importFile.Errors[0]);
            Assert.AreEqual("Error in line 5, column 11 (Col11Email): Incorrect value ('ABC'). Does not meet the pattern 'Email'.", importFile.Errors[1]);
            Assert.AreEqual("Error in line 6, column 2 (Col2StringNull): Incorrect value ('Red 1234', length: 8). Max lenght 5.", importFile.Errors[2]);
            Assert.AreEqual("Error in line 6, column 3 (Col3Int): Value is required.", importFile.Errors[3]);
            Assert.AreEqual("Error in line 6, column 5 (Col5DateTime): Value is required.", importFile.Errors[4]);
            Assert.AreEqual("Error in line 6, column 8 (Col8DecimalNull): Cannot convert 'test' to System.Decimal.", importFile.Errors[5]);
            Assert.AreEqual("Error in line 6, column 9 (Col9Bool): Cannot convert 'test1' to System.Boolean.", importFile.Errors[6]);
            Assert.AreEqual("Error in line 6, column 11 (Col11Email): Incorrect value ('test.@gmail'). Does not meet the pattern 'Email'.", importFile.Errors[7]);
            Assert.AreEqual("Error in line 6, column 12 (Col12CustomRegex): Incorrect value ('ABC'). Does not meet the pattern 'Custom'.", importFile.Errors[8]);
            Assert.AreEqual("Error in line 7, column 6 (Col6DateTimeNull): Cannot convert '36892' to System.DateTime.", importFile.Errors[9]);
            Assert.AreEqual("Error in line 7, column 7 (Col7Decimal): Cannot convert 'CDF' to System.Decimal.", importFile.Errors[10]);
            Assert.AreEqual("Error in line 7, column 11 (Col11Email): Incorrect value ('test.gmail.com'). Does not meet the pattern 'Email'.", importFile.Errors[11]);
            Assert.AreEqual("Error in line 8, column 4 (Col4IntNull): Incorrect value ('-100'). Value has to be between -90 and 90.", importFile.Errors[12]);
            Assert.AreEqual("Error in line 8, column 7 (Col7Decimal): Incorrect value ('11.2'). Value has to be between 0 and 10.", importFile.Errors[13]);
            Assert.AreEqual("Error in line 8, column 11 (Col11Email): Value is required.", importFile.Errors[14]);
            Assert.AreEqual("Error in line 9, column 1 (Col1String): Value is required.", importFile.Errors[15]);
            Assert.AreEqual("Error in line 9, column 8 (Col8DecimalNull): Incorrect value ('130.0'). Value has to be between 0 and 100.", importFile.Errors[16]);
            Assert.AreEqual("Error in line 9, column 12 (Col12CustomRegex): Value is required.", importFile.Errors[17]);
            Assert.AreEqual("Error in line 10, column 3 (Col3Int): Cannot convert 'QWE' to System.Int32.", importFile.Errors[18]);
        }

        private void ActionOnFileXlsx(Action<MemoryFile> action)
        {
            var fileStream = new FileStream(FilePath, FileMode.Open);
            using (fileStream)
            {
                var file = new MemoryFile(fileStream, ContentType, FileName);
                action(file);
            }
        }
    }
}
