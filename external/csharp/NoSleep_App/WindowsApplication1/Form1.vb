' Written by Mike Metzger
' Certifications: CISSP, Security+

Imports Microsoft.Win32     ' for system events
Imports System.Threading    ' For sleep

Public Class Form1

    ' Used for NotifyIcon shortcut menu
    Dim NotifyIcon_contextMenu As New System.Windows.Forms.ContextMenu
    Dim WithEvents NotifyIcon_menuItem As New System.Windows.Forms.MenuItem  ' Needs events as menu item will be clickable

    ' API call to prevent sleep (until the application exits)
    Private Declare Function SetThreadExecutionState Lib "kernel32" (ByVal esflags As EXECUTION_STATE) As EXECUTION_STATE

    ' Define the API execution states
    Private Enum EXECUTION_STATE
        ES_SYSTEM_REQUIRED = &H1    ' Stay in working state by resetting display idle timer
        ES_DISPLAY_REQUIRED = &H2   ' Force display on by resetting system idle timer
        ES_CONTINUOUS = &H80000000  ' Force this state until next ES_CONTINUOUS call and one of the other flags are cleared
    End Enum

    ' Prevents sleep as form loads
    Private Sub Form1_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        No_Sleep()

        ' Create and add shortcut menu to NotifyIcon
        NotifyIcon_contextMenu.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {NotifyIcon_menuItem})
        NotifyIcon_menuItem.Index = 0
        NotifyIcon_menuItem.Text = "E&xit"
        NoSleep_NotifyIcon.ContextMenu = NotifyIcon_contextMenu
    End Sub

    ' Flash button (so users know it's still running)
    Private Sub NoSleep_Timer_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles NoSleep_Timer.Tick
        Dim Save_Backcolor As Color = Status_Button.BackColor
        Status_Button.BackColor = Color.Red
        Me.Update()
        Thread.Sleep(500)   ' keeps button red for time
        Status_Button.BackColor = Save_Backcolor
        Me.Update()
    End Sub

    ' hide application form
    Private Sub MinimizeAppToTray()
        Me.Hide()
        NoSleep_NotifyIcon.Visible = True
        ' Show ballon text for time when app minimized
        NoSleep_NotifyIcon.ShowBalloonTip(16000)
    End Sub

    ' Show application form
    Private Sub ShowAppForm()
        Me.Show()
        NoSleep_NotifyIcon.Visible = False   ' Tray icon removed when app displayed
    End Sub

    ' Show application form if click on tray icon
    Private Sub NoSleep_NotifyIcon_MouseDoubleClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles NoSleep_NotifyIcon.MouseDoubleClick
        ShowAppForm()
    End Sub

    ' Minimize to tray if form double clicked
    Private Sub Form1_DoubleClick(sender As Object, e As System.EventArgs) Handles Me.DoubleClick
        MinimizeAppToTray()
    End Sub

    ' Minimize to tray if button double clicked
    Private Sub Status_Button_Click(sender As System.Object, e As System.EventArgs) Handles Status_Button.Click
        MinimizeAppToTray()
    End Sub

    ' Call API - force no sleep and no display turn off
    Private Function No_Sleep() As EXECUTION_STATE
        Return SetThreadExecutionState(EXECUTION_STATE.ES_SYSTEM_REQUIRED Or EXECUTION_STATE.ES_CONTINUOUS Or EXECUTION_STATE.ES_DISPLAY_REQUIRED)
    End Function

    ' Exit the application if NotifyIcon Exit menu item selected
    Private Sub menuItem1_Click(sender As Object, e As System.EventArgs) Handles NotifyIcon_menuItem.Click
        Me.Close()
    End Sub

    ' Remove system tray icon when app closing
    Private Sub Form1_FormClosing(sender As Object, e As System.Windows.Forms.FormClosingEventArgs) Handles Me.FormClosing
        ' These are needed to properly remove the icon from the system tray (or the icon will stay there until mouse scrolls over it)
        NoSleep_NotifyIcon.Visible = False
        NoSleep_NotifyIcon.Icon = Nothing
        NoSleep_NotifyIcon.Dispose()
    End Sub

End Class






