using System;
using System.Collections.Generic;
using NUnit.Framework;
using System.Data;
using System.Collections;
using System.Threading;
using fastJSON;
using System.Collections.Specialized;
using System.Reflection.Emit;
using System.Linq.Expressions;
using System.Diagnostics;
using System.Linq;
using System.Dynamic;
using System.Runtime.Serialization;
using System.Collections.ObjectModel;

public class Tests
{

	[Test]
	public static void test1() {
		String s = "{'a':{'b':'c'}}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		Dictionary<string,object> x = (Dictionary<string,object>)o["a"];
		Assert.AreEqual("c", x["b"]);

	}
	[Test]
	public static void test2() {
		String s = "{'a':['b','c']}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		ArrayList x = (ArrayList)o["a"];
		Assert.AreEqual("c", x[1]);

	}
	
	[Test]
	public static void test3() {
		String s = "{'a':[{'b':'B'},{'c':'C'}]}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		ArrayList x = (ArrayList)o["a"];
		Dictionary<string,object> y = (Dictionary<string,object>)x[0];
		Assert.AreEqual("B", y["b"]);

	}

	[Test]
	public static void test4() {
		String s = "{'a':[{'b':['B']},{'c':'C'}]}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		Console.Error.WriteLine(fastJSON.JSON.Instance.Beautify(s));
		ArrayList x = (ArrayList)o["a"];
		Dictionary<string,object> y = (Dictionary<string,object>)x[0];
		ArrayList z = (ArrayList)y["b"];

		Assert.AreEqual("B", z[0]);

	}
	
		[Test]
	public static void test5() {
		String s = "{'a':[{'b':{'c':'C'}}]}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		Console.Error.WriteLine(fastJSON.JSON.Instance.Beautify(s));
		ArrayList x = (ArrayList)o["a"];
		Dictionary<string,object> y = (Dictionary<string,object>)x[0];
		Dictionary<string,object> z = (Dictionary<string,object>)y["b"];

		Assert.AreEqual("C", z["c"]);

	}

}