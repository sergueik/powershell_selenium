using System;
using System.Drawing;
using System.Diagnostics;
using System.Collections;
using System.Windows.Forms;

public class CustomIntervalPicker : System.Windows.Forms.DomainUpDown
{
    private int _minutes = 1;
    private int _seconds = 0;

    public int Minutes
    {
        get
        {
            return _minutes;
        }
    }

    public int Seconds
    {
        get { return _seconds; }
    }

    public CustomIntervalPicker()
    {
        this.Items.Add(_minutes.ToString("00") + ":" + _seconds.ToString("00"));
        _minutes = 0;
        for (_seconds = 59; _seconds >= 1; _seconds -= 1)
        {
            this.Items.Add(_minutes.ToString("00") + ":" + _seconds.ToString("00"));
        }

        this.SelectedIndex = Items.IndexOf("01:00"); // select a default time

        this.Wrap = true;
    }
}

