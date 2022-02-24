using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using Echevil;

namespace Network_Monitor_Sample {
	public class FormMain : Form {
		private Label LabelDownload;
		private Label LabelUpload;
		private Label LableDownloadValue;
		private Label LabelUploadValue;
		private ListBox ListAdapters;
		private Timer TimerCounter;
		private IContainer components;
		private NetworkAdapter[] adapters;
		private NetworkMonitor monitor;


		[STAThread]
		static void Main() {
			Application.EnableVisualStyles();
			Application.Run(new FormMain());
		}


		public FormMain() {
			components = new Container();
			ListAdapters = new ListBox();
			LabelDownload = new Label();
			LabelUpload = new Label();
			LableDownloadValue = new Label();
			LabelUploadValue = new Label();
			TimerCounter = new Timer(this.components);
			SuspendLayout();

			ListAdapters.Location = new Point(16, 24);
			ListAdapters.Name = "ListAdapters";
			ListAdapters.Size = new Size(208, 82);
			ListAdapters.TabIndex = 0;
			ListAdapters.SelectedIndexChanged += new System.EventHandler(this.ListAdapters_SelectedIndexChanged);

			LabelDownload.Location = new Point(256, 32);
			LabelDownload.Name = "LabelDownload";
			LabelDownload.TabIndex = 1;
			LabelDownload.Text = "Download Speed:";
			LabelDownload.TextAlign = ContentAlignment.MiddleRight;

			LabelUpload.Location = new Point(256, 80);
			LabelUpload.Name = "LabelUpload";
			LabelUpload.TabIndex = 2;
			LabelUpload.Text = "Upload Speed:";
			LabelUpload.TextAlign = ContentAlignment.MiddleRight;

			LableDownloadValue.Location = new Point(392, 32);
			LableDownloadValue.Name = "LableDownloadValue";
			LableDownloadValue.TabIndex = 3;
			LableDownloadValue.TextAlign = ContentAlignment.MiddleLeft;

			LabelUploadValue.Location = new Point(392, 80);
			LabelUploadValue.Name = "LabelUploadValue";
			LabelUploadValue.TabIndex = 4;
			LabelUploadValue.TextAlign = ContentAlignment.MiddleLeft;

			TimerCounter.Interval = 1000;
			TimerCounter.Tick += new System.EventHandler(this.TimerCounter_Tick);

			this.AutoScaleBaseSize = new Size(5, 13);
			ClientSize = new Size(520, 134);
			Controls.Add(LabelUploadValue);
			Controls.Add(LableDownloadValue);
			Controls.Add(LabelUpload);
			Controls.Add(LabelDownload);
			Controls.Add(ListAdapters);
			Name = "FormMain";
			Text = "Network Monitor Demo";
			Load += new System.EventHandler(FormMain_Load);
			ResumeLayout(false);
		}

		protected override void Dispose(bool disposing) {
			if (disposing) {
				if (components != null) {
					components.Dispose();
				}
			}
			base.Dispose(disposing);
		}

		private void FormMain_Load(object sender, System.EventArgs e) {
			monitor	= new NetworkMonitor();
			adapters = monitor.Adapters;

			if (adapters.Length == 0) {
				ListAdapters.Enabled = false;
				MessageBox.Show("No network adapters found on this computer.");
				return;
			}

			this.ListAdapters.Items.AddRange(this.adapters);
		}

		private void ListAdapters_SelectedIndexChanged(object sender, System.EventArgs e) {
			monitor.StopMonitoring();
			monitor.StartMonitoring(adapters[this.ListAdapters.SelectedIndex]);
			TimerCounter.Start();
		}

		private void TimerCounter_Tick(object sender, System.EventArgs e) {
			NetworkAdapter adapter = adapters[ListAdapters.SelectedIndex];
			LableDownloadValue.Text	= String.Format("{0:n} kbps", adapter.DownloadSpeedKbps);
			LabelUploadValue.Text =	String.Format("{0:n} kbps", adapter.UploadSpeedKbps);
		}

	}
}
