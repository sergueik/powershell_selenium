/* need to integrate into enemenurator */
// and gracefully skip under Mono runtime
using System;
using System.Data;
using System.Runtime.InteropServices;
// http://www.pinvoke.net/default.aspx/user32.systemparametersinfo
public class ScreensaverManager {

public static void Main()
{

	[DllImport("user32.dll", SetLastError = true)]
	[return : MarshalAs(UnmanagedType.Bool)]
	static extern bool SystemParametersInfo(SPI uiAction, uint uiParam, IntPtr pvParam, SPIF fWinIni);

	[DllImport("user32.dll", SetLastError = true)]
	[return : MarshalAs(UnmanagedType.Bool)]
	static extern bool SystemParametersInfo(SPI uiAction, uint uiParam, String pvParam, SPIF fWinIni);

	[DllImport("user32.dll", SetLastError = true)]
	[return : MarshalAs(UnmanagedType.Bool)]
	static extern bool SystemParametersInfo(SPI uiAction, uint uiParam, ref ANIMATIONINFO pvParam, SPIF fWinIni);



	uint vParam = 0;
	if (SystemParametersInfo(SPI.SPI_GETSCREENSAVEACTIVE, 0, ref vParam, SPIF.None)) {
		if (vParam == 1)
			Console.WriteLine( "Screensaver is enabled");

		else
			Console.WriteLine( "Screensaver is disabled");

	}else
		Console.WriteLine( "Error!");

	if (SystemParametersInfo(SPI.SPI_SETSCREENSAVEACTIVE, 0, 0, SPIF.None))
		Console.WriteLine( "Screensaver has been disabled");
	else
		Console.WriteLine( "Error!");
//
// SystemParametersInfo(SPI.SPI_SETSCREENSAVEACTIVE, 1, 0, SPIF.None);

}

// from http://support.microsoft.com/kb/97142
public enum SPI : uint {
	SPI_GETSCREENSAVEACTIVE = 0x0010,
	SPI_SETSCREENSAVEACTIVE = 0x0011
}


// The fuWinIni argument updates the WIN.INI file:
public enum SPIF : uint {
	None = 0x00,
	SPIF_UPDATEINIFILE = 0x01,
	SPIF_SENDCHANGE = 0x02,
	SPIF_SENDWININICHANGE = 0x02,
// pinvoke mentions also SPI_GETFOREGROUNDLOCKTIMEOUT
	SPI_GETFOREGROUNDLOCKTIMEOUT As Long = 0x2000,
	SPI_SETFOREGROUNDLOCKTIMEOUT As Long = 0x2001
}

//[DllImport("user32.dll", SetLastError = true)]
//[return: MarshalAs(UnmanagedType.Bool)]
//static extern bool SystemParametersInfo(SPI uiAction, uint uiParam, ref uint pvParam, SPIF fWinIni);
//[DllImport("user32.dll", SetLastError = true)]
//[return: MarshalAs(UnmanagedType.Bool)]
//static extern bool SystemParametersInfo(SPI uiAction, uint uiParam, uint pvParam, SPIF fWinIni);
}
