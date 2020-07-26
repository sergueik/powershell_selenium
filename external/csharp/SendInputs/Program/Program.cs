using System;
using System.Threading;

namespace Utility
{
    class Program
    {
        static void Main()
        {
            // If we want to click a special (extended) key like Volume up
            // We need to send to inputs with ExtendedKey and Scancode flags
            // First is 0xe0 and the second is the special key scancode we want
            // You can read more on that here -> https://www.win.tue.nl/~aeb/linux/kbd/scancodes-6.html#microsoft
            InputSender.SendKeyboardInput(new InputSender.KeyboardInput[]
            {
                new InputSender.KeyboardInput
                {
                    wScan = 0xe0,
                    dwFlags = (uint)(InputSender.KeyEventF.ExtendedKey | InputSender.KeyEventF.Scancode),
                },
                new InputSender.KeyboardInput
                {
                    wScan = 0x30,
                    dwFlags = (uint)(InputSender.KeyEventF.ExtendedKey | InputSender.KeyEventF.Scancode)
                }
            });  // Volume +

            // Using our ClickKey wrapper to press W
            // To see more scancodes see this site -> https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
            InputSender.ClickKey(0x11); // W

            Thread.Sleep(1000);

            // Setting the cursor position
            InputSender.SetCursorPosition(100, 100);

            Thread.Sleep(1000);

            // Getting the cursor position
            var point = InputSender.GetCursorPosition();
            Console.WriteLine(point.X);
            Console.WriteLine(point.Y);

            Thread.Sleep(1000);

            // Setting the cursor position RELATIVE to the current position
            InputSender.SendMouseInput(new InputSender.MouseInput[]
            {
                new InputSender.MouseInput
                {
                    dx = 100,
                    dy = 100,
                    dwFlags = (uint)InputSender.MouseEventF.Move
                }
            });
        }
    }
}
