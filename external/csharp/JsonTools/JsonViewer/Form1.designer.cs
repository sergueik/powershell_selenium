namespace JsonViewer
{
    partial class Form1
    {
        /// <summary>
        /// Erforderliche Designervariable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Verwendete Ressourcen bereinigen.
        /// </summary>
        /// <param name="disposing">True, wenn verwaltete Ressourcen gelöscht werden sollen; andernfalls False.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Vom Windows Form-Designer generierter Code

        /// <summary>
        /// Erforderliche Methode für die Designerunterstützung.
        /// Der Inhalt der Methode darf nicht mit dem Code-Editor geändert werden.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.btnImportTextPaste = new System.Windows.Forms.Button();
            this.txtImportText = new System.Windows.Forms.TextBox();
            this.btnImportTextLoad = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.btnImportFileSelect = new System.Windows.Forms.Button();
            this.btnImportFileLoad = new System.Windows.Forms.Button();
            this.txtImportFile = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.btnImportUrlLoad = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.txtImportUrl = new System.Windows.Forms.TextBox();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.lstJsonTree = new System.Windows.Forms.TreeView();
            this.TypeImageList = new System.Windows.Forms.ImageList(this.components);
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(377, 403);
            this.tabControl1.TabIndex = 0;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.btnImportTextPaste);
            this.tabPage1.Controls.Add(this.txtImportText);
            this.tabPage1.Controls.Add(this.btnImportTextLoad);
            this.tabPage1.Controls.Add(this.label3);
            this.tabPage1.Controls.Add(this.btnImportFileSelect);
            this.tabPage1.Controls.Add(this.btnImportFileLoad);
            this.tabPage1.Controls.Add(this.txtImportFile);
            this.tabPage1.Controls.Add(this.label2);
            this.tabPage1.Controls.Add(this.btnImportUrlLoad);
            this.tabPage1.Controls.Add(this.label1);
            this.tabPage1.Controls.Add(this.txtImportUrl);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(369, 377);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Import";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // btnImportTextPaste
            // 
            this.btnImportTextPaste.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnImportTextPaste.Location = new System.Drawing.Point(264, 71);
            this.btnImportTextPaste.Name = "btnImportTextPaste";
            this.btnImportTextPaste.Size = new System.Drawing.Size(50, 20);
            this.btnImportTextPaste.TabIndex = 10;
            this.btnImportTextPaste.Text = "Paste";
            this.btnImportTextPaste.UseVisualStyleBackColor = true;
            this.btnImportTextPaste.Click += new System.EventHandler(this.btnImportTextPaste_Click);
            // 
            // txtImportText
            // 
            this.txtImportText.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtImportText.Location = new System.Drawing.Point(9, 92);
            this.txtImportText.Multiline = true;
            this.txtImportText.Name = "txtImportText";
            this.txtImportText.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtImportText.Size = new System.Drawing.Size(354, 277);
            this.txtImportText.TabIndex = 9;
            // 
            // btnImportTextLoad
            // 
            this.btnImportTextLoad.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnImportTextLoad.Location = new System.Drawing.Point(320, 71);
            this.btnImportTextLoad.Name = "btnImportTextLoad";
            this.btnImportTextLoad.Size = new System.Drawing.Size(43, 20);
            this.btnImportTextLoad.TabIndex = 8;
            this.btnImportTextLoad.Text = "Load";
            this.btnImportTextLoad.UseVisualStyleBackColor = true;
            this.btnImportTextLoad.Click += new System.EventHandler(this.btnImportTextLoad_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(6, 76);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(31, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Text:";
            // 
            // btnImportFileSelect
            // 
            this.btnImportFileSelect.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnImportFileSelect.Location = new System.Drawing.Point(286, 40);
            this.btnImportFileSelect.Name = "btnImportFileSelect";
            this.btnImportFileSelect.Size = new System.Drawing.Size(28, 20);
            this.btnImportFileSelect.TabIndex = 6;
            this.btnImportFileSelect.Text = "...";
            this.btnImportFileSelect.UseVisualStyleBackColor = true;
            this.btnImportFileSelect.Click += new System.EventHandler(this.btnImportFileSelect_Click);
            // 
            // btnImportFileLoad
            // 
            this.btnImportFileLoad.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnImportFileLoad.Location = new System.Drawing.Point(320, 40);
            this.btnImportFileLoad.Name = "btnImportFileLoad";
            this.btnImportFileLoad.Size = new System.Drawing.Size(43, 20);
            this.btnImportFileLoad.TabIndex = 5;
            this.btnImportFileLoad.Text = "Load";
            this.btnImportFileLoad.UseVisualStyleBackColor = true;
            this.btnImportFileLoad.Click += new System.EventHandler(this.btnImportFileLoad_Click);
            // 
            // txtImportFile
            // 
            this.txtImportFile.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtImportFile.Location = new System.Drawing.Point(44, 40);
            this.txtImportFile.Name = "txtImportFile";
            this.txtImportFile.Size = new System.Drawing.Size(236, 20);
            this.txtImportFile.TabIndex = 4;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(6, 43);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(26, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "File:";
            // 
            // btnImportUrlLoad
            // 
            this.btnImportUrlLoad.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnImportUrlLoad.Location = new System.Drawing.Point(320, 9);
            this.btnImportUrlLoad.Name = "btnImportUrlLoad";
            this.btnImportUrlLoad.Size = new System.Drawing.Size(43, 20);
            this.btnImportUrlLoad.TabIndex = 2;
            this.btnImportUrlLoad.Text = "Load";
            this.btnImportUrlLoad.UseVisualStyleBackColor = true;
            this.btnImportUrlLoad.Click += new System.EventHandler(this.btnImportUrlLoad_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(6, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(32, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "URL:";
            // 
            // txtImportUrl
            // 
            this.txtImportUrl.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtImportUrl.Location = new System.Drawing.Point(44, 9);
            this.txtImportUrl.Name = "txtImportUrl";
            this.txtImportUrl.Size = new System.Drawing.Size(270, 20);
            this.txtImportUrl.TabIndex = 0;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.lstJsonTree);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(369, 377);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "View";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // lstJsonTree
            // 
            this.lstJsonTree.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstJsonTree.ImageIndex = 5;
            this.lstJsonTree.ImageList = this.TypeImageList;
            this.lstJsonTree.Location = new System.Drawing.Point(3, 3);
            this.lstJsonTree.Name = "lstJsonTree";
            this.lstJsonTree.SelectedImageIndex = 0;
            this.lstJsonTree.Size = new System.Drawing.Size(363, 371);
            this.lstJsonTree.TabIndex = 0;
            // 
            // TypeImageList
            // 
            this.TypeImageList.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("TypeImageList.ImageStream")));
            this.TypeImageList.TransparentColor = System.Drawing.Color.Transparent;
            this.TypeImageList.Images.SetKeyName(0, "IconObject.png");
            this.TypeImageList.Images.SetKeyName(1, "IconArray.png");
            this.TypeImageList.Images.SetKeyName(2, "IconString.png");
            this.TypeImageList.Images.SetKeyName(3, "IconNumber.png");
            this.TypeImageList.Images.SetKeyName(4, "IconBoolean.png");
            this.TypeImageList.Images.SetKeyName(5, "IconNull.png");
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(377, 403);
            this.Controls.Add(this.tabControl1);
            this.Name = "Form1";
            this.Text = "Json Viewer";
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            this.tabPage2.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.Button btnImportFileSelect;
        private System.Windows.Forms.Button btnImportFileLoad;
        private System.Windows.Forms.TextBox txtImportFile;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnImportUrlLoad;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtImportUrl;
        private System.Windows.Forms.TabPage tabPage2;
        private System.Windows.Forms.Button btnImportTextPaste;
        private System.Windows.Forms.TextBox txtImportText;
        private System.Windows.Forms.Button btnImportTextLoad;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TreeView lstJsonTree;
        private System.Windows.Forms.ImageList TypeImageList;
    }
}

