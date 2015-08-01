using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SwdPageRecorder.UI
{
    public partial class CapabilitiesDataGridView : UserControl, IView
    {
        public CapabilitiesDataGridPresenter Presenter { get; private set; }
        public CapabilitiesDataGridView()
        {
            InitializeComponent();
            Presenter = Presenters.CapabilitiesDataGridPresenter;
            Presenter.InitWithView(this);
        }
                private void seleniumVendor_SelectedIndexChanged(object sender, EventArgs e)
        {
            var dtVendorCapabilities = new Dictionary<string, Dictionary<string, Object>>();

            dtVendorCapabilities.Add("Sauce Labs", new Dictionary<string, Object>{ { "capabilities", new Dictionary<string, string>{
                                                                                          { "username", "<USERNAME>" },
                                                                                          { "accessKey", "<ACCESSKEY>" }
                                                                                  } }, { "hub_url", "http://ondemand.saucelabs.com:80/wd/hub/" }, { "help_url", "https://www.browserstack.com/automate/c-sharp#configure-capabilities" },
                                                                                { "platform", "linux" },
                                                                                { "browser", "chrome" },
                                                                                { "version", "35" }, });


            dtVendorCapabilities.Add("TestingBot", new Dictionary<string, Object>{ { "capabilities", new Dictionary<string, string>{
                                                                                          { "username", "<USERNAME>" },
                                                                                          { "accesskey", "<ACCESSKEY>" }
                                                                                  } }, { "hub_url", "" }, { "help_url", "https://testingbot.com/features" },
                                                                                { "platform", "<PLATFORM>" },
                                                                                { "browser", "<BROWSER>" },
                                                                                { "version", "<VERSION>" }, });

            dtVendorCapabilities.Add("BrowserStack", new Dictionary<string, Object>{ { "capabilities", new Dictionary<string, string>{
                                                                                            { "browserstack.user", "<BROWSERSTACK.USER>" },
                                                                                            { "browserstack.key", "<BROWSERSTACK.KEY>" }
                                                                                    } }, { "hub_url", "http://hub.browserstack.com/wd/hub/" }, { "help_url", "https://www.browserstack.com/automate/c-sharp#configure-capabilities" },
                                                                                  { "platform", "<PLATFORM>" },
                                                                                  { "browser", "<BROWSER>" },
                                                                                  { "version", "<VERSION>" }, });
            string vendor = cbSeleniumVendor.SelectedItem.ToString();
            if (dtVendorCapabilities.ContainsKey(vendor))
            {
                // create a dummy vendorBrowser
                vendorBrowser = new VendorBrowser ();

                vendorBrowser.Browser = null;
                vendorBrowser.Version = null;
                vendorBrowser.Platform = null;
                vendorBrowser.Custom = true;
                
                vendorBrowser.HubUrl =  dtVendorCapabilities[vendor]["hub_url"].ToString();
                // TODO: update  the chkUseRemoteHub.Checked and txtRemoteHubUrl.Text
                parent.txtRemoteHubUrl.Text = vendorBrowser.HubUrl;
                parent.chkUseRemoteHub.Checked = true;
                // fill dataGridView DataGridView with vendor-specific inputs
                dataGridView.Rows.Clear();
                foreach (var configuration_input in new String[] { "browser", "platform", "version" })
                {
                    dataGridView.Rows.Add(new String[] { configuration_input, dtVendorCapabilities[vendor][configuration_input].ToString() });
                }

                Object capabilities_input_object;
                dtVendorCapabilities[vendor].TryGetValue("capabilities", out capabilities_input_object);
                Dictionary<string, string> capabilities_input = new Dictionary<string, string>();
                try
                {
                    capabilities_input = capabilities_input_object as Dictionary<string, string>;
                }
                catch (Exception) { /* ignore */ }

                foreach (string capability_name in capabilities_input.Keys)
                {
                    dataGridView.Rows.Add(new String[] { capability_name, capabilities_input[capability_name].ToString() });
                }
            }
        }
        public void InitializeDataGridView()
        {
            string[] row1 = new string[] { "Browser Name", "<BROWSER_NAME>" };
            string[] row2 = new string[] { "Browser Platform", "<BROWSER_PLATFORM>" };

            foreach (string[] rowArray in new object[] { row1, row2 })
            {
                dataGridView.Rows.Add(rowArray);
            }
        }
		void DataGridViewCellContentClick(object sender, DataGridViewCellEventArgs e)
		{
	
		}

    }
    public class VendorBrowser
    {
        public string Browser { get; set; }
        public string Version { get; set; }
        public string Platform { get; set; }
        public string HubUrl { get; set; }
        public bool Custom { get; set; }
    }

}
