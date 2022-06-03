using System;
using System.Collections.Generic;
using NUnit.Framework;
using System.Data;
using System.Collections;
using System.Threading;
using fastJSON;
using System.Collections.Specialized;
using System.Reflection.Emit;
using System.Diagnostics;
using System.Runtime.Serialization;
using System.Collections.ObjectModel;

public class Tests {

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
		var x = (ArrayList)o["a"];
		Assert.AreEqual("c", x[1]);

	}
	
	[Test]
	public static void test3() {
		String s = "{'a':[{'b':'B'},{'c':'C'}]}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		var x = (ArrayList)o["a"];
		var y = (Dictionary<string,object>)x[0];
		Assert.AreEqual("B", y["b"]);

	}

	[Test]
	public static void test4() {
		String s = "{'a':[{'b':['B']},{'c':'C'}]}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		Console.Error.WriteLine(fastJSON.JSON.Instance.Beautify(s));
		var x = (ArrayList)o["a"];
		var y = (Dictionary<string,object>)x[0];
		var z = (ArrayList)y["b"];

		Assert.AreEqual("B", z[0]);

	}
	
	[Test]
	public static void test5() {
		String s = "{'a':[{'b':{'c':'C'}}]}".Replace("'", "\"");
		var o = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(s);
		Console.Error.WriteLine(fastJSON.JSON.Instance.Beautify(s));
		var x = (ArrayList)o["a"];
		var y = (Dictionary<string,object>)x[0];
		var z = (Dictionary<string,object>)y["b"];

		Assert.AreEqual("C", z["c"]);

	}

	[Test]
	public static void test6() {
		var d = new Dictionary<string,object>();
		d.Add("foo", "bar");
		d.Add("pi", 3.14f);	
		d.Add("valid", true);
		var a = new List<String>();
		a.Add("a");
		a.Add("b");
		a.Add("c");
		d.Add("array", a);
		var r = fastJSON.JSON.Instance.ToJSON(d);
		Console.Error.WriteLine(r);
		StringAssert.AreEqualIgnoringCase(r, @"{""foo"":""bar"",""pi"":3.14,""valid"":true,""array"":[""a"",""b"",""c""]}");
	}

	[Test]
	public static void test7() {
		var d = new System.Collections.Hashtable();
		d.Add("foo", "bar");
		d.Add("pi", 3.14f);	
		d.Add("valid", true);
		var a = new List<String>();
		a.Add("a");
		a.Add("b");
		a.Add("c");
		d.Add("array", a);
		var r = fastJSON.JSON.Instance.ToJSON(d);
		Console.Error.WriteLine(r);
		StringAssert.AreEqualIgnoringCase(r, @"[{""k"":""array"",""v"":[""a"",""b"",""c""]},{""k"":""foo"",""v"":""bar""},{""k"":""valid"",""v"":true},{""k"":""pi"",""v"":3.14}]");
	}


}