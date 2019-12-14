#Copyright (c) 2019 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

<#
Usage:
powershell.exe -executionpolicy bypass -file console_helper.ps1
REM run the batch command without mouse interruptions
powershell.exe -executionpolicy bypass -file console_helper.ps1 -enable

#>
param(
  [switch]$enable
)
# based on:
# http://forum.oszone.net/thread-325464.html
# purpose: disable or enable simple mouse click-to-select to prevent interruptions
# of a lengthy batch process running in the console window, with the mouse click
#
# See also:
# https://www.pinvoke.net/default.aspx/kernel32.setconsolemode
# https://www.pinvoke.net/default.aspx/kernel32.getconsolemode
# https://www.pinvoke.net/default.aspx/kernel32/GetStdHandle.html
Add-Type -Language 'VisualBasic' -TypeDefinition @'

Imports System
Public Class Helper

  Declare Function GetStdHandle   Lib "kernel32" (ByVal nStdHandle As Integer) As Integer
  Declare Function GetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByRef lpMode As Integer) As Integer
  Declare Function SetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByVal dwMode As Integer) As Integer

  Public Const STD_INPUT_HANDLE As Integer = -10&
  Public Const STD_OUTPUT_HANDLE As Integer = -11&
  Public Const STD_ERROR_HANDLE As Integer = -12&
  
  Public Enum ConsoleModes
    ' 55 /* Console Mode flags */
    ENABLE_PROCESSED_INPUT = &H1
    ENABLE_LINE_INPUT = &H2
    ENABLE_ECHO_INPUT = &H4
    ENABLE_WINDOW_INPUT = &H8
    ENABLE_MOUSE_INPUT = &H10
    ENABLE_INSERT_MODE = &H20
    ENABLE_QUICK_EDIT_MODE = &H40
    ENABLE_EXTENDED_FLAGS = &H80
    ENABLE_AUTO_POSITION = &H100

    ENABLE_PROCESSED_OUTPUT = &H1s
    ENABLE_WRAP_AT_EOL_OUTPUT = &H2

  End Enum
  
  Sub ModifyConsoleMode(ByVal allowMouseSelection As Boolean)
    Dim hConsole As Integer
    Dim iMode As Integer
    Dim bSuccess As Integer

    hConsole = GetStdHandle(STD_INPUT_HANDLE)
    bSuccess = GetConsoleMode(hConsole, iMode)
    If allowMouseSelection = True Then
      bSuccess = SetConsoleMode(hConsole, iMode Or ConsoleModes.ENABLE_QUICK_EDIT_MODE Or ConsoleModes.ENABLE_EXTENDED_FLAGS)
    Else
      bSuccess = SetConsoleMode(hConsole, iMode And Not ConsoleModes.ENABLE_QUICK_EDIT_MODE And Not ConsoleModes.ENABLE_EXTENDED_FLAGS)
    End If

  End Sub
End Class

'@

$object = New-Object -TypeName 'Helper'

if ([bool]$PSBoundParameters['enable'].IsPresent) {
  $object.ModifyConsoleMode($true)
} else {
  $object.ModifyConsoleMode($false)
}

<#
# original code:
# http://forum.oszone.net/thread-325464.html
Add-Type -Language 'VisualBasic' -TypeDefinition @'
' c:\Windows\Microsoft.NET\Framework\v2.0.50727\vbc.exe "ConsoleMode.vb" /target:exe /nologo /verbose
Imports System

Module mainModule
  Declare Function GetStdHandle   Lib "kernel32" (ByVal nStdHandle As Integer) As Integer
  Declare Function GetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByRef lpMode As Integer) As Integer
  Declare Function SetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Integer, ByVal dwMode As Integer) As Integer

  Public Const STD_INPUT_HANDLE As Integer = -10&

  Sub Main()
    Dim hConsole As Integer
    Dim iMode As Integer
    Dim bSuccess As Integer

    hConsole = GetStdHandle(STD_INPUT_HANDLE)
    bSuccess = GetConsoleMode(hConsole, iMode)
    bSuccess = SetConsoleMode(hConsole, iMode And Not &H40)
  End Sub
End Module
'@
#>


