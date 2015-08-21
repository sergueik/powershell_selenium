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
            this.Label1.Location = new System.Drawing.Point(16, 10);
            this.Label1.Name = "Label1";
            this.Label1.Size = new System.Drawing.Size(224, 23);
            this.Label1.TabIndex = 5;
            this.Label1.Text = "Recently created files:";
            // 
            // cmdClose
            // 
            this.cmdClose.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdClose.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.cmdClose.Location = new System.Drawing.Point(103, 190);
            this.cmdClose.Name = "cmdClose";
            this.cmdClose.Size = new System.Drawing.Size(141, 34);
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
            this.lstFiles.ItemHeight = 21;
            this.lstFiles.Location = new System.Drawing.Point(16, 39);
            this.lstFiles.Name = "lstFiles";
            this.lstFiles.Size = new System.Drawing.Size(228, 140);
            this.lstFiles.TabIndex = 3;
            // 
            // App
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(8, 20);
            this.ClientSize = new System.Drawing.Size(260, 234);
            this.Controls.Add(this.Label1);
            this.Controls.Add(this.cmdClose);
            this.Controls.Add(this.lstFiles);
            this.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "App";
            this.Text = "SystemTrayApp";
            this.ResumeLayout(false);

        }

    }
}
