using System;
using System.Collections.Generic;


	// http://www.java2s.com/Code/CSharp/Collections-Data-Structure/DictionaryPrettyPrint.htm
namespace TestUtils {
	public static class DictionaryExtensions {
		public static string PrettyPrint<K, V>(this IDictionary<K, V> dict)
		{
			if (dict == null)
				return "";
			string dictStr = "[";
			ICollection<K> keys = dict.Keys;
			int i = 0;
			foreach (K key in keys) {
				dictStr += key.ToString() + "=" + dict[key].ToString();
				if (i++ < keys.Count - 1) {
					dictStr += ", ";
				}
			}
			return dictStr + "]";
		}
	}
}

