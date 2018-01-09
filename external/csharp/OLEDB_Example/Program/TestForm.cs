using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;

using Importer;

namespace WindowsApplication1 {
	public partial class TestForm : Form {
		public TestForm() {
			// http://msdn.microsoft.com/en-us/library/ms974559.aspx
			InitializeComponent();
		}

		private void ReadDelimitedFile(string fileName, DelimiterType type) {
			ImportDelimitedFile importer = new ImportDelimitedFile(type);

			importer.ProcessLine += new EventHandler<ImportDelimitedEventArgs>(importer_ProcessLine);

			textBox1.Text += string.Format("- Start {0} ------------------------------\r\n", type.ToString());
			importer.Import(fileName);
			textBox1.Text += string.Format("- End {0} --------------------------------\r\n\r\n", type.ToString());
		}

		void importer_ProcessLine(object sender, ImportDelimitedEventArgs e) {
			if (e.Content.Count > 0) {
				textBox1.Text += string.Format("{0} | ", e.Content[0]);

				for (int i = 1; i < (e.Content.Count - 1); i++) {
					textBox1.Text += string.Format("{0} | ", e.Content[i]);
				}
				textBox1.Text += string.Format("{0}\r\n", e.Content[(e.Content.Count - 1)]);
			}
		}

		private void Form1_Load(object sender, EventArgs e) {
		}

		private void button1_Click(object sender, EventArgs e) {
			textBox1.Text = string.Empty;

			ReadDelimitedFile("..\\..\\..\\Examples\\TabDelimited.txt", DelimiterType.TabDelimited);
			ReadDelimitedFile("..\\..\\..\\Examples\\CommaDelimited.csv", DelimiterType.CsvDelimited);
		}
	}
}