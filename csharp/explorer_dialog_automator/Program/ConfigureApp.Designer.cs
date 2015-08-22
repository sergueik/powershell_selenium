using System;
using System.Drawing;
using System.Diagnostics;
using System.Collections;
using System.Windows.Forms;

namespace ExplorerFileDialogDetector
{

    public partial class ConfigureApp : System.Windows.Forms.Form
    {
        internal System.Windows.Forms.Label Label1;
        internal System.Windows.Forms.Button cmdClose;
        internal System.Windows.Forms.ListBox lstFiles;
        // internal System.Windows.Forms.DateTimePicker intervalpicker;
        internal CustomIntervalPicker intervalpicker;
        private System.ComponentModel.Container components = null;

        private void InitializeComponent()
        {
            this.Label1 = new System.Windows.Forms.Label();
            this.cmdClose = new System.Windows.Forms.Button();
            this.lstFiles = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // Label1
            // 
            this.Label1.Location = new System.Drawing.Point(10, 7);
            this.Label1.Name = "Label1";
            this.Label1.Size = new System.Drawing.Size(140, 16);
            this.Label1.TabIndex = 5;
            this.Label1.Text = "Recently created files:";

            // interval

            this.intervalpicker = new CustomIntervalPicker();
            this.intervalpicker.Parent = this;
            this.intervalpicker.Location = new System.Drawing.Point(162, 153);
            this.intervalpicker.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.intervalpicker.Size = new System.Drawing.Size(70, 20);

            this.intervalpicker.TextChanged += new System.EventHandler((
                   object sender,
                   System.EventArgs eventargs) =>
                   {
                       var intervalpicker_sender = (CustomIntervalPicker)sender;
                       var TimeStr = intervalpicker_sender.Items[intervalpicker_sender.SelectedIndex];
                       Console.WriteLine(TimeStr);
                   });

            /*
            this.intervalpicker = new System.Windows.Forms.DateTimePicker();
            this.intervalpicker.Parent = this;
            this.intervalpicker.MinDate = new DateTime(2015, 8, 20, 0, 0, 1);
            this.intervalpicker.MaxDate = new DateTime(2015, 8, 20, 0, 1, 0);
            this.intervalpicker.Location = new System.Drawing.Point(162, 153);
            this.intervalpicker.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.intervalpicker.Size = new System.Drawing.Size(70, 20);
            this.intervalpicker.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.intervalpicker.CustomFormat = "mm:ss";
            this.intervalpicker.ShowUpDown = true;
            this.intervalpicker.Checked = false;

            this.intervalpicker.TextChanged += new System.EventHandler((
                   object sender,
                   System.EventArgs eventargs) =>
                   {
                       var x = (System.Windows.Forms.DateTimePicker)sender;
                       var datetime = (DateTime)x.Value;
                       var TimeStr = datetime.Second + 60 * datetime.Minute;
                       Console.WriteLine(TimeStr);
                   });

            */

            // 
            // cmdClose
            // 
            this.cmdClose.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdClose.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.cmdClose.Location = new System.Drawing.Point(162, 203);
            this.cmdClose.Name = "cmdClose";
            this.cmdClose.Size = new System.Drawing.Size(88, 24);
            this.cmdClose.TabIndex = 4;
            this.cmdClose.Text = "Close";
            this.cmdClose.Click += new System.EventHandler(this.cmdClose_Click);
            // 
            // lstFiles
            // 
            this.lstFiles.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
            | System.Windows.Forms.AnchorStyles.Left)
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstFiles.IntegralHeight = false;
            this.lstFiles.Location = new System.Drawing.Point(10, 27);
            this.lstFiles.Name = "lstFiles";
            this.lstFiles.Size = new System.Drawing.Size(240, 94);
            this.lstFiles.TabIndex = 3;
            // 
            // ConfigureApp
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 14);
            this.ClientSize = new System.Drawing.Size(260, 234);
            this.Controls.Add(this.Label1);
            this.Controls.Add(this.cmdClose);
            this.Controls.Add(this.lstFiles);
            this.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "ConfigureApp";
            this.Text = "SystemTrayApp";
            this.ResumeLayout(false);

        }

    }
}
