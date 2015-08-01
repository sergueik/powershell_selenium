using System;

using System.IO;

using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

using System.Collections.ObjectModel;

using System.Xml;
using System.Xml.Linq;

using System.Windows.Forms;
using System.Diagnostics;


namespace SwdPageRecorder.UI
{
    public class CapabilitiesDataGridPresenter : IPresenter<CapabilitiesDataGridView>
    {
        private CapabilitiesDataGridView view;

        public void InitWithView(CapabilitiesDataGridView view)
        {
            this.view = view;

            // TODO: Subscribe to WebDriverUtils events
            // SwdBrowser.OnDriverStarted += InitControls;
            // SwdBrowser.OnDriverClosed += InitControls;
            InitControls();
        }

        private void InitControls()
        {
            // view.btnGetHtmlSource.Enabled = shouldControlBeEnabled;
            // view.txtHtmlPageSource.Enabled = shouldControlBeEnabled;
        }

    }
}
