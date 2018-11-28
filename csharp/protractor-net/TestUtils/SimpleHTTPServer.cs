using NUnit.Framework;

using System;

using System.Collections.Generic;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Net;
using System.Text.RegularExpressions;
using System.Text;
using System.Threading;

// based on:
// https://gist.github.com/aksakalli/9191056
// MIT License - Copyright (c) 2016 Can Güney Aksakalli
// https://aksakalli.github.io/2014/02/24/simple-http-server-with-csparp.html
// see also:
// https://github.com/unosquare/embedio
// https://github.com/bonesoul/uhttpsharp
namespace Protractor.TestUtils
{
	public class SimpleHTTPServer{

		private /* readonly */ string[] indexFiles = {
			"index.html",
		};
		public string[] IndexFiles {
			get { return indexFiles; }
			set {
				indexFiles = value;
			}
		}

		public string GetIndexFile(int index) {
			return indexFiles[index];
		}

		public void SetIndexFile(int index, string value)
		{
			indexFiles[index] = value;
		}
		private Thread _serverThread;
		private string documentRoot;
		private HttpListener _listener;
		private int port;

		public int Port {
			get { return port; }
		}

		public SimpleHTTPServer(string documentRoot, int port) {
			this.Initialize(documentRoot, port);
		}

		public SimpleHTTPServer(string documentRoot) {
			// find an unused port
			TcpListener tcpListener = new TcpListener(IPAddress.Loopback, 0);
			tcpListener.Start();
			int unusedPort = ((IPEndPoint)tcpListener.LocalEndpoint).Port;
			tcpListener.Stop();
			this.Initialize(documentRoot, unusedPort);
		}
		
		public void Stop() {
			_serverThread.Abort();
			_listener.Stop();
		}

		private void Listen() {
			_listener = new HttpListener();
			_listener.Prefixes.Add("http://*:" + port.ToString() + "/");
			_listener.Start();
			while (true) {
				try {
					HttpListenerContext context = _listener.GetContext();
					Process(context);
				} catch (Exception) {

				}
			}
		}

		private void Process(HttpListenerContext context) {
			string filename = context.Request.Url.AbsolutePath;
			string query = context.Request.Url.Query;
			// Console.Error.WriteLine(String.Format("Processing {0}", context.Request.Url.LocalPath));
			filename = filename.Substring(1); // chop the oot portion of the request path
			if (string.IsNullOrEmpty(filename)) {
				foreach (string indexFile in indexFiles) {					
					if (File.Exists(Path.Combine(documentRoot, indexFile))) {
						filename = indexFile;
						break;
					}
				}
			}

			filename = Path.Combine(documentRoot, filename);

			if (File.Exists(filename)) {

				try {
					Stream input = new FileStream(filename, FileMode.Open);

					// Adding fixed minimal http response headers
					string mime;
					context.Response.ContentType = mimeTypes.TryGetValue(Path.GetExtension(filename), out mime) ? mime : "application/octet-stream";
					context.Response.ContentLength64 = input.Length;
					context.Response.AddHeader("Date", DateTime.Now.ToString("r"));
					context.Response.AddHeader("Last-Modified", System.IO.File.GetLastWriteTime(filename).ToString("r"));

					byte[] buffer = new byte[1024 * 16];
					int nbytes;
					while ((nbytes = input.Read(buffer, 0, buffer.Length)) > 0)
						context.Response.OutputStream.Write(buffer, 0, nbytes);
					input.Close();

					context.Response.StatusCode = (int)HttpStatusCode.OK;
					context.Response.OutputStream.Flush();
				} catch (Exception) {
					context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
				}

			} else {
				context.Response.StatusCode = (int)HttpStatusCode.NotFound;
			}

			context.Response.OutputStream.Close();
		}

		private void Initialize(string documentRoot, int port) {
			this.documentRoot = documentRoot;
			this.port = port;
			_serverThread = new Thread(this.Listen);
			_serverThread.Start();
		}
		
		private static IDictionary<string, string> mimeTypes = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase) {
        #region extension to MIME type list
			{ ".css", "text/css" },
			{ ".gif", "image/gif" },
			{ ".htm", "text/html" },
			{ ".html", "text/html" },
			{ ".ico", "image/x-icon" },
			{ ".jpeg", "image/jpeg" },
			{ ".jpg", "image/jpeg" },
			{ ".js", "application/x-javascript" },
			{ ".png", "image/png" },
			{ ".txt", "text/plain" },
         #endregion
		};
	}
		
}
