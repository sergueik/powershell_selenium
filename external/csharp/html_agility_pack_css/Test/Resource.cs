using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace HapCss.UnitTests {
	internal class Resource {
		private static Dictionary<string, byte[]> documentCache = new Dictionary<string, byte[]>(StringComparer.InvariantCultureIgnoreCase);

		// https://html-agility-pack.net/from-string
		public static string GetString(string data) {
			return data;
		}
		public static string GetString(string resourceName, Stream dataStream) {
			return Encoding.UTF8.GetString(GetBytes(resourceName, dataStream));
		}

		public static string GetString(Uri resourceUri, Stream dataStream) {
			return Encoding.UTF8.GetString(GetBytes(resourceUri.AbsolutePath, dataStream));
		}

		private static byte[] GetBytes(string resourceName, Stream stream) {
			byte[] data;

			if (documentCache.TryGetValue(resourceName, out data))
				return data;
			var asm = typeof(Resource).Assembly;

			if (stream == null)
				throw new InvalidOperationException("Stream não encontrado: " + resourceName);

			var ms = new MemoryStream();
			stream.CopyTo(ms);
			ms.Position = 0;
			data = ms.ToArray();
			documentCache.Add(resourceName, data);
			return data;
		}
	}
}
