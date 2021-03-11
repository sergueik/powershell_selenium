using Microsoft.VisualBasic.CompilerServices;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace No_Sleep
{
	[DesignerGenerated]
	public class Form1 : Form
	{
		private enum EXECUTION_STATE
		{
			ES_SYSTEM_REQUIRED = 1,
			ES_DISPLAY_REQUIRED,
			ES_CONTINUOUS = -2147483648
		}

		private static List<WeakReference> __ENCList = new List<WeakReference>();

		private IContainer components;

		[AccessedThroughProperty("NoSleep_Timer")]
		private System.Windows.Forms.Timer _NoSleep_Timer;

		[AccessedThroughProperty("Status_Button")]
		private Button _Status_Button;

		[AccessedThroughProperty("NoSleep_NotifyIcon")]
		private NotifyIcon _NoSleep_NotifyIcon;

		private ContextMenu NotifyIcon_contextMenu;

		[AccessedThroughProperty("NotifyIcon_menuItem")]
		private MenuItem _NotifyIcon_menuItem;

		internal virtual System.Windows.Forms.Timer NoSleep_Timer
		{
			[DebuggerNonUserCode]
			get
			{
				return this._NoSleep_Timer;
			}
			[DebuggerNonUserCode]
			[MethodImpl(MethodImplOptions.Synchronized)]
			set
			{
				EventHandler value2 = new EventHandler(this.NoSleep_Timer_Tick);
				bool flag = this._NoSleep_Timer != null;
				if (flag)
				{
					this._NoSleep_Timer.Tick -= value2;
				}
				this._NoSleep_Timer = value;
				flag = (this._NoSleep_Timer != null);
				if (flag)
				{
					this._NoSleep_Timer.Tick += value2;
				}
			}
		}

		internal virtual Button Status_Button
		{
			[DebuggerNonUserCode]
			get
			{
				return this._Status_Button;
			}
			[DebuggerNonUserCode]
			[MethodImpl(MethodImplOptions.Synchronized)]
			set
			{
				EventHandler value2 = new EventHandler(this.Status_Button_Click);
				bool flag = this._Status_Button != null;
				if (flag)
				{
					this._Status_Button.Click -= value2;
				}
				this._Status_Button = value;
				flag = (this._Status_Button != null);
				if (flag)
				{
					this._Status_Button.Click += value2;
				}
			}
		}

		internal virtual NotifyIcon NoSleep_NotifyIcon
		{
			[DebuggerNonUserCode]
			get
			{
				return this._NoSleep_NotifyIcon;
			}
			[DebuggerNonUserCode]
			[MethodImpl(MethodImplOptions.Synchronized)]
			set
			{
				MouseEventHandler value2 = new MouseEventHandler(this.NoSleep_NotifyIcon_MouseDoubleClick);
				bool flag = this._NoSleep_NotifyIcon != null;
				if (flag)
				{
					this._NoSleep_NotifyIcon.MouseDoubleClick -= value2;
				}
				this._NoSleep_NotifyIcon = value;
				flag = (this._NoSleep_NotifyIcon != null);
				if (flag)
				{
					this._NoSleep_NotifyIcon.MouseDoubleClick += value2;
				}
			}
		}

		private virtual MenuItem NotifyIcon_menuItem
		{
			[DebuggerNonUserCode]
			get
			{
				return this._NotifyIcon_menuItem;
			}
			[DebuggerNonUserCode]
			[MethodImpl(MethodImplOptions.Synchronized)]
			set
			{
				EventHandler value2 = new EventHandler(this.menuItem1_Click);
				bool flag = this._NotifyIcon_menuItem != null;
				if (flag)
				{
					this._NotifyIcon_menuItem.Click -= value2;
				}
				this._NotifyIcon_menuItem = value;
				flag = (this._NotifyIcon_menuItem != null);
				if (flag)
				{
					this._NotifyIcon_menuItem.Click += value2;
				}
			}
		}

		public Form1()
		{
			base.Load += new EventHandler(this.Form1_Load);
			base.DoubleClick += new EventHandler(this.Form1_DoubleClick);
			base.FormClosing += new FormClosingEventHandler(this.Form1_FormClosing);
			Form1.__ENCAddToList(this);
			this.NotifyIcon_contextMenu = new ContextMenu();
			this.NotifyIcon_menuItem = new MenuItem();
			this.InitializeComponent();
		}

		[DebuggerNonUserCode]
		private static void __ENCAddToList(object value)
		{
			List<WeakReference> _ENCList = Form1.__ENCList;
			checked
			{
				lock (_ENCList)
				{
					bool flag = Form1.__ENCList.Count == Form1.__ENCList.Capacity;
					if (flag)
					{
						int num = 0;
						int arg_3F_0 = 0;
						int num2 = Form1.__ENCList.Count - 1;
						int num3 = arg_3F_0;
						while (true)
						{
							int arg_90_0 = num3;
							int num4 = num2;
							if (arg_90_0 > num4)
							{
								break;
							}
							WeakReference weakReference = Form1.__ENCList[num3];
							flag = weakReference.IsAlive;
							if (flag)
							{
								bool flag2 = num3 != num;
								if (flag2)
								{
									Form1.__ENCList[num] = Form1.__ENCList[num3];
								}
								num++;
							}
							num3++;
						}
						Form1.__ENCList.RemoveRange(num, Form1.__ENCList.Count - num);
						Form1.__ENCList.Capacity = Form1.__ENCList.Count;
					}
					Form1.__ENCList.Add(new WeakReference(RuntimeHelpers.GetObjectValue(value)));
				}
			}
		}

		[DebuggerNonUserCode]
		protected override void Dispose(bool disposing)
		{
			try
			{
				bool flag = disposing && this.components != null;
				if (flag)
				{
					this.components.Dispose();
				}
			}
			finally
			{
				base.Dispose(disposing);
			}
		}

		[DebuggerStepThrough]
		private void InitializeComponent()
		{
			this.components = new Container();
			ComponentResourceManager resources = new ComponentResourceManager(typeof(Form1));
			this.NoSleep_Timer = new System.Windows.Forms.Timer(this.components);
			this.Status_Button = new Button();
			this.NoSleep_NotifyIcon = new NotifyIcon(this.components);
			this.SuspendLayout();
			this.NoSleep_Timer.Enabled = true;
			this.NoSleep_Timer.Interval = 5000;
			this.Status_Button.BackColor = SystemColors.Control;
			Control arg_95_0 = this.Status_Button;
			Point location = new Point(12, 12);
			arg_95_0.Location = location;
			this.Status_Button.Name = "Status_Button";
			Control arg_C0_0 = this.Status_Button;
			Size size = new Size(44, 23);
			arg_C0_0.Size = size;
			this.Status_Button.TabIndex = 0;
			this.Status_Button.UseVisualStyleBackColor = false;
			this.NoSleep_NotifyIcon.BalloonTipText = "Prevents system from going to sleep (as long as this application is running)";
			this.NoSleep_NotifyIcon.Icon = (Icon)resources.GetObject("NoSleep_NotifyIcon.Icon");
			this.NoSleep_NotifyIcon.Text = "  No Sleep";
			SizeF autoScaleDimensions = new SizeF(6f, 13f);
			this.AutoScaleDimensions = autoScaleDimensions;
			this.AutoScaleMode = AutoScaleMode.Font;
			size = new Size(68, 44);
			this.ClientSize = size;
			this.Controls.Add(this.Status_Button);
			this.FormBorderStyle = FormBorderStyle.FixedToolWindow;
			this.Icon = (Icon)resources.GetObject("$this.Icon");
			this.MaximizeBox = false;
			size = new Size(74, 68);
			this.MaximumSize = size;
			this.MinimizeBox = false;
			size = new Size(74, 68);
			this.MinimumSize = size;
			this.Name = "Form1";
			this.Text = "No Sleep";
			this.ResumeLayout(false);
		}

		[DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
		private static extern Form1.EXECUTION_STATE SetThreadExecutionState(Form1.EXECUTION_STATE esflags);

		private void Form1_Load(object sender, EventArgs e)
		{
			this.No_Sleep();
			this.NotifyIcon_contextMenu.MenuItems.AddRange(new MenuItem[]
			{
				this.NotifyIcon_menuItem
			});
			this.NotifyIcon_menuItem.Index = 0;
			this.NotifyIcon_menuItem.Text = "E&xit";
			this.NoSleep_NotifyIcon.ContextMenu = this.NotifyIcon_contextMenu;
		}

		private void NoSleep_Timer_Tick(object sender, EventArgs e)
		{
			Color Save_Backcolor = this.Status_Button.BackColor;
			this.Status_Button.BackColor = Color.Red;
			this.Update();
			Thread.Sleep(500);
			this.Status_Button.BackColor = Save_Backcolor;
			this.Update();
		}

		private void MinimizeAppToTray()
		{
			this.Hide();
			this.NoSleep_NotifyIcon.Visible = true;
			this.NoSleep_NotifyIcon.ShowBalloonTip(16000);
		}

		private void ShowAppForm()
		{
			this.Show();
			this.NoSleep_NotifyIcon.Visible = false;
		}

		private void NoSleep_NotifyIcon_MouseDoubleClick(object sender, MouseEventArgs e)
		{
			this.ShowAppForm();
		}

		private void Form1_DoubleClick(object sender, EventArgs e)
		{
			this.MinimizeAppToTray();
		}

		private void Status_Button_Click(object sender, EventArgs e)
		{
			this.MinimizeAppToTray();
		}

		private Form1.EXECUTION_STATE No_Sleep()
		{
			return Form1.SetThreadExecutionState((Form1.EXECUTION_STATE)(-2147483645));
		}

		private void menuItem1_Click(object sender, EventArgs e)
		{
			this.Close();
		}

		private void Form1_FormClosing(object sender, FormClosingEventArgs e)
		{
			this.NoSleep_NotifyIcon.Visible = false;
			this.NoSleep_NotifyIcon.Icon = null;
			this.NoSleep_NotifyIcon.Dispose();
		}
	}
}

