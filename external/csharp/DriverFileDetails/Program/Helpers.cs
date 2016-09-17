using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Automation;
using System.Runtime.InteropServices;
using Newtonsoft.Json;

static class AutomationElementHelpers
{
	public static AutomationElement
		FindChildById(this AutomationElement parent, int id)
	{
		return parent == null ? null :
			parent.FindFirst(
				TreeScope.Children,
				new PropertyCondition(AutomationElement.AutomationIdProperty,
				                      id.ToString()));
	}

	public static IEnumerable<AutomationElement>
		EnumChildrenOfControlType(this AutomationElement parent, ControlType type)
	{
		return (parent == null )? Enumerable.Empty<AutomationElement>()
			: parent.FindAll(TreeScope.Children,
			                 new PropertyCondition(AutomationElement.ControlTypeProperty,
			                                       type)).Cast<AutomationElement>();
	}
}

static class Win32Helper
{
	[DllImport("user32.dll", EntryPoint = "FindWindow", SetLastError = true)]
	static extern public System.IntPtr
		FindWindowByName(System.IntPtr MustBeZero, string name);
}

