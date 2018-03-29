using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;

namespace NUnit.Demo99.config
{
    class Constants
    {
        //This is the list of our variables
        //Declared as 'public', so that it can be used in other classes of this project
        //Declared as 'static', so that we do not need to instantiate a class object
        //Declared as 'const', so that the value of this variable cannot be changed
        // 'String' & 'int' are the two data type for storing a type of value	
        public const string URL = "http://www.store.demoqa.com";
        public static string assemblyDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        public static string projectDir = Path.GetDirectoryName(Path.GetDirectoryName(assemblyDir));
        public static string Path_TestData = Path.Combine(projectDir, "dataEngine\\DataEngine.xlsx");
        //public static const string Path_OR  = "OR.txt";
        public static string Path_TestScr = Path.Combine(projectDir, "extend-src.png");
        public static string Path_Report = Path.Combine(projectDir, "extent-report.html");
        public static string Path_Config = Path.Combine(projectDir, "\\config\\", "extent-config.xml");

        //List of Data Sheet Column Numbers
        public const int Col_TestCaseID = 0;
        public const int Col_TestScenarioID = 1;
        public const int Col_PageObject = 4;
        public const int Col_ActionKeyword = 5;
        public const int Col_DataSet = 6;

        // New entry in Constant variable
        public const int Col_RunMode = 2;

        // Two new constants variables to mark Fail or Pass
        public const String KEYWORD_FAIL = "FAIL";
        public const String KEYWORD_PASS = "PASS";

        // Define two new result column
        public const int Col_CaseResult = 3;
        public const int Col_TestStepResult = 7;

        //List of Data Engine Excel sheets
        public const String Sheet_TestSteps = "Test Steps";
        // New entry in Constant variable
        public const String Sheet_TestCases = "Test cases";
    }
}
