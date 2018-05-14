### Info

This directory contains code of utility to prevent workstations from going to sleep (during long running processes) from the article [Give your computer sleep apnea - Don't let it go](https://www.codeproject.com/KB/winsdk/No_Sleep/Prevent_Sleep.zip)

Effectively it just calls
```c#
private enum EXECUTION_STATE {
  ES_SYSTEM_REQUIRED = 1,
  ES_DISPLAY_REQUIRED,
  ES_CONTINUOUS = -2147483648
}
[DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
		private static extern Form1.EXECUTION_STATE SetThreadExecutionState(Form1.EXECUTION_STATE esflags);

SetThreadExecutionState(EXECUTION_STATE.ES_SYSTEM_REQUIRED | EXECUTION_STATE.ES_CONTINUOUS | EXECUTION_STATE.ES_DISPLAY_REQUIRED)

```
### See also
 * https://www.codeproject.com/Tips/490390/How-to-disable-the-Sleep-button-while-your-code-is
 * [etThreadExecutionState function](https://msdn.microsoft.com/en-us/library/windows/desktop/aa373208(v=vs.85).aspx)
 * [System Sleep Criteria](https://msdn.microsoft.com/en-us/library/windows/desktop/aa373233(v=vs.85).aspx)
