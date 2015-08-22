using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace ExplorerFileDialogDetector
{
    static class ConsoleProgram2
    {
 /*
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Get the filename if it exists
            string fileName = "test 2";
            if (args.Length == 1)
                fileName = args[0];

            string windowTitle = "SystemTrayApp";

            // Find the window with the name of the main form
            IntPtr ptrWnd = NativeMethods.FindWindow(null, windowTitle);
            if (ptrWnd == IntPtr.Zero)
            {
                MessageBox.Show(String.Format("No window found with the title '{0}'.", windowTitle), "Program", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
            {
                IntPtr ptrCopyData = IntPtr.Zero;
                try
                {
                    // Create the data structure and fill with data
                    NativeMethods.COPYDATASTRUCT copyData = new NativeMethods.COPYDATASTRUCT();
                    copyData.dwData = new IntPtr(2);    // Just a number to identify the data type
                    copyData.cbData = fileName.Length + 1;  // One extra byte for the \0 character
                    copyData.lpData = Marshal.StringToHGlobalAnsi(fileName);

                    // Allocate memory for the data and copy
                    ptrCopyData = Marshal.AllocCoTaskMem(Marshal.SizeOf(copyData));
                    Marshal.StructureToPtr(copyData, ptrCopyData, false);

                    // Send the message
                    NativeMethods.SendMessage(ptrWnd, NativeMethods.WM_COPYDATA, IntPtr.Zero, ptrCopyData);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.ToString(), "SendMessage Demo", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                finally
                {
                    // Free the allocated memory after the contol has been returned
                    if (ptrCopyData != IntPtr.Zero)
                        Marshal.FreeCoTaskMem(ptrCopyData);
                }
            }
        }
  */
    }
}
