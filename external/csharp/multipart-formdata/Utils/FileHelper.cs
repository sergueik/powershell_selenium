using System;
using System.IO;
using System.Text;
using System.Threading;

namespace Utils {
	public class FileHelper {
		private string filePath = null;
		public int Retries { get; set; }
		public string FilePath {
			set { filePath = value; }
		}
		public string Text { get; set; }
		private byte[] bytes;
		public byte[] Bytes { get { return bytes; } }

	
		public void WriteContents() {
			Boolean done = false;
			if (!string.IsNullOrEmpty(filePath)) {
				// Console.Error.WriteLine(String.Format("Writing data to {0}.", filePath));
				for (int cnt = 0; cnt != Retries; cnt++) {
					if (done)
						break;
					try {
						using (FileStream stream = new FileInfo(filePath).Open(FileMode.OpenOrCreate, FileAccess.Write, FileShare.None)) {						
							bytes = Encoding.ASCII.GetBytes(Text);
							// stream.Lock(0, bytes.Length);
							// have to truncate
							stream.SetLength(0);
							// Console.Error.WriteLine(String.Format("Writing text {0}.", Text));
							stream.Write(bytes, 0, bytes.Length);
							stream.Flush();
							stream.Close();
							// Console.Error.WriteLine(String.Format("Written text {0}.", Text));
							// stream.Unlock(0, bytes.Length);
							done = true;
						}
					} catch (IOException e) {
						Console.Error.WriteLine(String.Format("Got Exception {0}. Wait and retry", e.Message));
						Thread.Sleep(1000);
						// wait and retry
					}	
				}
			}
			return;
		}
	
		// retries if "File in use by another process"
		// because file is being processed by another thread
		public void ReadContents()
		{
			Text = null;
			if (!string.IsNullOrEmpty(filePath) && File.Exists(filePath)) {
				for (int cnt = 0; cnt != Retries; cnt++) {	
					try {
						using (FileStream stream = new FileInfo(filePath).Open(FileMode.Open, FileAccess.Read, FileShare.None)) {
						
							int numBytesToRead = (int)stream.Length;
							if (numBytesToRead > 0) {
								bytes = new byte[numBytesToRead];
								int numBytesRead = 0;
								while (numBytesToRead > 0) {
									// Console.Error.WriteLine(String.Format("{0} bytes to read", numBytesToRead));
									int n = stream.Read(bytes, numBytesRead, numBytesToRead);
									if (n == 0)
										break;

									numBytesRead += n;
									numBytesToRead -= n;
								}
								numBytesToRead = bytes.Length;
								Text = Encoding.ASCII.GetString(bytes);
								// the below call is race condition prone
								// text =  System.IO.File.ReadAllText(filePath);
							}
						}
					} catch (IOException) {
						Thread.Sleep(1000);
						// wait and retry
					}	
				}
			}
			return;
		}

	}
}

