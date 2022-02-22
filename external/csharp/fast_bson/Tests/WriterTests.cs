using System;
using System.IO;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using NUnit.Framework;
using Kernys.Bson;


namespace Tests {
	[TestFixture]
	public class WriterTests {
		[Test]
		public void WriteSingleObject() {
			var BSONobj = new BSONObject();

			BSONobj["Blah"] = 1;

			string data = MiscellaneousUtils.BytesToHex(SimpleBSON.Dump(BSONobj));
			Assert.AreEqual("0F-00-00-00-10-42-6C-61-68-00-01-00-00-00-00", data);
		}

		public static int WriteFile(String filePath, byte[] content) {
			// NOTE: specifying FileMode.Create|FileMode.Truncate
			// leads to System.ArgumentOutOfRangeException : Enum value was out of legal range.

            var fileStream = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.ReadWrite);
            var binaryWriter = new BinaryWriter(fileStream);
            try {
                binaryWriter.Write(content);
            } finally {
                binaryWriter.Close();
                fileStream.Close();
            }
            return 0;
        }

		public static void SaveMemoryStream(string filePath, MemoryStream memoryStream ) {
			FileStream fileStream = File.OpenWrite(filePath);
			memoryStream.WriteTo(fileStream);
			fileStream.Flush();
			fileStream.Close();
		}

		[Test]
		public void WriteFile() {
			var BSONobj = new BSONObject();
			BSONobj["Blah"] = 1;
			var filePath = "C:\\temp\\text.bson";
			WriteFile( filePath, SimpleBSON.Dump(BSONobj));
			Assert.AreEqual(15, new FileInfo(filePath).Length );
		}
		
		[Test]
		public void WriteArray() {
			byte[] data = MiscellaneousUtils.HexToBytes("31-00-00-00-04-42-53-4f-4e-00-26-00-00-00-02-30-00-08-00-00-00-61-77-65-73-6f-6d-65-00-01-31-00-33-33-33-33-33-33-14-40-10-32-00-c2-07-00-00-00-00");

			var BSONobj = new BSONObject();

			BSONobj["BSON"] = new BSONArray();
			BSONobj["BSON"].Add("awesome");
			BSONobj["BSON"].Add(5.05);
			BSONobj["BSON"].Add(1986);

			byte[] target = SimpleBSON.Dump(BSONobj);
			Assert.IsTrue(MiscellaneousUtils.ByteArrayCompare(target, data) == 0);
		}

	}
}

