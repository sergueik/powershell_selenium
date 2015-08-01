namespace SwdPageRecorder.UI
{
    partial class CapabilitiesDataGridView
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.SuspendLayout();
            // ((System.ComponentModel.ISupportInitialize)(this.dtAdditonalCapabilities)).BeginInit();
            this.dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();

            this.Name = "CapabilitiesDataGridView";
            this.Size = new System.Drawing.Size(552, 389);
            this.dtAdditonalCapabilities = new System.Windows.Forms.DataGridView();
            this.dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            
            // 
            // dtAdditonalCapabilities
            // 
            this.dtAdditonalCapabilities.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dtAdditonalCapabilities.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtAdditonalCapabilities.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dtAdditonalCapabilities.ColumnHeadersHeight = 18;
            this.dtAdditonalCapabilities.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.dataGridViewTextBoxColumn1,
            this.dataGridViewTextBoxColumn2});
            this.dtAdditonalCapabilities.Dock = System.Windows.Forms.DockStyle.Top;
            this.dtAdditonalCapabilities.Location = new System.Drawing.Point(3, 3);
            this.dtAdditonalCapabilities.Name = "dtAdditonalCapabilities";
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtAdditonalCapabilities.RowsDefaultCellStyle = dataGridViewCellStyle4;
            this.dtAdditonalCapabilities.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dtAdditonalCapabilities.Size = new System.Drawing.Size(659, 160);
            this.dtAdditonalCapabilities.TabIndex = 14;
            // 
            // dataGridViewTextBoxColumn1
            // 
            this.dataGridViewTextBoxColumn1.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dataGridViewTextBoxColumn1.DefaultCellStyle = dataGridViewCellStyle2;
            this.dataGridViewTextBoxColumn1.HeaderText = "Capability";
            this.dataGridViewTextBoxColumn1.Name = "dataGridViewTextBoxColumn1";
            this.dataGridViewTextBoxColumn1.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            // 
            // dataGridViewTextBoxColumn2
            // 
            this.dataGridViewTextBoxColumn2.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dataGridViewTextBoxColumn2.DefaultCellStyle = dataGridViewCellStyle3;
            this.dataGridViewTextBoxColumn2.HeaderText = "Value";
            this.dataGridViewTextBoxColumn2.Name = "dataGridViewTextBoxColumn2";
            this.dataGridViewTextBoxColumn2.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            // 

            
                        // 
            // cbSeleniumVendor
            // 
            this.cbSeleniumVendor = new System.Windows.Forms.ComboBox();
            this.cbSeleniumVendor.BackColor = System.Drawing.SystemColors.Menu;
            this.cbSeleniumVendor.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.cbSeleniumVendor.FormattingEnabled = true;
            this.cbSeleniumVendor.Items.AddRange(new object[] {
            "Sauce Labs",
            "BrowserStack",
            "TestingBot"});
            this.cbSeleniumVendor.Location = new System.Drawing.Point(3, 163);
            this.cbSeleniumVendor.Name = "cbSeleniumVendor";
            this.cbSeleniumVendor.Size = new System.Drawing.Size(659, 21);
            this.cbSeleniumVendor.TabIndex = 15;
            this.cbSeleniumVendor.SelectedIndexChanged += new System.EventHandler(this.seleniumVendor_SelectedIndexChanged);

            
            this.Controls.Add(this.dtAdditonalCapabilities);
            this.Controls.Add(this.cbSeleniumVendor);
            // ((System.ComponentModel.ISupportInitialize)(this.dtAdditonalCapabilities)).EndInit();
            this.ResumeLayout(false);

        }
        public System.Windows.Forms.DataGridView dtAdditonalCapabilities;
        private System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1;
        private System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4;
        private System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2;
        private System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn1;
        private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn2;
        private System.Windows.Forms.ComboBox cbSeleniumVendor;
        public VendorBrowser2 vendorBrowser = null;

    }
}
