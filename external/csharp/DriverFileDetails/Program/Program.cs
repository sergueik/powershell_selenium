using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Automation;
using System.Runtime.InteropServices;
using Newtonsoft.Json;

class Program
{
	[System.STAThread]
	public static void Main(string[] args)
	{
		// Find the Driver File Details dialog.
		var dialog = AutomationElement.FromHandle(
			Win32Helper.FindWindowByName(IntPtr.Zero, "Driver File Details"));

		// Find the various pieces of the dialog.
		var list = dialog.FindChildById(228);
		var provider = dialog.FindChildById(229);
		var version = dialog.FindChildById(230);
		var copyright = dialog.FindChildById(231);
		var signer = dialog.FindChildById(232);

		// Enumerate and print the list items
		foreach (AutomationElement item in
		         list.EnumChildrenOfControlType(ControlType.DataItem))
		{
			Console.WriteLine("Driver: {0}", item.Current.Name);

			var pattern = item.GetCurrentPattern(SelectionItemPattern.Pattern)
				as SelectionItemPattern;
			pattern.Select();

			Console.WriteLine("Provider: {0}", provider.Current.Name);
			Console.WriteLine("Version: {0}", version.Current.Name);
			Console.WriteLine("Copyright: {0}", copyright.Current.Name);
			Console.WriteLine("Signer: {0}", signer.Current.Name);
			Console.WriteLine();
			Console.ReadLine();
		}
	}
}