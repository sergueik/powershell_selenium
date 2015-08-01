using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SwdPageRecorder.WebDriver;
using OpenQA.Selenium;
using OpenQA.Selenium.Remote;

using FormKeys = System.Windows.Forms.Keys;

namespace SwdPageRecorder.UI
{

    public partial class BrowserSettingsTabView : UserControl, IView
    {
        public BrowserSettingsTabPresenter Presenter
        {
            get;
            private set;
        }
        private Control[] driverControls;

        public BrowserSettingsTabView()
        {
            InitializeComponent();
            Presenter = Presenters.BrowserSettingsTabPresenter;
            Presenter.InitWithView(this);

            HandleRemoteDriverSettingsEnabledStatus();

            driverControls = new Control[] { chkUseRemoteHub, grpRemoteConnection, ddlBrowserToStart };

            SetDesiredCapsAvailability(false);
            Presenter.InitDesiredCapabilities();
        }

        private void SetDesiredCapsAvailability(bool enabled)
        {
            grpDesiredCaps.DoInvokeAction(() => grpDesiredCaps.Enabled = enabled);
        }
        
        private void btnStartWebDriver_Click(object sender, EventArgs e)
        {
            WebDriverOptions browserOptions;
            var isRemoteDriver = chkUseRemoteHub.Checked;
            var startSeleniumServerIfNotStarted = chkAutomaticallyStartServer.Checked;
            var shouldMaximizeBrowserWindow = chkMaximizeBrowserWindow.Checked;
            if (dtAdditonalCapabilities.vendorBrowser != null && dtAdditonalCapabilities.vendorBrowser.Custom)
            {

                foreach (DataGridViewRow row in dtAdditonalCapabilities.dataGridView.Rows)
                {
                    string name = row.Cells[0].ToString();
                    string value = row.Cells[1].ToString();
                    if (String.Compare(name, "browser", true) == 0)
                    {
                        dtAdditonalCapabilities.vendorBrowser.Browser = value;
                    }
                    if (String.Compare(name, "version", true) == 0)
                    {
                        dtAdditonalCapabilities.vendorBrowser.Version = value;
                    }
                    if (String.Compare(name, "platform", true) == 0)
                    {
                        dtAdditonalCapabilities.vendorBrowser.Platform = value;
                    }
                    dtAdditonalCapabilities.vendorBrowser.HubUrl = txtRemoteHubUrl.Text;
                }

                browserOptions = new WebDriverOptions()
                {
                    BrowserName = dtAdditonalCapabilities.vendorBrowser.Browser,
                    BrowserPlatform = dtAdditonalCapabilities.vendorBrowser.Platform,
                    BrowserVersion = dtAdditonalCapabilities.vendorBrowser.Version,
                    IsRemote = isRemoteDriver,
                    RemoteUrl = txtRemoteHubUrl.Text,
                };

            }
            else
            {

                browserOptions = new WebDriverOptions()
                {
                    BrowserName = ddlBrowserToStart.SelectedItem as string,
                    IsRemote = isRemoteDriver,
                    RemoteUrl = txtRemoteHubUrl.Text,
                };

            }
            Presenter.StartNewBrowser(browserOptions, startSeleniumServerIfNotStarted, shouldMaximizeBrowserWindow);
        }

        private void HandleRemoteDriverSettingsEnabledStatus()
        {
            grpRemoteConnection.DoInvokeAction(
                    () => { grpRemoteConnection.Enabled = chkUseRemoteHub.Checked; grpDesiredCaps.Enabled = chkUseRemoteHub.Checked; });

            ChangeBrowsersList(chkUseRemoteHub.Checked);
        }

        private void ChangeBrowsersList(bool showAll)
        {
            var selectedItem = ddlBrowserToStart.SelectedItem;
            string previousValue = "";

            if (selectedItem != null)
            {
                previousValue = ddlBrowserToStart.SelectedItem as string;
            }

            ddlBrowserToStart.Items.Clear();

            string[] addedItems = null;
            if (showAll)
            {
                addedItems = WebDriverOptions.allWebdriverBrowsersSupported;
                ddlBrowserToStart.Items.AddRange(addedItems);
            }
            else
            {
                addedItems = WebDriverOptions.embededWebdriverBrowsersSupported;
                ddlBrowserToStart.Items.AddRange(addedItems);
            }

            int index = Array.IndexOf(addedItems, previousValue);
            index = index >= 0 ? index : 0;
            ddlBrowserToStart.SelectedIndex = index;
        }

