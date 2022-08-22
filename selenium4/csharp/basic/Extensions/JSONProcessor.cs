using System;

using System.IO;
using System.Runtime.Serialization.Json;

namespace Extensions {
	// origin:
	// http://www.java2s.com/Code/CSharp/Network/SerializesDeserializessourceintoaJSONstring.htm

	public static class JSONProcessor {
		
		public static string Stringify<T>(T source) where T : class {
			string ret = null;
			var serializer = new DataContractJsonSerializer(typeof(T));
			using (var memoryStream = new MemoryStream()) {
				serializer.WriteObject(memoryStream, source);
				memoryStream.Flush();
				memoryStream.Position = 0;
				using (StreamReader reader = new StreamReader(memoryStream)) {
					ret = reader.ReadToEnd();
				}
			}
			return ret;
		}
		
		
		public static T Parse<T>(string source) where T : class {
			T ret = null;
			DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(T));
			using (MemoryStream memoryStream = new MemoryStream()) {
				using (StreamWriter writer = new StreamWriter(memoryStream)) {
					writer.Write(source);
					writer.Flush();
					memoryStream.Position = 0;
					ret = serializer.ReadObject(memoryStream) as T;
				}
			}
			return ret;
		}
	}
}
