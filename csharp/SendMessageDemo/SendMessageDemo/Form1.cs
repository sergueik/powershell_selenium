using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace SendMessageDemo
{
    public partial class Form1 : Form
    {
        public Form1(string fileName)
        {
            InitializeComponent();

            if (!String.IsNullOrEmpty(fileName))
                richTextBox1.Text = String.Format("{0}\r\n", fileName);
        }
        private void cmdClose_Click(object sender, System.EventArgs e)
        {
            this.Close();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            NativeMethods.CHANGEFILTERSTRUCT changeFilter = new NativeMethods.CHANGEFILTERSTRUCT();
            changeFilter.size = (uint)Marshal.SizeOf(changeFilter);
            changeFilter.info = 0;
            if (!NativeMethods.ChangeWindowMessageFilterEx(this.Handle, NativeMethods.WM_COPYDATA, NativeMethods.ChangeWindowMessageFilterExAction.Allow, ref changeFilter))
            {
                int error = Marshal.GetLastWin32Error();
                MessageBox.Show(String.Format("The error {0} occured.", error));
            }
        }

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == NativeMethods.WM_COPYDATA)
            {
                // Extract the file name
                NativeMethods.COPYDATASTRUCT copyData = (NativeMethods.COPYDATASTRUCT)Marshal.PtrToStructure(m.LParam, typeof(NativeMethods.COPYDATASTRUCT));
                int dataType = (int)copyData.dwData;
                if (dataType == 2)
                {
                    string fileName = Marshal.PtrToStringAnsi(copyData.lpData);

                    // Add the file name to the edit box
                    richTextBox1.AppendText(fileName);
                    richTextBox1.AppendText("\r\n");
                }
                else
                {
                    MessageBox.Show(String.Format("Unrecognized data type = {0}.", dataType), "SendMessageDemo", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            else
            {
                base.WndProc(ref m);
            }
        }
    }
}
