/*
Copyright (c) 2006, 2014, 2015 Serguei Kouzmine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

using System;
using System.IO;
using System.Threading;

public class Program
{
    private static string _filename = String.Format("my random filename {0}", new Random().Next(10));
    private static string _filepath;
    public static string Filename
    {
        get { return _filename; }
        set { _filename = value; }
    }

    //	http://www.java2s.com/Tutorial/CSharp/0300__File-Directory-Stream/UseFileSystemWatchertodetectfilechanges.htm     
    private static void OnCreatedOrDeleted(object sender, FileSystemEventArgs e)
    {
        Console.WriteLine("\tNOTIFICATION: " + e.FullPath + "' was " + e.ChangeType.ToString());
    }

    public static void Main()
    {
        EnumReport.Filename = "test.txt";
        EnumReport.Filename = _filename;
        _filepath = Path.Combine(Environment.GetEnvironmentVariable("TEMP"), _filename);
        using (FileSystemWatcher watch = new FileSystemWatcher())
        {
            watch.Path = Environment.GetEnvironmentVariable("TEMP");
            watch.Filter = _filename;
            watch.IncludeSubdirectories = false;
            watch.Created += new FileSystemEventHandler(OnCreatedOrDeleted);
            watch.Deleted += new FileSystemEventHandler(OnCreatedOrDeleted);
            watch.EnableRaisingEvents = true;

            if (File.Exists(_filepath))
            {
                File.Delete(_filepath);
            }
            EnumReport.EnumWindows(EnumReport.Report, 0);
            Thread.Sleep(120);
        }
    }
}