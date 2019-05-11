using System;
using System.Collections.Generic;
using System.Text;
using Clipboard;

namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {
            string demo = @"demo";
            string fileName = @"test";

            //Comment next line to end the demo mode 
            //and backup your clipboard data.
            ClipboardHelper.Deserialize(demo);
            Console.WriteLine("restore the demo clipboard");
            //Open the clipboard and serialize into a directory
            ClipboardHelper.Serialize(fileName);
            Console.WriteLine("clipboard to " + fileName);

            //Deserialize the clipboard and set data
            //to win clipboard ready to be pasted
            ClipboardHelper.Deserialize(fileName);
            Console.WriteLine("restore the clipboard " + fileName);

            Console.WriteLine();
            Console.WriteLine("Now try to paste into Word, notepad, OpenOffice or where you want. It's my clipboard after having copied some rows of codeproject.com homepage. Each element preserve its format!");
            Console.ReadLine();
        }
    }
}
