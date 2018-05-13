<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(Form1))
        Me.NoSleep_Timer = New System.Windows.Forms.Timer(Me.components)
        Me.Status_Button = New System.Windows.Forms.Button()
        Me.NoSleep_NotifyIcon = New System.Windows.Forms.NotifyIcon(Me.components)
        Me.SuspendLayout()
        '
        'NoSleep_Timer
        '
        Me.NoSleep_Timer.Enabled = True
        Me.NoSleep_Timer.Interval = 5000
        '
        'Status_Button
        '
        Me.Status_Button.BackColor = System.Drawing.SystemColors.Control
        Me.Status_Button.Location = New System.Drawing.Point(12, 12)
        Me.Status_Button.Name = "Status_Button"
        Me.Status_Button.Size = New System.Drawing.Size(44, 23)
        Me.Status_Button.TabIndex = 0
        Me.Status_Button.UseVisualStyleBackColor = False
        '
        'NoSleep_NotifyIcon
        '
        Me.NoSleep_NotifyIcon.BalloonTipText = "Prevents system from going to sleep (as long as this application is running)"
        Me.NoSleep_NotifyIcon.Icon = CType(resources.GetObject("NoSleep_NotifyIcon.Icon"), System.Drawing.Icon)
        Me.NoSleep_NotifyIcon.Text = "  No Sleep"
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(68, 44)
        Me.Controls.Add(Me.Status_Button)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MaximizeBox = False
        Me.MaximumSize = New System.Drawing.Size(74, 68)
        Me.MinimizeBox = False
        Me.MinimumSize = New System.Drawing.Size(74, 68)
        Me.Name = "Form1"
        Me.Text = "No Sleep"
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents NoSleep_Timer As System.Windows.Forms.Timer
    Friend WithEvents Status_Button As System.Windows.Forms.Button
    Friend WithEvents NoSleep_NotifyIcon As System.Windows.Forms.NotifyIcon

End Class
