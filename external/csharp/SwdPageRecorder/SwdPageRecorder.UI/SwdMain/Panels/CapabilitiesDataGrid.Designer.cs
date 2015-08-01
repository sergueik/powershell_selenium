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
        	
        	this.dataGridView = new System.Windows.Forms.DataGridView();
        	this.cbSeleniumVendor = new System.Windows.Forms.ComboBox();
        	((System.ComponentModel.ISupportInitialize)(this.dataGridView)).BeginInit();
        	this.SuspendLayout();
        	// 
        	// dataGridView
        	// 
        	
        	this.dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
        	this.dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
        	this.dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));

        	this.dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
        	this.dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        	
        	this.datadataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
        	this.datadataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn();

        	this.dataGridView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
        	this.dataGridView.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells;
        	this.dataGridView.ColumnHeadersDefaultCellStyle = this.dataGridViewCellStyle1;
        	this.dataGridView.ColumnHeadersHeight = 16;
        	this.dataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
			this.datadataGridViewTextBoxColumn1,
			this.datadataGridViewTextBoxColumn2});
        	this.dataGridView.Dock = System.Windows.Forms.DockStyle.Top;
        	this.dataGridView.Location = new System.Drawing.Point(0, 0);
        	this.dataGridView.Name = "dataGridView";
        	this.dataGridView.RowsDefaultCellStyle = this.dataGridViewCellStyle2;
        	this.dataGridView.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
        	this.dataGridView.Size = new System.Drawing.Size(552, 92);
        	this.dataGridView.TabIndex = 1;
        	this.dataGridView.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.DataGridViewCellContentClick);
        	// 
        	// datadataGridViewTextBoxColumn1
        	// 
        	this.datadataGridViewTextBoxColumn1.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
        	
        	this.datadataGridViewTextBoxColumn1.DefaultCellStyle = this.dataGridViewCellStyle2;
        	this.datadataGridViewTextBoxColumn1.HeaderText = "Capability";
        	this.datadataGridViewTextBoxColumn1.Name = "datadataGridViewTextBoxColumn1";
        	this.datadataGridViewTextBoxColumn1.Resizable = System.Windows.Forms.DataGridViewTriState.False;
        	// 
        	// datadataGridViewTextBoxColumn2
        	// 
        	this.datadataGridViewTextBoxColumn2.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
        	
        	this.datadataGridViewTextBoxColumn2.DefaultCellStyle = this.dataGridViewCellStyle2;
        	this.datadataGridViewTextBoxColumn2.HeaderText = "Value";
        	this.datadataGridViewTextBoxColumn2.Name = "datadataGridViewTextBoxColumn2";
        	this.datadataGridViewTextBoxColumn2.Resizable = System.Windows.Forms.DataGridViewTriState.False;
        	// 
        	// cbSeleniumVendor
        	// 
        	this.cbSeleniumVendor.BackColor = System.Drawing.SystemColors.Menu;
        	this.cbSeleniumVendor.Dock = System.Windows.Forms.DockStyle.Bottom;
        	this.cbSeleniumVendor.FormattingEnabled = true;
        	this.cbSeleniumVendor.Items.AddRange(new object[] {
			"Sauce Labs",
			"BrowserStack",
			"TestingBot"});
        	this.cbSeleniumVendor.Location = new System.Drawing.Point(0, 109);
        	this.cbSeleniumVendor.Name = "cbSeleniumVendor";
        	this.cbSeleniumVendor.Size = new System.Drawing.Size(552, 21);
        	this.cbSeleniumVendor.TabIndex = 15;
        	this.cbSeleniumVendor.SelectedIndexChanged += new System.EventHandler(this.seleniumVendor_SelectedIndexChanged);
        	// 
        	// CapabilitiesDataGridView
        	// 
        	this.Controls.Add(this.dataGridView);
        	this.Controls.Add(this.cbSeleniumVendor);
        	this.Size = new System.Drawing.Size(552, 130);
        	((System.ComponentModel.ISupportInitialize)(this.dataGridView)).EndInit();
        	this.ResumeLayout(false);

        }
        public System.Windows.Forms.DataGridView dataGridView;
        private System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1;
        private System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2;
        private System.Windows.Forms.DataGridViewTextBoxColumn datadataGridViewTextBoxColumn1;
        private System.Windows.Forms.DataGridViewTextBoxColumn datadataGridViewTextBoxColumn2;
        private System.Windows.Forms.ComboBox cbSeleniumVendor;
        public VendorBrowser vendorBrowser = null;
        public BrowserSettingsTabView parent;
    }
}