        private void chkUseRemoteHub_CheckedChanged(object sender, EventArgs e)
        {
            HandleRemoteDriverSettingsEnabledStatus();
        }



        private void SetControlsState(string startButtonCaption, bool isEnabled)
        {
            btnStartWebDriver.DoInvokeAction(() => btnStartWebDriver.Text = startButtonCaption);

            foreach (var control in driverControls)
            {
                btnStartWebDriver.DoInvokeAction(() => control.Enabled = isEnabled);
            }
            HandleRemoteDriverSettingsEnabledStatus();
        }

        internal void DriverIsStopping()
        {
            SetControlsState("Start", true);
            SetDesiredCapsAvailability(false);
        }

        internal void DriverWasStarted()
        {
            SetControlsState("Stop", false);
            SetDesiredCapsAvailability(true);
        }

        internal void DisableDriverStartButton()
        {
            btnStartWebDriver.DoInvokeAction(() => btnStartWebDriver.Enabled = false);
        }

        internal void EnableDriverStartButton()
        {
            btnStartWebDriver.DoInvokeAction(() => btnStartWebDriver.Enabled = true);
        }

        internal void SetStatus(string status)
        {
            lblWebDriverStatus.DoInvokeAction(() => lblWebDriverStatus.Text = status);
        }

        private void btnTestRemoteHub_Click(object sender, EventArgs e)
        {
            Presenter.TestRemoteHub(txtRemoteHubUrl.Text);
        }

        internal void SetTestResult(string result, bool isOk)
        {
            lblRemoteHubStatus.Text = result;
            lblRemoteHubStatus.ForeColor = (isOk) ? Color.Green : Color.Red;
        }

        internal void SetBrowserStartupSettings(WebDriverOptions browserOptions)
        {
            Action action = new Action(() =>
            {
                chkUseRemoteHub.Checked = browserOptions.IsRemote;

                var index = ddlBrowserToStart.Items.IndexOf(browserOptions.BrowserName);

                ddlBrowserToStart.SelectedIndex = index;

                txtRemoteHubUrl.Text = browserOptions.RemoteUrl;
            });

            if (this.InvokeRequired)
            {
                this.Invoke(action);
            }
            else
            {
                action();
            }
        }

        internal void ClickOnStartButton()
        {
            btnStartWebDriver.DoInvokeAction(() => btnStartWebDriver.PerformClick());
        }

        private void tabPage2_Enter(object sender, System.EventArgs e)
        {
            dtAdditonalCapabilities.InitializeDataGridView();
        }

        private void InitializeDataGridView()
        {
            string[] row1 = new string[] { "Meatloaf", "Main Dish", "ground beef",
                                       "**" };
            string[] row2 = new string[] { "Chocolate Cheesecake", "Dessert",
                                       "cream cheese", "***" };

            object[] rows = new object[] { row1, row2 };
            foreach (string[] rowArray in rows)
            {
                dtAdditonalCapabilities.dataGridView.Rows.Add(rowArray);
            }
        }

        private void tabPage1_Enter(object sender, System.EventArgs e)
        {
            Presenter.LoadCapabilities();
        }

        private void lnkSeleniumDownloadPage_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(@"http://docs.seleniumhq.org/download/");
        }

        internal void DisableMaximizeBrowserChackBox()
        {
            chkMaximizeBrowserWindow.DoInvokeAction(() =>
            {
                chkMaximizeBrowserWindow.Enabled = false;
            });
        }

        internal void EnableMaximizeBrowserChackBox()
        {
            chkMaximizeBrowserWindow.DoInvokeAction(() =>
            {
                chkMaximizeBrowserWindow.Enabled = true;
            });
        }
    }
}
